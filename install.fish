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
    defaults write -g InitialKeyRepeat -int 10
    defaults write -g KeyRepeat -int 1
end

function install_modules_via_homebrew
    echo "+ Install modules via homebrew."

    set -l commands \
        # Clone of cat(1) with syntax highlighting and Git integration
        bat \
        # Simple, fast and user-friendly alternative to find
        fd \
        # Fuzzy Finder in rust!
        sk \
        # Search tool like grep and The Silver Searcher
        ripgrep \
        # Modern ls
        eza \
        # Pretty git diff tool
        git-delta \
        hub \
        ffmpeg \
        imagemagick \
        tree \
        fzf \
        zoxide \
        jq \
        gh \
        asdf \
        direnv

    brew install $commands
end

function install_casks_via_homebrew
    echo "+ Install casks via homebrew."

    # set -l casks \
    #     google-chrome
    # brew cask install $casks
end

function install_fisher
    functions -q fisher and return

    echo "+ Install fisher."
    curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
    source ~/.config/fish/functions/fisher.fish
end

function install_via_fisher
    if not functions -q fisher
        echo "  ><> fisher is not installed..."
        return
    end

    echo "  + Install modules via fisher."

    set -l packages \
        jorgebucaran/fisher \
        yamadayuki/lure
    fisher install $packages
end

function install_rustup
    which -s rustup and return

    echo "+ Install rustup."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
end

function install_via_cargo
    echo "  + Install modules via cargo."
    # cargo install sd bottom
end

function link_config_file
    echo "+ Link config.fish file into .config/fish/config.fish"

    ln -sf "$HOME/dotfiles/config.fish" "$HOME/.config/fish/config.fish"
end

function link_alacritty_config_file
    echo "+ Link alacritty.yml file into .config/alacritty/alacritty.yml"

    ln -sf "$HOME/dotfiles/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
end

function link_wezterm_config_file
    echo "+ Link wezterm.lua file into .config/wezterm/wezterm.lua"

    ln -sf "$HOME/dotfiles/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
end

function link_gitignore
    echo "+ Link gitignore file into .config/git/ignore"

    mkdir -p "$HOME/.config/git"
    ln -sf "$HOME/dotfiles/ignore" "$HOME/.config/git/ignore"
end

function link_warp_config
    echo "+ Link warp config file into $HOME/.warp"

    mkdir -p "$HOME/.warp"
    for file in (ls $HOME/dotfiles/warp)
        ln -sf "$HOME/dotfiles/warp/$file" "$HOME/.warp/$file"
    end
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

#  Endpoint
#--------------------------------------

print_title
link_files
modify_defaults
install_fisher
install_modules_via_homebrew
install_via_fisher
link_config_file
link_gitignore
link_warp_config
print_done
