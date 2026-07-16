# dotfiles

### What's managed

Everything is declared in `mise.toml` (`[dotfiles]` for symlinks, `[bootstrap.*]`
for packages, macOS defaults, and the login shell):

- **fish** — `config.fish` plus `functions`/`conf.d`/`completions` symlinked
  file-by-file (includes the vendored former `yamadayuki/lure` prompt)
- **git** — `~/.gitconfig` and the global ignore file
- **Vim / Neovim** — a single shared `vimrc` (native features only, no plugin
  manager; netrw configured as a NERDTree-like toggleable sidebar) with a
  GitHub Dark colorscheme matched to Ghostty. Neovim's `init.vim` extends
  `runtimepath` with `~/.vim` and sources the same `vimrc`; `has('nvim')`
  branches handle the few differences
- **Ghostty** — terminal config (GitHub Dark + transparency)
- **hunk** — theme matched to Ghostty's GitHub Dark
- **herdr** — terminal-multiplexer config (prefix moved off `ctrl+w` so it
  doesn't shadow Vim's window commands)
- **mise** — global `[settings]`/`[tasks]` (e.g. `mise run up` to upgrade
  Homebrew/mise/rustup), merged via `~/.config/mise/conf.d/00-dotfiles.toml`

CLI tools (fish, Neovim, hunk, ripgrep, fzf, starship, …) are installed as
`brew:` packages through `[bootstrap.packages]`.

### Installation

```
$ bash <(curl -sSL https://raw.githubusercontent.com/yamadayuki/dotfiles/master/up)
```

`up` installs Homebrew and mise (the only two things that must exist before mise
itself can take over), then runs `mise bootstrap` from the repo root (`mise.toml`).
That single command installs Homebrew packages (including fish), symlinks/copies
dotfiles, sets macOS defaults, and configures fish shell activation — all
idempotently, so re-running `up` at any time converges the machine back to the
declared state.

The mise config is split into three layers:
- Global settings (`[settings]`, `[tasks]`) tracked in dotfiles and merged from
  `~/.config/mise/conf.d/00-dotfiles.toml`, available from any directory
- Tool-specific config (`[tools]`) managed by `mise use -g` at `~/.config/mise/config.toml`,
  not tracked in dotfiles
- Project-scoped bootstrap declarations (`[dotfiles]`, `[bootstrap.*]`) tracked in
  `mise.toml` at the repo root, applied via `mise bootstrap` when run from `~/dotfiles`

Check machine state at any time with:

```bash
mise bootstrap status   # aggregate status of all bootstrap parts
mise dotfiles status    # symlink/copy status for tracked dotfiles
```

See: https://mise.jdx.dev/bootstrap.html and https://mise.jdx.dev/dotfiles.html

### Profiling

```
$ fish --profile-startup /tmp/fish.profile -i -c exit
$ sort -nk2 /tmp/fish.profile
```
