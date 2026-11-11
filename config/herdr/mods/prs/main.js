// Pull requests: the open GitHub PRs of the shown space's repository (`gh pr list`), and the CI of its branch.
// Shown as a pane (`pane.split {direction, mod: "prs"}`). With `props: {button: true}` (the main-prs
// layout's tab bar) it's the button that opens or closes that pane, split to the right in the shown tab,
// and watches CI on every branch a terminal is on.
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, Scrollbar } from "gpui-base";
import { spaces, panes, terminals, focused, exec, home, theme, props, run, notify } from "herdr";

// Where the shown space is now: the focused pane's folder, on its machine (as mods/changes does).
function location() {
  const space = spaces().find((s) => s.active), f = focused();
  let pane = f?.pane ? panes().find(p => p.pane === f.pane) : null;
  // A mod pane (this panel split beside a shell) has no folder: use its tab's first terminal.
  if (pane && !pane.terminal) pane = panes().find(p => p.tab === pane.tab && p.terminal && p.cwd) ?? pane;
  const on = f?.pane === null ? (f.terminal?.includes("/") ? f.terminal.split("/")[0] : null) : space?.machine ?? null;
  return { cwd: pane?.cwd || f?.cwd || space?.folder, on, branch: pane?.branch ?? null };
}
const key = () => JSON.stringify(location());

// Review checkouts sit with mods/worktree's: <worktrees>/<repo>/pr-<N>, on branch pr-<N>.
const WORKTREES = (home) => `${home}/.herdr/worktrees`;
const under = (path) => (at) => at === path || Boolean(at?.startsWith(`${path}/`));
// `claude <prompt>` as a line for that shell (the prompt is the PR title's, so it's quoted, not trusted).
function claudeLine(shell, prompt) {
  const name = (shell ?? "").split("/").pop();
  if (name === "nu") {
    let h = "#";
    while (prompt.includes(`'${h}`)) h += "#";
    return `claude r${h}'${prompt}'${h}`;
  }
  if (name === "fish") return `claude '${prompt.replace(/[\\']/g, "\\$&")}'`;
  return `claude '${prompt.replace(/'/g, "'\\''")}'`;
}
const REVIEW_PROMPT = (pr) =>
  `PR #${pr.number} (${pr.title}) をレビューして。gh pr view ${pr.number} と gh pr diff ${pr.number} で内容を確認して`;

