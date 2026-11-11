// Run: the shown space's mise tasks, each started in a pane below with a click, and the TCP ports that
// processes working in its repository listen on. Shown as a pane (`pane.split {direction, mod: "tasks"}`).
// With `props: {button: true}` (the main-prs layout's tab bar) it's the Run button that opens or closes
// that pane, split to the right in the shown tab.
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, Scrollbar } from "gpui-base";
import { spaces, panes, terminals, focused, exec, home, theme, props, run, notify } from "herdr";

// Where the shown space is now: the focused pane's folder, on its machine (as mods/prs does).
function location() {
  const space = spaces().find((s) => s.active), f = focused();
  let pane = f?.pane ? panes().find((p) => p.pane === f.pane) : null;
  if (pane && !pane.terminal) pane = panes().find((p) => p.tab === pane.tab && p.terminal && p.cwd) ?? pane;
  const on = f?.pane === null ? (f.terminal?.includes("/") ? f.terminal.split("/")[0] : null) : space?.machine ?? null;
  return { cwd: pane?.cwd || f?.cwd || space?.folder, on };
}
const key = () => JSON.stringify(location());
const under = (path) => (at) => at === path || Boolean(at?.startsWith(`${path}/`));

// Where mise may live when the app's PATH lacks it; the first that starts is kept.
const MISE_PLACES = (on) => [
  "mise",
  ...(on ? [] : [`${home()}/.local/bin/mise`, `${home()}/.local/share/mise/bin/mise`]),
  "/opt/homebrew/bin/mise", "/usr/local/bin/mise",
];
const PORTS_EVERY = 5000;
const TASKS_EVERY = 60000;

// argv as one line for that shell: plain words as they are, others quoted (nu raw strings, else single quotes).
function shellLine(shell, argv) {
  const name = (shell ?? "").split("/").pop();
  const word = (w) => {
    if (/^[A-Za-z0-9_.:\/-]+$/.test(w)) return w;
    if (name === "nu") {
      let h = "#";
      while (w.includes(`'${h}`)) h += "#";
      return `r${h}'${w}'${h}`;
    }
    if (name === "fish") return `'${w.replace(/[\\']/g, "\\$&")}'`;
    return `'${w.replace(/'/g, "'\\''")}'`;
  };
  return argv.map(word).join(" ");
}

// The processes listening on TCP there, with their ports and working folders (`lsof`, macOS and Linux).
async function listening(on) {
  const r = await exec("lsof", ["-nP", "-iTCP", "-sTCP:LISTEN", "-Fpcn"], { on });
  const procs = new Map();
  let cur = null;
  for (const line of r.stdout.split("\n")) {
    const v = line.slice(1);
    if (line[0] === "p") procs.set(Number(v), (cur = { pid: Number(v), command: "", ports: new Set(), cwd: null }));
    else if (line[0] === "c" && cur) cur.command = v;
    else if (line[0] === "n" && cur) {
      const m = v.match(/:(\d+)$/);
      if (m) cur.ports.add(Number(m[1]));
    }
  }
  if (!procs.size) return [];
  const c = await exec("lsof", ["-a", "-d", "cwd", "-p", [...procs.keys()].join(","), "-Fpn"], { on });
  let pid = null;
  for (const line of c.stdout.split("\n")) {
    if (line[0] === "p") pid = Number(line.slice(1));
    else if (line[0] === "n" && procs.has(pid)) procs.get(pid).cwd = line.slice(1);
  }
  return [...procs.values()].map((p) => ({ ...p, ports: [...p.ports].sort((a, b) => a - b) }));
}

const EMPTY = {
  nofolder: "This space has no folder to look in.",
  nomise: "mise not found: install it or put it on PATH, then refresh.",
  error: "Couldn't list the tasks.",
};

