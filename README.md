# dotfiles

### Installation

```
$ bash <(curl -sSL https://raw.githubusercontent.com/yamadayuki/dotfiles/master/up)
```

`up` installs Homebrew and mise (the only two things that must exist before mise
itself can take over), then runs `mise bootstrap` from the repo root (`mise.toml`).
That single command installs Homebrew packages (including fish), symlinks/copies
dotfiles, sets macOS defaults, and configures fish shell activation — all
idempotently, so re-running `up` at any time converges the machine back to the
declared state. There's no separate `install.fish` step anymore; everything that
doesn't need to exist before mise does is declared in `mise.toml`.

Fish plugins are no longer managed by `fisher` — the former `yamadayuki/lure`
fisher plugin (prompt colors, keybindings, and assorted utility functions) is
vendored directly under `config/fish/{functions,conf.d,completions}` and
symlinked file-by-file via `[dotfiles]`, so there's nothing left for a plugin
manager to do.

This allows:
- Global settings (`[settings]`, `[tasks]`) tracked in dotfiles and merged from
  `~/.config/mise/conf.d/00-dotfiles.toml`, available from any directory
- Tool-specific config (`[tools]`) managed by `mise use -g` at `~/.config/mise/config.toml`,
  not tracked in dotfiles
- Project-scoped bootstrap declarations (`[dotfiles]`, `[bootstrap.*]`) tracked in
  `mise.toml` at the repo root, applied via `mise bootstrap` when run from `~/dotfiles`

Unlike `/etc/mise`, `~/.config/mise/conf.d` is a normal user-owned directory, so mise
follows the symlink there directly — no sudo, no copy-on-write, no manual re-sync.

Check machine state at any time with:

```bash
mise bootstrap status   # aggregate status of all bootstrap parts
mise dotfiles status    # symlink/copy status for tracked dotfiles
```

See: https://mise.jdx.dev/bootstrap.html and https://mise.jdx.dev/dotfiles.html

#### Migrating an existing machine set up before mise bootstrap

Machines that ran an older version of this repo may still have `fisher` and its
managed files (`yamadayuki/lure`), and/or a sudo-copied `/etc/mise/config.toml`
lying around (both superseded — `fisher` by `[dotfiles]` in `mise.toml`, `/etc/mise`
by `~/.config/mise/conf.d/00-dotfiles.toml`). `mise bootstrap`'s dotfiles step
refuses to symlink over `fisher`'s unmanaged real files, so run this **before**
`mise bootstrap`:

```bash
mise run migrate-legacy-setup
```

This is a one-time, idempotent task (each part no-ops if there's nothing to
migrate) and asks for sudo to remove `/etc/mise/config.toml` if present. Once
every machine you use has run it, this task and its README section can be
deleted.

### Profiling

```
$ fish --profile-startup /tmp/fish.profile -i -c exit
$ sort -nk2 /tmp/fish.profile
```
