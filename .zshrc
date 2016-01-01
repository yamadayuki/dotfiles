echo "Loading $HOME/.zshrc"

# zplug
source ~/.zplug/zplug

zplug "b4b4r07/zplug"
zplug "b4b4r07/enhancd"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "plugins/git", from:oh-my-zsh
zplug "lib/git", from:oh-my-zsh

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose

# functions
peco-select-history() {
  BUFFER=$(history  | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\*?\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$LBUFFER")
  CURSOR=${#BUFFER}
  zle reset-prompt
}
zle -N peco-select-history
bindkey '^r' peco-select-history

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

# alias
alias zr="vim ~/.zshrc"
alias szr="source ~/.zshrc"

alias l="ls -laG"
alias ls="ls -G"

alias vi=vim

alias cdot="cd ~/dotfiles"
alias vdot="vim ~/dotfiles"

# bundle exec
alias be="bundle exec"

# settings
plugins+=(zsh-completions)
# autoload -U compinit
# compinit -u
autoload -U colors
colors

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

# prompt
ZSH_THEME_GIT_PROMPT_PREFIX="(%{$fg_bold[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%} %{$fg[yellow]%}☒ %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} %{$fg[cyan]%}☑︎ %{$reset_color%}"

PROMPT='[%{$fg_bold[white]%}%n%{$reset_color%}@%{$fg_bold[red]%}%m%{$reset_color%} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)%{$reset_color%}]$ '
RPROMPT="[%{$fg_no_bold[yellow]%} %B%T%b %{$reset_color%}]"

# source
source ~/.zplug/repos/b4b4r07/enhancd/enhancd.sh
