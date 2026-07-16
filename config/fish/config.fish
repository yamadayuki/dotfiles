# PATHS
set -gx PATH $PATH /opt/homebrew/bin
set -gx PATH $PATH /opt/homebrew/sbin
set -gx PATH $PATH $HOME/.cargo/bin
set -gx PATH $PATH $HOME/dev/bin
set -gx PATH $PATH $HOME/.anyenv/bin
set -gx PATH $PATH /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/
set -gx PATH $PATH /usr/local/bin
set -gx PATH $PATH /usr/bin
set -gx PATH $PATH /bin
set -gx PATH $PATH /usr/sbin
set -gx PATH $PATH /sbin
set -gx PATH $PATH $HOME/google-cloud-sdk/bin
set -gx PATH $PATH $HOME/.local/bin

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
set -gx PATH $PATH $HOME/.docker/bin

# Python (rye)
set -gx PATH $PATH $HOME/.rye/shims

alias vi vim
set -gx EDITOR vim

# direnv
# eval (direnv hook fish)
function __direnv_export_eval --on-event fish_prompt
    # Run on each prompt to update the state
    direnv export fish | source

    # Handle cd history arrows between now and the next prompt
    function __direnv_cd_hook --on-variable PWD
        # ensure any output overwrites the prompt instead of going after it
        echo -ne '\r'
        # run the outer function to apply any changes
        __direnv_export_eval
    end

    function __direnv_disable_cd --on-event fish_preexec
        # Once we're running commands, stop monitoring cd changes
        # until we get to the prompt again
        functions --erase __direnv_cd_hook
    end
end

# hub command config
source (hub alias -s|psub)

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
set -gx PATH $PATH $DENO_INSTALL/bin

# mise
~/.local/bin/mise activate fish | source

# starship
starship init fish | source

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end


# Added by Antigravity CLI installer
set -gx PATH "$HOME/.local/bin" $PATH

# Added by Antigravity IDE
set -gx PATH "$HOME/.antigravity-ide/antigravity-ide/bin" $PATH

# Vite+
set -gx PATH $PATH "$HOME/.vite-plus/bin"
