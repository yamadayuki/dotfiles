
# Setting PATH for Python 3.4
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:${PATH}"
export PATH

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# git by Homebrew
export PATH="/usr/local/Cellar/git/2.1.0/bin:$PATH"

alias subl="/Applications/'Sublime Text.app'/Contents/SharedSupport/bin/subl"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
export PATH=/usr/local/bin:$PATH

export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick/6.8.9-7/include/ImageMagick-6/magick
export PATH="$HOME/.nodebrew/current/bin:$PATH"

# pyenv config
eval "$(pyenv init -)"

# python package
export PATH="$HOME/.pyenv/versions/3.4.2/bin:$PATH"

# mysql by Homebrew
export PATH="/usr/local/Cellar/mysql/5.6.22/bin:$PATH"

test -r ~/.bashrc && . ~/.bashrc
