#  functions
#-------------------------------------------------------------------------------
peco-select-history() {
  BUFFER=$(history  | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\*?\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$LBUFFER")
  CURSOR=${#BUFFER}
  zle reset-prompt
}
zle -N peco-select-history
bindkey '^r' peco-select-history

peco-go-src() {
  local selected_dir=$(ghq list | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    selected_dir="$GOPATH/src/$selected_dir"
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-go-src
bindkey '^t' peco-go-src

silent-git-status-sb() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
    echo
    git status -sb
  fi
  # builtin zle .accept-line
  zle reset-prompt
  return 0
}
zle -N silent-git-status-sb
bindkey '^n' silent-git-status-sb


#  settings
#-------------------------------------------------------------------------------
plugins+=(zsh-completions)
autoload -U compinit
compinit -u
autoload -U colors
colors

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

setopt append_history
setopt auto_cd auto_pushd
setopt pushd_ignore_dups
setopt auto_list
setopt auto_param_slash
setopt auto_remove_slash
setopt hist_ignore_dups
setopt share_history


#  export
#-------------------------------------------------------------------------------
export LESS='-R'
export LESSOPEN='|lessfilter %s'
export LANG=en_US.UTF-8
export LC_ALL=$LANG

export EDITOR='vim'

# Cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Go
export GOPATH=$HOME/dev
export PATH=$GOPATH/bin:$PATH

# Cabal
export PATH="$HOME/.cabal/bin:$PATH"

export PATH="$PATH:/usr/local/share/git-core/contrib/diff-highlight"

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"


#  alias
#-------------------------------------------------------------------------------
alias l="ls -laG"
alias ls="ls -G"
alias vi=vim

# bundle exec
alias be='bundle exec'

# git alias
alias g='git'

alias restart='source ~/.zshrc'
alias zconf='vim ~/.zshrc'
alias vconf='vim ~/.vimrc'

# docker
alias dk='docker'
alias dkc='docker-compose'
alias dkm='docker-machine'
alias dkl='docker-clean'


#  eval
#-------------------------------------------------------------------------------
eval "$(anyenv init -)"
eval "$(opam config env)"

#  zplug
#-------------------------------------------------------------------------------
[[ -f ~/.zplug/init.zsh ]] || return
source ~/.zplug/init.zsh

zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "plugins/bundler", from:oh-my-zsh
zplug "plugins/gem", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/go", from:oh-my-zsh
zplug "plugins/heroku", from:oh-my-zsh
zplug "plugins/mix", from:oh-my-zsh
zplug "plugins/osx", from:oh-my-zsh
zplug "plugins/pip", from:oh-my-zsh
zplug "lib/git", from:oh-my-zsh
zplug "themes/ys", from:oh-my-zsh

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose
