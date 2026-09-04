# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/yamadayuki/.docker/bin"
# End of Docker Desktop section.

# PATHS
# Homebrew must come before system paths (/usr/bin etc.) so brewed tools win.
fish_add_path --global --move --prepend /opt/homebrew/bin /opt/homebrew/sbin
# Do NOT fish_add_path system dirs (/usr/local/bin, /usr/bin, /bin, /usr/sbin, /sbin):
# they're already on PATH via macOS's launchd/path_helper. Adding them to
# fish_user_paths makes fish re-prepend them ahead of mise (and other tools)
# every time something later in this file calls fish_add_path again — e.g. the
# pnpm/antigravity/moonbit blocks below, which installers keep appending — which
# is exactly how a stale system `gem`/`ruby` ends up shadowing mise's shims.
fish_add_path --global --append \
    $HOME/.cargo/bin \
    $HOME/dev/bin \
    $HOME/.anyenv/bin \
    /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/ \
    $HOME/google-cloud-sdk/bin \
    $HOME/.local/bin

set -gx SHELL (which fish)

# Homebrew
# If the HOMEBREW_PREFIX is not set, set it based on the well-known install path
# (avoids shelling out to `brew config` on every new shell).
if test -z "$HOMEBREW_PREFIX"
    if test -d /opt/homebrew
        set -gx HOMEBREW_PREFIX /opt/homebrew
    else
        set -gx HOMEBREW_PREFIX /usr/local
    end
end

# Go
set -gx GOPATH $HOME/dev

# Docker
fish_add_path --global --append $HOME/.docker/bin

# Python (rye)
fish_add_path --global --append $HOME/.rye/shims

alias vi vim
set -gx EDITOR vim

# anyenv
# source (anyenv init -|psub)

# fzf
set -gx FZF_DEFAULT_OPTS --height 100% --layout=reverse

# skim
set -gx SKIM_DEFAULT_OPTIONS --ansi --layout=reverse --height 40%

# bat
set -gx BAT_THEME base16
alias cat "bat --plain --paging never"

# eza
alias ls eza

# zoxide
zoxide init fish | source
# `z`'s `--wraps=__zoxide_z` pre-registers a completion at startup, which
# blocks fish's normal completions/z.fish autoload, so source it explicitly.
# (This must run after `zoxide init`, and conf.d loads before config.fish,
# so this completion can't just live in conf.d/ either — it has to be
# sourced here, in this exact position.)
source $__fish_config_dir/completions/z.fish
set -gx _ZO_FZF_OPTS "--height 100% --layout=reverse --preview='l {2..}'"

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

set -gx COLORTERM truecolor

# gh open with browser
set -gx GH_BROWSER open

set -gx DENO_INSTALL $HOME/.deno
fish_add_path --global --append $DENO_INSTALL/bin

# mise
~/.local/bin/mise activate fish | source

# starship
starship init fish | source

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
fish_add_path --global --move "$PNPM_HOME"
# pnpm end


# Added by Antigravity CLI installer
fish_add_path --global --move "$HOME/.local/bin"

# Added by Antigravity IDE
fish_add_path --global --move "$HOME/.antigravity-ide/antigravity-ide/bin"

# Vite+
fish_add_path --global --append "$HOME/.vite-plus/bin"

# moonbit
fish_add_path --global "$HOME/.moon/bin"

# moonbit
fish_add_path "$HOME/.moon/bin"
