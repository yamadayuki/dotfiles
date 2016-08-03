
# Setting PATH for Python 3.4
# The orginal version is saved in .bash_profile.pysave
export PATH

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
export PATH=/usr/local/bin:$PATH

export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick/6.8.9-7/include/ImageMagick-6/magick
export PATH="$HOME/.nodebrew/current/bin:$PATH"

# pyenv config
eval "$(pyenv init -)"

test -r ~/.bashrc && . ~/.bashrc

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/yamadayuuki/.sdkman"
[[ -s "/Users/yamadayuuki/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/yamadayuuki/.sdkman/bin/sdkman-init.sh"
