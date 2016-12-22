# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="ys"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git bundler osx rake-fast ruby gem mix)

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#

#############################################################

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

function peco-go-src() {
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

function peco-git-checkout() {
  local selected_branch=$(git branch --no-merged | peco --query "$LBUFFER")
  if [ -n "$selected_branch" ]; then
    BUFFER="git checkout ${selected_branch}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-git-checkout
bindkey '^g' peco-git-checkout

#############################################################

# change color file and directory
alias ls='ls -G'

# bundle exec
alias be='bundle exec'

# git alias
alias g='git'

alias restart='source ~/.zshrc'

alias vi=vim

alias zconf='vim ~/.zshrc'
alias vconf='vim ~/.vimrc'

# less
export LESS='-R'
export LESSOPEN='|lessfilter %s'

###########################################################################

# export LANG=ja_JP.UTF-8

autoload -Uz colors
colors

autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..

setopt print_eight_bit
setopt auto_cd

###########################################################################

export PATH="/usr/local/ghc-7.10.2/bin:$PATH"
export PATH="$HOME/.cabal/bin:$PATH"

export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick/6.9.1-1/include/ImageMagick-6/magick

export PATH="$HOME/.gobrew/bin:$PATH"

export EDITOR='vim'
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

alias dk='docker'
alias dkc='docker-compose'
alias dkm='docker-machine'
alias dkl='docker-clean'

export PATH="/usr/local/sbin:$PATH"

export PATH="$PATH:/usr/local/share/git-core/contrib/diff-highlight"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/yamadayuuki/.sdkman"
[[ -s "/Users/yamadayuuki/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/yamadayuuki/.sdkman/bin/sdkman-init.sh"

export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
export PATH="$HOME/.anyenv/envs/nodenv/shims:$PATH"

eval "$(hub alias -s)"

export VAGRANT_HOME="/Volumes/Seagate/Vagrant/.vagrant.d"
export PATH="$PATH:$VAGRANT_HOME"
eval $(opam config env)

export GOPATH=$HOME/dev
export PATH=$GOPATH/bin:$PATH

export PATH="$HOME/.yarn/bin:$PATH"