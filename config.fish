set -x SHELL /usr/local/bin/fish

for file in $fisher_path/conf.d/*.fish
    builtin source $file 2>/dev/null
end

# Rust
set -U fish_user_paths $HOME/.cargo/bin $fish_user_paths

# Go
set -x GOPATH $HOME/dev
set -U fish_user_paths $fish_user_paths $GOPATH/bin

# Deno
set -U fish_user_paths $fish_user_paths $HOME/.deno/bin

# Homebrew
set -U fish_user_paths /usr/local/sbin $fish_user_paths

alias vi vim

set -x EDITOR vim

# direnv
# eval (direnv hook fish)
function __direnv_export_eval --on-event fish_prompt
    # Run on each prompt to update the state
    "/usr/local/bin/direnv" export fish | source

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
set -x FZF_DEFAULT_OPTS --height 100% --layout=reverse

# skim
set -x SKIM_DEFAULT_OPTIONS --ansi --layout=reverse --height 40%

# bat
alias cat "bat --plain --paging never"

# Visual Studio Code - Insiders
set -U fish_user_paths $fish_user_paths /Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/

# exa
alias ls exa

# zoxide
zoxide init fish | source

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8


# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.fish.inc" ]
    . "$HOME/google-cloud-sdk/path.fish.inc"
end

