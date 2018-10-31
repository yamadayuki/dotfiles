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

function install_via_homebrew
    echo "+ Install modules via homebrew."

    set -l commands bat fd flow fzf go hub imagemagick jq lua ocaml ocamlbuild opam creasty/tools/rid sqlite the_silver_searcher tree watchman yarn
    brew install $commands
end

function install_via_fisher
    echo "+ Install modules via fisher."

    set -l packages jethrokuan/fzf rafaelrinaldi/pure yamadayuki/lure edc/bass
    fisher add $packages
end

function setup
    echo "+ Setup environment variables."

    set -x GOPATH $HOME/dev
    set -x PATH $PATH $GOENV_ROOT/bin $GOPATH/bin
end

#  Endpoint
#--------------------------------------

print_title
link_files
modify_defaults
install_via_homebrew
install_via_fisher
setup
