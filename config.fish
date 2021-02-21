set -gx SHELL (which fish)

# PATHS
set -gx PATH /opt/homebrew/bin
set -gx PATH $PATH /Users/yamadayuki/.cargo/bin
set -gx PATH $PATH /Users/yamadayuki/dev/bin
set -gx PATH $PATH /Users/yamadayuki/.anyenv/bin
set -gx PATH $PATH /Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/
set -gx PATH $PATH /usr/local/bin
set -gx PATH $PATH /usr/bin
set -gx PATH $PATH /bin
set -gx PATH $PATH /usr/sbin
set -gx PATH $PATH /sbin

for file in $fisher_path/conf.d/*.fish
    builtin source $file 2>/dev/null
end

# Homebrew
set -gx HOMEBREW_PREFIX (brew config | grep HOMEBREW_PREFIX |  awk '{ print $2 }')

# Go
set -gx GOPATH $HOME/dev

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
source (anyenv init -|psub)

# fzf
set -gx FZF_DEFAULT_OPTS --height 100% --layout=reverse

# skim
set -gx SKIM_DEFAULT_OPTIONS --ansi --layout=reverse --height 40%

# bat
alias cat "bat --plain --paging never"

# exa
alias ls exa

# zoxide
zoxide init fish | source

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Self installed binaries
set -gx SELF_INSTALLED_RUST_TOOLS \
    bat \
    pastel \
    procs \
    "git-delta" \
    exa \
    ripgrep \
    fd-find \
    skim

set -gx COLORTERM truecolor
