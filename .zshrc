export SHELL=/usr/local/bin/zsh

#  functions
#-------------------------------------------------------------------------------
function peco-select-history() {
  local tac
  if which tac > /dev/null;
  then
    tac="tac"
  else
    tac="tail -r"
  fi
  BUFFER=$(\history -n 1 | \
    eval $tac | \
    peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen

  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi
}
zle -N peco-select-history
bindkey '^r' peco-select-history

peco-go-src() {
  local selected_dir=$(ghq list | peco --query "$LBUFFER" --initial-filter Fuzzy)
  if [ -n "$selected_dir" ]; then
    selected_dir="$GOPATH/src/$selected_dir"
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-go-src
bindkey '^t' peco-go-src

peco-git-checkout() {
  local selected_branch=$(git branch -a | peco --query "$LBUFFER")
  if [ -n "$selected_branch" ]; then
    [[ $selected_branch =~ 'remotes/origin/(.+)' ]] && selected_branch=$match[1]
    [[ $selected_branch =~ '\* (.+)' ]] && selected_branch=$match[1]
    BUFFER="git checkout ${selected_branch}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-git-checkout
bindkey '^g' peco-git-checkout

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
setopt auto_cd auto_pushd
setopt pushd_ignore_dups
setopt auto_list
setopt auto_param_slash
setopt auto_remove_slash

setopt bang_hist
setopt inc_append_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_beep


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

# Postgres.app
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin


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

# ag
alias ag="ag --color-match '1;31'"


#  eval
#-------------------------------------------------------------------------------
eval "$(anyenv init -)"
# eval "$(opam config env)"

#  zplug
#-------------------------------------------------------------------------------
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

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

zplug load --verbose >&/dev/null
