#  Functions
#--------------------------------------

function print_title
    printf "\e[34m"
    echo '                                                                              '
    echo '                    https://github.com/yamadayuki/dotfiles                    '
    echo '                                                                              '
    echo '                             __      __  _____ __                             '
    echo '                        ____/ /___  / /_/ __(_) /__  _____                    '
    echo '                       / __  / __ \/ __/ /_/ / / _ \/ ___/                    '
    echo '                     _/ /_/ / /_/ / /_/ __/ / /  __(__  )                     '
    echo '                    (_)__,_/\____/\__/_/ /_/_/\___/____/                      '
    echo '                                                                              '
    printf "\e[0m\n"
end

function print_done
    printf "\e[34m"
    echo '                                                                              '
    echo '                              ____                                            '
    echo '                             / __ \____  ____  ___                            '
    echo '                            / / / / __ \/ __ \/ _ \                           '
    echo '                           / /_/ / /_/ / / / /  __/                           '
    echo '                          /_____/\____/_/ /_/\___(_)                          '
    echo '                                                                              '
    printf "\e[0m\n"
end

function link_files
    echo "+ Link config files in dotfiles/config ."

    set -l dotfiles_path "$HOME/dotfiles/config"
    for file in (ls $dotfiles_path)
        ln -sf "$dotfiles_path/$file" "$HOME/.$file"
    end
end

function modify_defaults
    echo "+ Modify macOS defaults."

    # Set a blazingly fast keyboard repeat rate.
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10
end

function install_modules_via_homebrew
    echo "+ Install modules via homebrew."

    set -l commands bat fd ffmpeg flow fzf go hub imagemagick jq lua ocaml ocamlbuild opam creasty/tools/rid ripgrep sqlite tig tree watchman yarn
    brew install $commands
end

function install_casks_via_homebrew
    echo "+ Install casks via homebrew."

    set -l casks google-chrome insomnia visual-studio-code
    brew cask install $casks
end

function install_fisher
    functions -q fisher and return

    echo "+ Install fisher"
    curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
    source ~/.config/fish/functions/fisher.fish
end

function install_via_fisher
    if not functions -q fisher
        echo "  ><> fisher is not installed..."
        return
    end

    echo "+ Install modules via fisher."

    set -l packages edc/bass jethrokuan/fzf oh-my-fish/plugin-nodenv oh-my-fish/plugin-pyenv oh-my-fish/plugin-rbenv rafaelrinaldi/pure yamadayuki/lure
    fisher add $packages
end

#  Endpoint
#--------------------------------------

print_title
link_files
modify_defaults
install_fisher
install_modules_via_homebrew
install_casks_via_homebrew
install_via_fisher
print_done
