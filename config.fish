set fish_function_path $fish_function_path $fisher_path/functions
set fish_complete_path $fish_complete_path $fisher_path/completions

set -x SHELL /usr/local/bin/fish

for file in $fisher_path/conf.d/*.fish
    builtin source $file 2>/dev/null
end

# Rust
set -x PATH $PATH $HOME/.cargo/bin

# Go
set -x GOPATH $HOME/dev
set -x PATH $PATH $GOPATH/bin

# Deno
set -x PATH $PATH $HOME/.deno/bin

# Wantedly
set -x PATH $PATH $HOME/.wantedly/bin

# Homebrew
set -g fish_user_paths /usr/local/sbin $fish_user_paths

alias vi vim

set -x EDITOR vim

# direnv
# eval (direnv hook fish)
direnv hook fish | source

# hub command config
source (hub alias -s|psub)

# opam
eval (opam env)

# anyenv
source (anyenv init -|psub)

# fzf
set -x FZF_DEFAULT_OPTS --height 40% --layout=reverse

# skim
set -x SKIM_DEFAULT_OPTIONS --ansi --layout=reverse --height 40%

# bat
alias cat "bat --plain --paging never"

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8


# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.fish.inc" ]
    . "$HOME/google-cloud-sdk/path.fish.inc"
end

