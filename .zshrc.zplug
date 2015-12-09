echo "Loading $HOME/.zshrc"

# zplug
source ~/.zplug/zplug

zplug "b4b4r07/zplug"
zplug "b4b4r07/enhancd"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "plugins/git", from:oh-my-zsh

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose

# functions
function peco-history-selection() {
  BUFFER=`history -n 1 | tail -r | awk '!a[$0]++' | peco`
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

# alias
alias zr="vim ~/.zshrc"
alias szr="source ~/.zshrc"

alias l="ls -laG"
alias ls="ls -G"

alias vi=vim

alias cdot="cd ~/dotfiles"
alias vdot="vim ~/dotfiles"

# settings
plugins+=(zsh-completions)
autoload -U compinit
compinit -u
autoload -U colors
colors

PROMPT="[%{$fg[white]%}%n%{$reset_color%}@%{$fg[red]%}%m%{$reset_color%} %{$fg[cyan]%}%c%{$reset_color%}]$ "
RPROMPT="[%{$fg_no_bold[yellow]%} %B%T%b %{$reset_color%}]"

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

setopt append_history
setopt auto_cd auto_pushd
setopt pushd_ignore_dups
setopt auto_list
setopt auto_param_slash
setopt auto_remove_slash
setopt HIST_NO_STORE
setopt hist_ignore_dups
setopt HIST_IGNORE_ALL_DUPS

# source
source ~/.zplug/repos/b4b4r07/enhancd/enhancd.sh
