export PATH=$PATH:/Users/yamadayuuki/.nodebrew/current/bin

# ssh melo-backend
alias sshb="ssh ec2-user@ec2-54-92-88-38.ap-northeast-1.compute.amazonaws.com"

# ssh melo-web
alias sshw="ssh ubuntu@ec2-54-64-206-230.ap-northeast-1.compute.amazonaws.com"

# ssh melo-deploy
alias sshd="ssh ec2-user@ec2-54-64-38-171.ap-northeast-1.compute.amazonaws.com"

# change color file and directory
alias ls='ls -G'

# git add . && git commit -m "WIP"
alias wip='git add . && git commit -m "WIP"'

# bundle exec
alias be='bundle exec'

# postgresql server start / stop
alias pgstart='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias pgstop='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/yamadayuuki/.sdkman"
[[ -s "/Users/yamadayuuki/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/yamadayuuki/.sdkman/bin/sdkman-init.sh"
