// Pull requests: the open GitHub PRs of the shown space's repository (`gh pr list`).
// Opens as a popup (`mod.open:prs`) or as a pane (`pane.split {direction, mod: "prs"}`).
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, Scrollbar } from "gpui-base";
import { spaces, panes, focused, exec, home, theme, props, closeOverlay } from "herdr";

// Where the shown space is now: the focused pane's folder, on its machine (as mods/changes does).
function location() {
  const space = spaces().find((s) => s.active), f = focused();
  let pane = f?.pane ? panes().find(p => p.pane === f.pane) : null;
  // A mod pane (this panel split beside a shell) has no folder: use its tab's first terminal.
  if (pane && !pane.terminal) pane = panes().find(p => p.tab === pane.tab && p.terminal && p.cwd) ?? pane;
  const on = f?.pane === null ? (f.terminal?.includes("/") ? f.terminal.split("/")[0] : null) : space?.machine ?? null;
  return { cwd: pane?.cwd || f?.cwd || space?.folder, on };
}
const key = () => JSON.stringify(location());

const LIMIT = 50;
const ROW_H = 58;
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

// Turns gh's failure into something the panel can explain.
function failure(text) {
  if (/auth login|not logged in|authenticat|HTTP 401|bad credentials/i.test(text)) return "auth";
  if (/no git remotes|none of the git remotes|not a github|could not determine/i.test(text)) return "noremote";
  return "error";
}

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
    this.prs = []; this.state = null; this.detail = null; this.root = null; this.gen = 0; this.ghBin = {};
    this.refresh(cx);
    cx.timer.every(60000, (cx) => this.refresh(cx));
  }

  // From render, `notify` is false: render already draws the new state and may not notify.
  refresh(cx, notify = true) {
    const { cwd, on } = location(), context = key();
    if (context !== this.context) {
      this.context = context; this.prs = []; this.state = null; this.detail = null; this.root = null; this.loading = false;
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

  openPr(pr) {
    exec("open", [pr.url]).catch(() => null);
    const overlay = props()?.overlay;
    if (overlay) closeOverlay(overlay);
  }

  badge(text, color, t) {
    return div().flex_none().px(5).py(1).rounded(4).border_1().border_color(color === t.muted ? t.border : color + "66")
      .when(color !== t.muted, (e) => e.bg(color + "1a")).text_size(10).text_color(color).child(text);
  }

  row(pr, t) {
    const dot = { success: t.ansi2, failure: t.blocked, pending: t.working, none: t.dim }[pr.checks];
    const review = {
      APPROVED: ["Approved", t.ansi2],
      CHANGES_REQUESTED: ["Changes requested", t.ansi1],
      REVIEW_REQUIRED: ["Review required", t.muted],
    }[pr.reviewDecision];
    const author = (pr.author?.login ?? "ghost").replace(/^app\//, "");
    const sep = () => div().flex_none().child("·");
    return h_flex().id(`pr-${pr.number}`).flex_none().px(10).py(7).gap(10).items_start().rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_click((_e, _cx) => this.openPr(pr))
      .child(div().flex_none().mt(5).size(8).rounded(4).bg(dot)
        .when(pr.checks === "pending", (e) => e.loop("opacity", { from: 0.35, to: 1, period: 1400 })))
      .child(v_flex().flex_1().min_w(0).gap(3)
        .child(h_flex().min_w(0).gap(6).items_center()
          .child(div().flex_none().text_color(t.dim).child(`#${pr.number}`))
          .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(pr.title))
          .when(pr.isDraft, (e) => e.child(this.badge("Draft", t.muted, t)))
          .when(Boolean(review), (e) => e.child(this.badge(review[0], review[1], t))))
        .child(h_flex().min_w(0).gap(5).items_center().text_size(11).text_color(t.dim)
          .child(div().flex_none().text_color(t.muted).child(author))
          .child(sep())
          .child(div().min_w(0).truncate().child(pr.headRefName))
          .child(sep())
          .child(div().flex_none().child(ago(pr.updatedAt)))
          .child(div().flex_none().ml(2).text_color(t.ansi2).child(`+${pr.additions ?? 0}`))
          .child(div().flex_none().text_color(t.ansi1).child(`−${pr.deletions ?? 0}`))));
  }

  empty(t) {
    let title, hint;
    if (this.state === "ok") [title, hint] = ["No open pull requests", null];
    else if (!this.state) [title, hint] = ["Loading pull requests…", null];
    else [title, hint] = EMPTY[this.state];
    if (!hint && this.state !== "ok") hint = this.detail;
    return v_flex().flex_1().min_h(0).items_center().justify_center().gap(6).p(24)
      .child(svg("mods/prs/pr.svg").size(28).text_color(t.dim))
      .child(div().text_color(t.muted).font_semibold().child(title))
      .when(Boolean(hint), (e) => e.child(div().max_w(420).text_size(12).text_color(t.dim).text_center().child(hint)));
  }

  render(cx) {
    if (key() !== this.context) this.refresh(cx, false);
    const t = theme(), overlay = props()?.overlay, list = this.state === "ok" && this.prs.length > 0;
    const repo = this.root ? this.root.split("/").pop() : "";
    const count = this.state === "ok" ? (this.prs.length >= LIMIT ? `${LIMIT}+` : String(this.prs.length)) : "–";
    return v_flex().id("prs").size_full().min_h(0).overflow_hidden().bg(overlay ? t.popover : t.background)
      .text_color(t.foreground).text_size(13)
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .child(div().flex_none().font_semibold().child("Pull requests"))
        .child(div().flex_none().px(5).py(1).rounded(4).border_1().border_color(t.border).text_size(10).text_color(t.muted).child(count))
        .child(div().flex_1().min_w(0).truncate().text_size(11).text_color(t.dim).child(repo))
        .child(div().id("prs-refresh").flex_none().size(26).flex().items_center().justify_center().rounded(6).cursor_pointer()
          .text_color(t.muted).hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_click((_e, cx) => this.refresh(cx))
          .child(this.loading ? svg("mods/prs/spinner.svg").size(14).spin(900) : svg("mods/prs/refresh.svg").size(14))))
      .when(!list, (e) => e.child(this.empty(t)))
      // overflow_y_scroll() sits absolutely inside a flex child, so the list's height comes from the panel.
      // A popup sizes to its content and absolute children add nothing, so there the list gets a height
      // of its own (about 58px a row, as mods/picker does), capped so long lists scroll.
      .when(list, (e) => e.child(div().flex_1().min_h(0).relative()
        .when(Boolean(overlay), (el) => el.flex_none().h(Math.min(ROW_H * 10, this.prs.length * ROW_H + 12)))
        .child(v_flex().id("prs-list").absolute().inset_0().overflow_y_scroll().p(6).gap(1)
          .children(this.prs.map((pr) => this.row(pr, t))))
        .child(Scrollbar.vertical("prs-list").absolute().inset_0())));
  }
}
