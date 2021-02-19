set -x SHELL /opt/homebrew/bin/fish

for file in $fisher_path/conf.d/*.fish
    builtin source $file 2>/dev/null
end

# Homebrew
set -U fish_user_paths /opt/homebrew/bin $fish_user_paths

# Rust
set -U fish_user_paths $HOME/.cargo/bin $fish_user_paths

# Go
set -x GOPATH $HOME/dev
set -U fish_user_paths $fish_user_paths $GOPATH/bin

# Go M1 preview
# set -U fish_user_paths $HOME/go-darwin-arm64-bootstrap/bin $fish_user_paths

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

# skim
set -x SKIM_DEFAULT_OPTIONS --ansi --layout=reverse --height 40%

# bat
alias cat "bat --plain --paging never"

# exa
alias ls exa

# vim
alias vi vim
set -x EDITOR vim

# Visual Studio Code - Exploration
# set -U fish_user_paths $fish_user_paths /Applications/Visual\ Studio\ Code\ -\ Exploration.app/Contents/Resources/app/bin
set -U fish_user_paths $fish_user_paths /Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin

set -x ENHANCD_FILTER sk

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Self installed binaries
set -x SELF_INSTALLED_RUST_TOOLS \
    bat \
    pastel \
    procs \
    "git-delta" \
    exa \
    ripgrep \
    fd-find \
    skim

set -x COLORTERM truecolor
