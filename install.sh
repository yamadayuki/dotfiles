#! /bin/sh

MY_PATH="`dirname \"$0\"`"
DOTFILES_PATH="`( cd \"$MY_PATH\" && pwd )`"

ln -sf "$DOTFILES_PATH/.gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_PATH/.hyper.js" ~/.hyper.js
ln -sf "$DOTFILES_PATH/.vimrc" ~/.vimrc
ln -sf "$DOTFILES_PATH/.vimrc.plug" ~/.vimrc.plug
ln -sf "$DOTFILES_PATH/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_PATH/.npmrc" ~/.npmrc
ln -sf "$DOTFILES_PATH/.editorconfig" ~/.editorconfig


# For Atom

# Install Sync Settings
# https://github.com/atom-community/sync-settings
# Gist ID from URL (This is secret)