export default class Tasks extends View {
  init(_props, cx) {
    if (props()?.button) return;
    // tasks: mise's tasks here (null until listed); ports: processes listening from the repo; busy: task or pid → label.
    this.tasks = null; this.state = null; this.detail = null; this.root = null; this.ports = [];
    this.miseBin = {}; this.busy = new Map(); this.hovered = null; this.gen = 0;
    this.refresh(cx);
    cx.timer.every(TASKS_EVERY, (cx) => this.refresh(cx));
    cx.timer.every(PORTS_EVERY, (cx) => this.refreshPorts(cx));
  }

  // From render, `notify` is false: render already draws the new state and may not notify.
  refresh(cx, notify = true) {
    const { cwd, on } = location(), context = key();
    if (context !== this.context) {
      this.context = context; this.tasks = null; this.state = null; this.detail = null; this.root = null;
      this.ports = []; this.loading = false;
    }
    if (this.loading) return;
    if (!cwd) { this.state = "nofolder"; if (notify) cx.notify(); return; }
    const gen = ++this.gen, current = () => gen === this.gen && key() === context;
    this.loading = true;
    if (notify) cx.notify();
    cx.spawn(async (cx) => {
      try {
        const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd, on });
        if (!current()) return;
        this.root = top.code === 0 ? top.stdout.trim() : cwd;
        let r;
        try { r = await this.mise(["tasks", "ls", "--json"], cwd, on); }
        catch { if (current()) { this.tasks = []; this.state = "nomise"; } return; }
        if (!current()) return;
        if (r.code !== 0) { this.tasks = []; this.state = "error"; this.detail = (r.stderr || r.stdout).trim().split("\n")[0]; return; }
        this.tasks = JSON.parse(r.stdout || "[]").filter((t) => !t.hide)
          .sort((a, b) => Number(a.global) - Number(b.global) || a.name.localeCompare(b.name));
        this.state = "ok"; this.detail = null;
      } catch (e) {
        if (current()) { this.tasks = []; this.state = "error"; this.detail = String(e?.message ?? e); }
      } finally {
        if (gen === this.gen) this.loading = false;
        cx.notify();
      }
    });
    this.refreshPorts(cx);
  }

  // The ports of processes working in the repo (or the folder, outside git). This machine's only:
  // a port elsewhere wouldn't open here.
  refreshPorts(cx) {
    const { on } = location(), root = this.root;
    if (on || !root || this.portsLoading) return;
    this.portsLoading = true;
    cx.spawn(async (cx) => {
      try {
        const at = under(root), found = (await listening(null)).filter((p) => at(p.cwd));
        if (this.root === root) this.ports = found;
      } catch (e) { console.log(`tasks: ports: ${e}`); }
      finally { this.portsLoading = false; cx.notify(); }
    });
  }

  // Runs mise on that machine, trying the usual places when it's not on PATH.
  async mise(args, cwd, on) {
    const known = this.miseBin[on ?? ""];
    let last;
    for (const bin of [...new Set([known, ...MISE_PLACES(on)].filter(Boolean))]) {
      try {
        const r = await exec(bin, args, { cwd, on });
        this.miseBin[on ?? ""] = bin;
        return r;
      } catch (e) { last = e; }
    }
    throw last;
  }

  // A task runs in a new pane below a terminal of the shown tab, typed into its shell: Herdr starts an
  // `argv` through the login shell with an sh script, which fails when that's nu.
  runTask(task, cx) {
    const tab = spaces().find((s) => s.active)?.tabs?.find((x) => x.active)?.id;
    const inTab = panes().filter((p) => p.tab === tab);
    const at = inTab.find((p) => p.focused && p.terminal) ?? inTab.find((p) => p.terminal);
    if (!at || this.busy.has(task.name)) return;
    const before = new Set(inTab.map((p) => p.pane));
    this.busy.set(task.name, "Starting…");
    cx.notify();
    run("pane.split", { direction: "down", pane: at.pane });
    cx.spawn(async (cx) => {
      try {
        const term = await this.until(cx, () => {
          const p = panes().find((x) => x.tab === tab && x.terminal && !before.has(x.pane));
          return p && terminals().find((x) => x.address === p.terminal && x.state === "live") ? p.terminal : null;
        });
        const shell = terminals().find((x) => x.address === term)?.argv?.[0];
        await this.hc(["send", term, shellLine(shell, ["mise", "run", task.name])]);
      } catch (e) {
        notify({ title: `Couldn't run ${task.name}`, body: String(e?.message ?? e).split("\n")[0], level: "error" });
      } finally { this.busy.delete(task.name); cx.notify(); }
    });
  }

  // Stops a listening process (SIGTERM), then looks again.
  stop(proc, cx) {
    const k = `pid-${proc.pid}`;
    if (this.busy.has(k)) return;
    this.busy.set(k, "Stopping…");
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const r = await exec("kill", [String(proc.pid)]);
        if (r.code !== 0) throw new Error(r.stderr.trim() || "kill failed");
        await cx.sleep(500);
      } catch (e) {
        notify({ title: `Couldn't stop ${proc.command} (${proc.pid})`, body: String(e?.message ?? e), level: "error" });
      } finally { this.busy.delete(k); this.refreshPorts(cx); cx.notify(); }
    });
  }

  // Polls `find` until it gives something (a split's terminal shows up a little after pane.split).
  async until(cx, find, ms = 15000) {
    for (const end = Date.now() + ms; Date.now() < end; await cx.sleep(200)) {
      const found = find();
      if (found) return found;
    }
    throw new Error("The pane didn't start in time.");
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

  hover(id) {
    return (on, cx) => {
      if (on) this.hovered = id; else if (this.hovered === id) this.hovered = null;
      cx.notify();
    };
  }

  heading(text, t) {
    return div().h(24).px(10).flex().items_center().text_size(11).font_semibold().text_color(t.dim).child(text);
  }

  note(text, t) {
    return div().px(10).py(4).text_size(12).text_color(t.dim).child(text);
  }

  taskRow(task, t) {
    const busy = this.busy.get(task.name), id = `task-${task.name}`;
    return h_flex().id(id).flex_none().px(10).py(6).gap(10).items_center().rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_hover(this.hover(id)).on_click((_e, cx) => this.runTask(task, cx))
      .child(svg("mods/tasks/run.svg").size(12).flex_none().text_color(this.hovered === id ? t.foreground : t.dim))
      .child(v_flex().flex_1().min_w(0).gap(2)
        .child(h_flex().min_w(0).gap(6).items_center()
          .child(div().min_w(0).truncate().text_color(t.foreground).child(task.name))
          .when(Boolean(task.global), (e) => e.child(div().flex_none().px(5).py(1).rounded(4).border_1().border_color(t.border)
            .text_size(10).text_color(t.muted).child("global"))))
        .when(Boolean(task.description), (e) => e.child(div().min_w(0).truncate().text_size(11).text_color(t.dim).child(task.description))))
      .when(Boolean(busy), (e) => e.child(h_flex().flex_none().gap(5).items_center().text_size(12).text_color(t.muted)
        .child(svg("mods/prs/spinner.svg").size(12).spin(900)).child(busy)));
  }

  portRow(proc, t) {
    const id = `port-${proc.pid}`, busy = this.busy.get(`pid-${proc.pid}`);
    const open = (port) => exec("open", [`http://localhost:${port}`]).catch(() => null);
    return h_flex().id(id).flex_none().px(10).py(6).gap(10).items_center().rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_hover(this.hover(id)).on_click(() => open(proc.ports[0]))
      .child(div().flex_none().size(8).rounded(4).bg(t.ansi2))
      .child(h_flex().flex_1().min_w(0).gap(6).items_center()
        .children(proc.ports.map((port) => div().id(`${id}-${port}`).flex_none().text_color(t.foreground)
          .hover((s) => s.text_color(t.ansi4)).on_click((_e, cx) => { cx.stop_propagation(); open(port); }).child(`:${port}`)))
        .child(div().min_w(0).truncate().text_size(11).text_color(t.dim).child(`${proc.command} · ${proc.pid}`)))
      .when(Boolean(busy), (e) => e.child(div().flex_none().text_size(12).text_color(t.muted).child(busy)))
      .when(!busy && this.hovered === id, (e) => e.child(h_flex().id(`${id}-stop`).flex_none().h(24).px(8).items_center().rounded(6)
        .border_1().border_color(t.border).bg(t.background).text_size(12).text_color(t.muted)
        .hover((s) => s.bg(t.hover).text_color(t.foreground))
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click((_e, cx) => { cx.stop_propagation(); this.stop(proc, cx); })
        .child("Stop")));
  }

  // Drawn like the tab bar's Files / Changes buttons. Lit while the shown tab has a Run pane; a click
  // closes it, else splits the tab's focused pane.
  button(t) {
    const tab = spaces().find((s) => s.active)?.tabs?.find((x) => x.active)?.id;
    const inTab = panes().filter((p) => p.tab === tab);
    const open = inTab.find((p) => p.mod === "tasks");
    const toggle = () => {
      if (open) return run("pane.close", { pane: open.pane });
      const at = inTab.find((p) => p.focused) ?? inTab[0];
      if (at) run("pane.split", { direction: "right", pane: at.pane, mod: "tasks" });
    };
    return h_flex().size_full().pr(10).justify_end().items_center().bg(t.chrome).border_b(1).border_color(t.border)
      .child(h_flex().id("tasks-open").h(26).px(8).gap(5).flex_none().items_center().rounded(6)
        .text_size(12).bg(open ? t.selected : t.chrome).text_color(open ? t.foreground : t.muted).hover((s) => s.bg(t.hover))
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(toggle)
        .child(svg("mods/tasks/run.svg").size(14)).child("Run"));
  }

  render(cx) {
    const t = theme();
    if (props()?.button) return this.button(t);
    if (key() !== this.context) this.refresh(cx, false);
    const tasks = this.tasks ?? [], local = !location().on;
    const taskNote = this.state === null ? "Loading tasks…" : this.state === "ok" ? (tasks.length ? null : "No mise tasks here.")
      : this.detail || EMPTY[this.state];
    // The pane header already names it: above the sections sits only the refresh button.
    return v_flex().id("tasks").size_full().min_h(0).overflow_hidden().bg(t.background).text_color(t.foreground).text_size(13)
      .child(h_flex().flex_none().pt(6).px(8).justify_end()
        .child(div().id("tasks-refresh").flex_none().size(26).flex().items_center().justify_center().rounded(6).cursor_pointer()
          .text_color(t.muted).hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_click((_e, cx) => this.refresh(cx))
          .child(this.loading ? svg("mods/prs/spinner.svg").size(14).spin(900) : svg("mods/prs/refresh.svg").size(14))))
      // overflow_y_scroll() sits absolutely inside a flex child, so the list's height comes from the pane.
      .child(div().flex_1().min_h(0).relative()
        .child(v_flex().id("tasks-list").absolute().inset_0().overflow_y_scroll().px(6).pb(6).gap(1)
          .child(this.heading("Tasks", t))
          .when(Boolean(taskNote), (e) => e.child(this.note(taskNote, t)))
          .children(tasks.map((task) => this.taskRow(task, t)))
          .child(div().h(8).flex_none())
          .child(this.heading("Ports", t))
          .when(!local, (e) => e.child(this.note("Ports are shown for this computer's spaces.", t)))
          .when(local && !this.ports.length, (e) => e.child(this.note("Nothing listening from this repository.", t)))
          .when(local, (e) => e.children(this.ports.map((proc) => this.portRow(proc, t)))))
        .child(Scrollbar.vertical("tasks-list").absolute().inset_0()));
  }
}
