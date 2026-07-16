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

#### Migrating an existing machine from the old `/etc/mise` setup

Machines that ran an older version of `install.fish` may still have a sudo-copied
`/etc/mise/config.toml` lying around. It's harmless (its content is superseded by
`~/.config/mise/conf.d/00-dotfiles.toml`), but it can be removed with:

```bash
mise run migrate-etc-mise-config
```

This is a one-time, idempotent task (a no-op if `/etc/mise/config.toml` doesn't
exist) and asks for sudo to remove the file.

#### Migrating an existing machine off `fisher`

Machines that ran an older version of this repo may still have `fisher` and its
managed files (`yamadayuki/lure`) installed. `mise bootstrap`'s dotfiles step
refuses to symlink over those unmanaged real files, so run this **before**
`mise bootstrap`:

```bash
mise run migrate-remove-fisher
```

This removes the `fisher` plugin manager and its `yamadayuki/lure` install so
the vendored copies under `config/fish/` can take their place.

### Profiling

```
$ fish --profile-startup /tmp/fish.profile -i -c exit
$ sort -nk2 /tmp/fish.profile
```
