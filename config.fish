set -gx SHELL (which fish)

# PATHS
set -gx PATH /opt/homebrew/bin
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

# asdf
set -gx ASDF_DIR (brew --prefix asdf)/libexec
source $ASDF_DIR/asdf.fish

for file in $fisher_path/conf.d/*.fish
    builtin source $file 2>/dev/null
end

# Homebrew
# If the HOMEBREW_PREFIX is not set, set it to the default
if test -z "$HOMEBREW_PREFIX"
    set -gx HOMEBREW_PREFIX (brew config | rg HOMEBREW_PREFIX |  awk '{ print $2 }')
end

# Go
set -gx GOPATH $HOME/dev

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
alias cat "bat --plain --paging never"

# eza
alias ls eza

# zoxide
zoxide init fish | source
set -gx _ZO_FZF_OPTS "--height 100% --layout=reverse --preview='l {2..}'"

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Self installed binaries
set -gx SELF_INSTALLED_RUST_TOOLS \
    bat \
    pastel \
    procs \
    git-delta \
    ripgrep \
    fd-find \
    skim

set -gx COLORTERM truecolor

# gh open with browser
set -gx GH_BROWSER open

set -gx DENO_INSTALL $HOME/.deno
set -gx PATH $PATH $DENO_INSTALL/bin

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/fish/__tabtab.fish ]; and . ~/.config/tabtab/fish/__tabtab.fish; or true