const LIMIT = 50;
const FIELDS = "number,title,author,isDraft,headRefName,reviewDecision,statusCheckRollup,url,updatedAt,additions,deletions";
// Where gh may live when the app's PATH lacks it (mise, Homebrew); the first that starts is kept.
const GH_PLACES = (on) => [
  "gh",
  ...(on ? [] : [`${home()}/.local/share/mise/shims/gh`, `${home()}/.local/bin/gh`]),
  "/opt/homebrew/bin/gh", "/usr/local/bin/gh", "/home/linuxbrew/.linuxbrew/bin/gh",
];
const FAILED = new Set(["FAILURE", "ERROR", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED", "STARTUP_FAILURE"]);

// The PR's checks as one word: failure > pending > success; "none" without checks.
function checks(rollup) {
  if (!rollup?.length) return "none";
  let pending = false;
  for (const c of rollup) {
    const state = c.__typename === "StatusContext" ? c.state : c.status === "COMPLETED" ? c.conclusion : "PENDING";
    if (FAILED.has(state)) return "failure";
    if (state === "PENDING" || state === "EXPECTED") pending = true;
  }
  return pending ? "pending" : "success";
}

function ago(iso) {
  const s = Math.max(0, (Date.now() - Date.parse(iso)) / 1000);
  if (!Number.isFinite(s)) return "";
  if (s < 60) return "just now";
  if (s < 3600) return `${Math.floor(s / 60)}m ago`;
  if (s < 86400) return `${Math.floor(s / 3600)}h ago`;
  if (s < 86400 * 30) return `${Math.floor(s / 86400)}d ago`;
  if (s < 86400 * 365) return `${Math.floor(s / (86400 * 30))}mo ago`;
  return `${Math.floor(s / (86400 * 365))}y ago`;
}

// CI: the GitHub Actions runs on a branch's newest commit, the latest per workflow. Scheduled runs are
// left out: they follow the clock on the default branch, not what was pushed.
const RUN_FIELDS = "databaseId,workflowName,status,conclusion,url,headSha,event,updatedAt";
const CI_EVERY = 120000;
const runState = (r) => r.status !== "completed" ? "pending" : FAILED.has(String(r.conclusion).toUpperCase()) ? "failure" : "success";
function ciOf(all) {
  const runs = all.filter((r) => r.event !== "schedule"), sha = runs[0]?.headSha ?? null, latest = [], seen = new Set();
  for (const r of runs) {
    if (r.headSha !== sha || seen.has(r.workflowName)) continue;
    seen.add(r.workflowName);
    latest.push({ ...r, state: runState(r) });
  }
  const has = (state) => latest.some((r) => r.state === state);
  return { sha, runs: latest, state: !latest.length ? "none" : has("failure") ? "failure" : has("pending") ? "pending" : "success" };
}
const ciKey = (on, top, branch) => JSON.stringify([on ?? null, top, branch]);

// Turns gh's failure into something the panel can explain.
function failure(text) {
  if (/auth login|not logged in|authenticat|HTTP 401|bad credentials/i.test(text)) return "auth";
  if (/no git remotes|none of the git remotes|not a github|could not determine/i.test(text)) return "noremote";
  return "error";
}

// Review filters: a `reviewDecision`, or "all" (also the PRs that need no review).
const FILTERS = [
  ["all", "All"],
  ["REVIEW_REQUIRED", "Review required"],
  ["CHANGES_REQUESTED", "Changes requested"],
  ["APPROVED", "Approved"],
];
const matches = (pr, filter) => filter === "all" || pr.reviewDecision === filter;

const EMPTY = {
  nofolder: ["No folder", "This space has no folder to look in."],
  nogit: ["Not a git repository", null],
  noremote: ["No GitHub remote", "This repository has no remote on GitHub."],
  auth: ["GitHub CLI is not signed in", "Run `gh auth login` in a terminal, then refresh."],
  nogh: ["GitHub CLI not found", "Install `gh` (brew install gh) or put it on PATH, then refresh."],
  error: ["Couldn't load pull requests", null],
};

export default class Prs extends View {
  init(_props, cx) {
    if (props()?.button) {
      // tops: checkout folder of each terminal folder; ci: ciKey → ciOf; told: failing commits already toasted.
      // asked: shown folder + branch pairs that started a watch at once (a new space or branch).
      this.ghBin = {}; this.tops = new Map(); this.ci = new Map(); this.told = new Set(); this.since = Date.now();
      this.asked = new Set();
      this.watch(cx);
      cx.timer.every(CI_EVERY, (cx) => this.watch(cx));
      return;
    }
    this.prs = []; this.state = null; this.detail = null; this.root = null; this.gen = 0; this.ghBin = {};
    // reviews: this repo's review checkouts (PR number → folder); busy: PR number → what it's doing.
    this.hovered = null; this.reviews = new Map(); this.busy = new Map();
    try { this.filter = localStorage.getItem("filter"); } catch { this.filter = null; }
    if (!FILTERS.some(([k]) => k === this.filter)) this.filter = "all";
    this.refresh(cx);
    cx.timer.every(60000, (cx) => this.refresh(cx));
  }

  // From render, `notify` is false: render already draws the new state and may not notify.
  refresh(cx, notify = true) {
    const { cwd, on } = location(), context = key();
    if (context !== this.context) {
      this.context = context; this.prs = []; this.state = null; this.detail = null; this.root = null; this.loading = false;
      this.reviews = new Map(); this.branch = null; this.runs = null;
    }
    if (this.loading) return;
    if (!cwd) { this.state = "nofolder"; if (notify) cx.notify(); return; }
    const gen = ++this.gen;
    const current = () => gen === this.gen && key() === context;
    this.loading = true;
    if (notify) cx.notify();
    cx.spawn(async (cx) => {
      try {
        const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd, on });
        if (!current()) return;
        if (top.code !== 0) { this.prs = []; this.root = null; this.state = "nogit"; this.detail = cwd; return; }
        const root = top.stdout.trim();
        let r;
        try {
          r = await this.gh(["pr", "list", "--state", "open", "--limit", String(LIMIT), "--json", FIELDS], root, on);
        } catch (e) {
          if (!current()) return;
          const text = String(e);
          this.prs = []; this.root = root;
          if (/not found|no such file|cannot find|failed to start|spawn/i.test(text)) { this.state = "nogh"; this.detail = null; }
          else { this.state = "error"; this.detail = text; }
          return;
        }
        if (!current()) return;
        this.root = root;
        if (r.code !== 0) {
          const text = (r.stderr || r.stdout).trim();
          this.prs = []; this.state = failure(text); this.detail = text.split("\n")[0];
          return;
        }
        this.prs = JSON.parse(r.stdout || "[]").map((p) => ({ ...p, checks: checks(p.statusCheckRollup) }));
        this.state = "ok"; this.detail = null;
        cx.notify();
        const branch = (await exec("git", ["rev-parse", "--abbrev-ref", "HEAD"], { cwd: root, on })).stdout.trim();
        const runs = branch && branch !== "HEAD" ? await this.ciOn(root, branch, on).catch(() => null) : null;
        if (!current()) return;
        this.branch = branch; this.runs = runs;
        cx.notify();
        await this.syncReviews(root, on, current, cx).catch((e) => console.log(`prs: reviews: ${e}`));
      } catch (e) {
        if (current()) { this.prs = []; this.state = "error"; this.detail = String(e); }
      } finally {
        if (gen === this.gen) this.loading = false;
        cx.notify();
      }
    });
  }

  // Runs gh on that machine, trying the usual places when it's not on PATH.
  async gh(args, cwd, on) {
    const known = this.ghBin[on ?? ""];
    let last;
    for (const bin of [...new Set([known, ...GH_PLACES(on)].filter(Boolean))]) {
      try {
        const r = await exec(bin, args, { cwd, on });
        this.ghBin[on ?? ""] = bin;
        return r;
      } catch (e) { last = e; }
    }
    throw last;
  }

  // A branch's CI, asked from its checkout. Runs carry the pushed branch's name, so a local branch that
  // tracks another (pr-<N> from gh pr checkout) is looked up by the one it tracks.
  async ciOn(top, branch, on) {
    const merge = await exec("git", ["config", "--get", `branch.${branch}.merge`], { cwd: top, on }).catch(() => null);
    const pushed = merge?.code === 0 && merge.stdout.trim().replace(/^refs\/heads\//, "") || branch;
    const r = await this.gh(["run", "list", "--branch", pushed, "--limit", "20", "--json", RUN_FIELDS], top, on);
    if (r.code !== 0) throw new Error((r.stderr || r.stdout).trim() || "gh run list failed");
    return ciOf(JSON.parse(r.stdout || "[]"));
  }

  // The checkout a terminal folder is in (null outside git), remembered.
  async top(cwd, on) {
    const k = `${on ?? ""}|${cwd}`;
    if (!this.tops.has(k)) {
      const r = await exec("git", ["rev-parse", "--show-toplevel"], { cwd, on }).catch(() => null);
      this.tops.set(k, r?.code === 0 ? r.stdout.trim() : null);
    }
    return this.tops.get(k);
  }

  // The button's watch: CI on every branch a terminal is on (agents' in other spaces too).
  watch(cx) {
    if (this.watching) return;
    this.watching = true;
    cx.spawn(async (cx) => {
      try {
        const machine = new Map(spaces().flatMap((s) => (s.tabs ?? []).map((c) => [c.id, s.machine ?? null])));
        const branches = new Map();
        for (const p of panes()) {
          if (!p.terminal || !p.cwd || !p.branch || p.branch === "HEAD") continue;
          const on = machine.get(p.tab) ?? null, top = await this.top(p.cwd, on);
          if (top) branches.set(ciKey(on, top, p.branch), { on, top, branch: p.branch });
        }
        for (const k of [...this.ci.keys()]) if (!branches.has(k)) this.ci.delete(k);
        for (const [k, b] of branches) {
          try {
            const ci = await this.ciOn(b.top, b.branch, b.on);
            this.ci.set(k, ci);
            this.tell(b, k, ci);
            cx.notify();
          } catch (e) { console.log(`prs: ci ${b.branch}: ${e}`); }
        }
      } finally { this.watching = false; cx.notify(); }
    });
  }

  // A toast once per failing commit, and only for one that failed after Herdr started: older failures
  // show as the button's dot.
  tell(b, k, ci) {
    if (ci.state !== "failure" || this.told.has(`${k}|${ci.sha}`)) return;
    this.told.add(`${k}|${ci.sha}`);
    const failed = ci.runs.filter((r) => r.state === "failure");
    if (!failed.some((r) => Date.parse(r.updatedAt) >= this.since)) return;
    notify({ title: `CI failed on ${b.branch}`, body: `${b.top.split("/").pop()}: ${failed.map((r) => r.workflowName).join(", ")}`, level: "error" });
  }

  openPr(pr) {
    exec("open", [pr.url]).catch(() => null);
  }

  // Runs one review action for a PR at a time, reporting a failure as a toast.
  act(pr, label, cx, work) {
    const { on } = location(), root = this.root;
    if (!root || this.busy.has(pr.number)) return;
    this.busy.set(pr.number, label);
    cx.notify();
    cx.spawn(async (cx) => {
      try { await work(root, on, cx); }
      catch (e) { notify({ title: `#${pr.number}: ${label.replace("…", "")} failed`, body: String(e?.message ?? e).split("\n")[0], level: "error" }); }
      finally { this.busy.delete(pr.number); cx.notify(); }
    });
  }

  // Where this repo's review checkouts go: its main checkout, and <worktrees>/<repo> on that machine.
  async reviewBase(root, on) {
    const r = await exec("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], { cwd: root, on });
    if (r.code !== 0) throw new Error(r.stderr.trim() || "Not a git repository.");
    const common = r.stdout.trim(), main = common.endsWith("/.git") ? common.slice(0, -5) : common;
    let userHome = home();
    if (on) userHome = (await exec("sh", ["-c", 'printf %s "$HOME"'], { on })).stdout.trim();
    if (!userHome) throw new Error("Couldn't find the home folder.");
    return { main, dir: `${WORKTREES(userHome)}/${main.split("/").pop()}` };
  }

  // This repo's review checkouts: PR number → folder.
  async reviewCheckouts(base, on) {
    const r = await exec("git", ["worktree", "list", "--porcelain"], { cwd: base.main, on });
    const found = new Map();
    for (const line of r.code === 0 ? r.stdout.split("\n") : []) {
      const m = line.startsWith(`worktree ${base.dir}/`) && line.slice(`worktree ${base.dir}/`.length).match(/^pr-(\d+)$/);
      if (m) found.set(Number(m[1]), line.slice("worktree ".length));
    }
    return found;
  }

  // The tabs with a terminal in that folder, on that machine: { space, tab }.
  tabsAt(path, on) {
    const at = under(path), tabs = new Set(panes().filter((p) => p.terminal && at(p.cwd)).map((p) => p.tab));
    return spaces().filter((s) => (s.machine ?? null) === (on ?? null))
      .flatMap((s) => (s.tabs ?? []).filter((c) => tabs.has(c.id)).map((c) => ({ space: s.id, tab: c.id })));
  }

  // The repo's own space: the one whose first terminal is in its main checkout, else the shown one.
  repoSpace(main, on) {
    const all = panes(), at = under(main);
    const first = (s) => (s.tabs ?? []).map((c) => all.find((p) => p.tab === c.id && p.terminal)).find(Boolean)?.cwd ?? s.folder;
    return spaces().find((s) => (s.machine ?? null) === (on ?? null) && at(first(s))) ?? spaces().find((s) => s.active);
  }

  // After a refresh: learn the review checkouts, and clean up those whose PR was merged or closed
  // (checked with gh, as the list stops at LIMIT).
  async syncReviews(root, on, current, cx) {
    const base = await this.reviewBase(root, on), found = await this.reviewCheckouts(base, on);
    if (!current()) return;
    this.reviews = found;
    cx.notify();
    const open = new Set(this.prs.map((p) => p.number));
    for (const [n, path] of found) {
      if (open.has(n) || this.busy.has(n)) continue;
      const v = await this.gh(["pr", "view", String(n), "--json", "state"], root, on);
      const state = v.code === 0 ? JSON.parse(v.stdout).state : "OPEN";
      if (state === "OPEN" || !current()) continue;
      this.busy.set(n, "Cleaning up…");
      try { await this.finishReview(n, path, base, on, cx, state.toLowerCase()); }
      finally { this.busy.delete(n); cx.notify(); }
    }
  }

  // Review: a "PR #N" tab in the repo's space on the PR's head (`gh pr checkout`, forks too), with Claude
  // Code asked to review it; a tab already there is selected.
  async openReview(pr, root, on, cx) {
    const base = await this.reviewBase(root, on), branch = `pr-${pr.number}`, path = `${base.dir}/${branch}`;
    const shown = this.tabsAt(path, on)[0];
    if (shown) { run("space.select", { id: shown.space }); run("tab.select", { id: shown.tab }); return; }
    const space = this.repoSpace(base.main, on);
    if (!space) throw new Error("No space to open the review in.");

    if (!(await this.reviewCheckouts(base, on)).has(pr.number)) {
      const add = await exec("git", ["worktree", "add", "--detach", path], { cwd: base.main, on, timeout: 600000 });
      if (add.code !== 0) throw new Error(add.stderr.trim() || "git worktree add failed");
      const r = await this.gh(["pr", "checkout", String(pr.number), "--branch", branch, "--force"], path, on);
      if (r.code !== 0) {
        await exec("git", ["worktree", "remove", "--force", path], { cwd: base.main, on }).catch(() => null);
        throw new Error((r.stderr || r.stdout).trim() || "gh pr checkout failed");
      }
    }
    this.reviews.set(pr.number, path);

    // Herdr starts an `argv` through the login shell with an sh script, which fails when that's nu: so the
    // tab opens on its plain shell and Claude Code is typed into it, quoted for that shell.
    const before = new Set((space.tabs ?? []).map((c) => c.id));
    run("tab.new", { space: space.id, folder: path, name: `PR #${pr.number}` });
    const [tab, term] = await this.until(cx, () => {
      const tab = spaces().find((s) => s.id === space.id)?.tabs?.find((c) => !before.has(c.id));
      const t = tab && panes().find((p) => p.tab === tab.id && p.terminal)?.terminal;
      return t && terminals().find((x) => x.address === t && x.state === "live") ? [tab.id, t] : null;
    });
    run("space.select", { id: space.id });
    run("tab.select", { id: tab });
    const shell = terminals().find((x) => x.address === term)?.argv?.[0];
    await this.hc(["send", term, claudeLine(shell, REVIEW_PROMPT(pr))]);
  }

  // Done (or the PR closed): its tabs close, then the checkout and branch pr-<N> go. A checkout with
  // uncommitted changes stays as it is, with a toast.
  async finishReview(n, path, base, on, cx, closed = null) {
    const st = await exec("git", ["--no-optional-locks", "status", "--porcelain"], { cwd: path, on });
    if (st.code === 0 && st.stdout.trim()) {
      notify({ title: `Kept the review of #${n}`, body: `It has uncommitted changes: ${path}`, level: "warning" });
      return;
    }
    for (const { tab } of this.tabsAt(path, on)) run("tab.close", { id: tab, confirmed: true });
    await this.until(cx, () => this.tabsAt(path, on).length === 0, 5000).catch(() => null);
    const rm = await exec("git", ["worktree", "remove", "--force", path], { cwd: base.main, on });
    if (rm.code !== 0) throw new Error(rm.stderr.trim() || "git worktree remove failed");
    await exec("git", ["branch", "-D", `pr-${n}`], { cwd: base.main, on });
    this.reviews.delete(n);
    notify({ title: closed ? `#${n} was ${closed}: review cleaned up` : `Review of #${n} cleaned up`, level: "info" });
  }

  // Polls `find` until it gives something (a new tab's terminal shows up a little after tab.new).
  async until(cx, find, ms = 15000) {
    for (const end = Date.now() + ms; Date.now() < end; await cx.sleep(200)) {
      const found = find();
      if (found) return found;
    }
    throw new Error("The review tab didn't start in time.");
  }

  // hc from here (it reaches other machines' terminals by address), also when the app's PATH lacks it.
  async hc(args) {
    let last;
    for (const bin of ["hc", `${home()}/.local/bin/hc`]) {
      try {
        const r = await exec(bin, args);
        if (r.code !== 0) throw new Error((r.stderr || r.stdout).trim() || `hc ${args[0]} failed`);
        return r;
      } catch (e) { last = e; }
    }
    throw last;
  }

  // Review, or Open and Done once it has a checkout; the label of what it's doing while busy.
  reviewButtons(pr, t) {
    const busy = this.busy.get(pr.number), path = this.reviews.get(pr.number);
    const button = (id, label, onClick) => h_flex().id(`pr-${id}-${pr.number}`).flex_none().h(24).px(8).gap(5).items_center()
      .rounded(6).border_1().border_color(t.border).bg(t.background).text_size(12).text_color(t.muted)
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => { cx.stop_propagation(); onClick(cx); })
      .child(label);
    const open = (cx) => this.act(pr, "Opening…", cx, (root, on, cx) => this.openReview(pr, root, on, cx));
    const done = (cx) => this.act(pr, "Cleaning up…", cx, async (root, on, cx) =>
      this.finishReview(pr.number, path, await this.reviewBase(root, on), on, cx));
    return h_flex().flex_none().self_center().gap(4)
      .when(Boolean(busy), (e) => e.child(h_flex().h(24).px(8).gap(5).items_center().text_size(12).text_color(t.muted)
        .child(svg("mods/prs/spinner.svg").size(12).spin(900)).child(busy)))
      .when(!busy && !path, (e) => e.child(button("review", "Review", open)))
      .when(!busy && Boolean(path), (e) => e.child(button("open", "Open", open)).child(button("done", "Done", done)));
  }

  // A checks / CI state as a dot, pulsing while pending.
  dot(state, t) {
    return div().flex_none().size(8).rounded(4).bg({ success: t.ansi2, failure: t.blocked, pending: t.working, none: t.dim }[state])
      .when(state === "pending", (e) => e.loop("opacity", { from: 0.35, to: 1, period: 1400 }));
  }

  // The shown branch's newest commit: a line per workflow, opening its run.
  ciSection(t) {
    const ci = this.runs;
    return v_flex().flex_none().px(6).pt(4).pb(4).gap(1).border_b(1).border_color(t.border)
      .child(h_flex().h(20).px(10).gap(6).items_center().text_size(11).text_color(t.dim)
        .child(div().min_w(0).truncate().child(`CI · ${this.branch}`)).child(div().flex_none().child(ci.sha.slice(0, 7))))
      .children(ci.runs.map((r) => h_flex().id(`run-${r.databaseId}`).h(28).px(10).gap(10).items_center().rounded(7).cursor_pointer()
        .hover((s) => s.bg(t.hover)).on_click(() => exec("open", [r.url]).catch(() => null))
        .child(this.dot(r.state, t))
        .child(div().flex_1().min_w(0).truncate().child(r.workflowName))
        .child(div().flex_none().text_size(11).text_color(t.dim).child(`${r.event} · ${ago(r.updatedAt)}`))));
  }

  badge(text, color, t) {
    return div().flex_none().px(5).py(1).rounded(4).border_1().border_color(color === t.muted ? t.border : color + "66")
      .when(color !== t.muted, (e) => e.bg(color + "1a")).text_size(10).text_color(color).child(text);
  }

  row(pr, t) {
    const review = {
      APPROVED: ["Approved", t.ansi2],
      CHANGES_REQUESTED: ["Changes requested", t.ansi1],
      REVIEW_REQUIRED: ["Review required", t.muted],
    }[pr.reviewDecision];
    const author = (pr.author?.login ?? "ghost").replace(/^app\//, "");
    const sep = () => div().flex_none().child("·");
    return h_flex().id(`pr-${pr.number}`).flex_none().px(10).py(7).gap(10).items_start().rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_click((_e, _cx) => this.openPr(pr))
      .on_hover((on, cx) => {
        if (on) this.hovered = pr.number; else if (this.hovered === pr.number) this.hovered = null;
        cx.notify();
      })
      .child(this.dot(pr.checks, t).mt(5))
      .child(v_flex().flex_1().min_w(0).gap(3)
        .child(h_flex().min_w(0).gap(6).items_center()
          .child(div().flex_none().text_color(t.dim).child(`#${pr.number}`))
          .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(pr.title))
          .when(pr.isDraft, (e) => e.child(this.badge("Draft", t.muted, t)))
          .when(this.reviews.has(pr.number), (e) => e.child(this.badge("In review", t.ansi4, t)))
          .when(Boolean(review), (e) => e.child(this.badge(review[0], review[1], t))))
        .child(h_flex().min_w(0).gap(5).items_center().text_size(11).text_color(t.dim)
          .child(div().flex_none().text_color(t.muted).child(author))
          .child(sep())
          .child(div().min_w(0).truncate().child(pr.headRefName))
          .child(sep())
          .child(div().flex_none().child(ago(pr.updatedAt)))
          .child(div().flex_none().ml(2).text_color(t.ansi2).child(`+${pr.additions ?? 0}`))
          .child(div().flex_none().text_color(t.ansi1).child(`−${pr.deletions ?? 0}`))))
      .when(this.hovered === pr.number || this.busy.has(pr.number), (e) => e.child(this.reviewButtons(pr, t)));
  }

  setFilter(filter, cx) {
    this.filter = filter;
    try { localStorage.setItem("filter", filter); } catch {}
    cx.notify();
  }

  // One chip per review filter, with how many open PRs it holds.
  filters(t) {
    return h_flex().flex_1().min_w(0).flex_wrap().gap(4).children(FILTERS.map(([k, label]) => {
      const on = this.filter === k, n = this.prs.filter((pr) => matches(pr, k)).length;
      return h_flex().id(`prs-filter-${k}`).flex_none().h(26).px(8).gap(5).items_center().rounded(6).cursor_pointer()
        .text_size(12).bg(on ? t.selected : t.background).text_color(on ? t.foreground : t.muted)
        .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.setFilter(k, cx))
        .child(label).child(div().text_size(11).text_color(t.dim).child(String(n)));
    }));
  }

  empty(t) {
    let title, hint;
    if (this.state === "ok" && this.prs.length) [title, hint] = ["No matching pull requests", null];
    else if (this.state === "ok") [title, hint] = ["No open pull requests", null];
    else if (!this.state) [title, hint] = ["Loading pull requests…", null];
    else [title, hint] = EMPTY[this.state];
    if (!hint && this.state !== "ok") hint = this.detail;
    return v_flex().flex_1().min_h(0).items_center().justify_center().gap(6).p(24)
      .child(svg("mods/prs/pr.svg").size(28).text_color(t.dim))
      .child(div().text_color(t.muted).font_semibold().child(title))
      .when(Boolean(hint), (e) => e.child(div().max_w(420).text_size(12).text_color(t.dim).text_center().child(hint)));
  }

  // Drawn like the tab bar's Files / Changes buttons, on its chrome and bottom border.
  // Lit while the shown tab has a PR pane; a click closes it, else splits the tab's focused pane.
  // A dot after the label: the CI of the shown branch's newest commit.
  button(t, cx) {
    const { cwd, on, branch } = location(), top = cwd && this.tops.get(`${on ?? ""}|${cwd}`);
    const shownAt = cwd && branch ? `${on ?? ""}|${cwd}|${branch}` : null;
    if (shownAt && !this.asked.has(shownAt)) { this.asked.add(shownAt); this.watch(cx); }
    const ci = top && branch ? this.ci.get(ciKey(on, top, branch)) : null;
    const tab = spaces().find((s) => s.active)?.tabs?.find((x) => x.active)?.id;
    const inTab = panes().filter((p) => p.tab === tab);
    const open = inTab.find((p) => p.mod === "prs");
    const toggle = () => {
      if (open) return run("pane.close", { pane: open.pane });
      const at = inTab.find((p) => p.focused) ?? inTab[0];
      if (at) run("pane.split", { direction: "right", pane: at.pane, mod: "prs" });
    };
    return h_flex().size_full().pr(10).justify_end().items_center().bg(t.chrome).border_b(1).border_color(t.border)
      .child(h_flex().id("prs-open").h(26).px(8).gap(5).flex_none().items_center().rounded(6)
        .text_size(12).bg(open ? t.selected : t.chrome).text_color(open ? t.foreground : t.muted).hover((s) => s.bg(t.hover))
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(toggle)
        .child(svg("mods/prs/pr.svg").size(14)).child("PRs")
        .when(Boolean(ci) && ci.state !== "none", (e) => e.child(this.dot(ci.state, t).size(6))));
  }

  render(cx) {
    if (props()?.button) return this.button(theme(), cx);
    if (key() !== this.context) this.refresh(cx, false);
    const t = theme(), any = this.state === "ok" && this.prs.length > 0;
    const shown = any ? this.prs.filter((pr) => matches(pr, this.filter)) : [], list = shown.length > 0;
    // The pane header already names it: above the list sit only the review filters and the refresh button.
    return v_flex().id("prs").size_full().min_h(0).overflow_hidden().bg(t.background)
      .text_color(t.foreground).text_size(13)
      .child(h_flex().flex_none().pt(6).px(8).gap(6).items_start().justify_end()
        .when(any, (e) => e.child(this.filters(t)))
        .child(div().id("prs-refresh").flex_none().size(26).flex().items_center().justify_center().rounded(6).cursor_pointer()
          .text_color(t.muted).hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_click((_e, cx) => this.refresh(cx))
          .child(this.loading ? svg("mods/prs/spinner.svg").size(14).spin(900) : svg("mods/prs/refresh.svg").size(14))))
      .when(Boolean(this.runs?.runs.length), (e) => e.child(this.ciSection(t)))
      .when(!list, (e) => e.child(this.empty(t)))
      // overflow_y_scroll() sits absolutely inside a flex child, so the list's height comes from the pane.
      .when(list, (e) => e.child(div().flex_1().min_h(0).relative()
        .child(v_flex().id("prs-list").absolute().inset_0().overflow_y_scroll().p(6).gap(1)
          .children(shown.map((pr) => this.row(pr, t))))
        .child(Scrollbar.vertical("prs-list").absolute().inset_0())));
  }
}
