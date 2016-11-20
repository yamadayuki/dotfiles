#! /bin/sh

MY_PATH="`dirname \"$0\"`"
DOTFILES_PATH="`( cd \"$MY_PATH\" && pwd )`"

ln -s -i "$DOTFILES_PATH/.gitconfig" ~/.gitconfig
ln -s -i "$DOTFILES_PATH/.vimrc" ~/.vimrc
ln -s -i "$DOTFILES_PATH/.zshrc" ~/.zshrc
