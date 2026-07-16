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

function link_mise_config
    echo "+ Link mise config into ~/.config/mise/conf.d/00-dotfiles.toml"

    # ~/.config/mise/conf.d, unlike /etc/mise, is a plain user-owned directory
    # that mise merges alphabetically and follows symlinks in, so [settings]/[tasks]
    # can be tracked in dotfiles and stay available from any cwd without sudo or
    # a copy-on-write workaround. [tools] stays in ~/.config/mise/config.toml,
    # managed separately via `mise use -g`.
    mkdir -p "$HOME/.config/mise/conf.d"
    ln -sf "$HOME/dotfiles/config/mise/config.toml" "$HOME/.config/mise/conf.d/00-dotfiles.toml"
end

function run_mise_bootstrap
    echo "+ Run mise bootstrap"

    mise trust "$HOME/dotfiles"
    mise bootstrap --cd "$HOME/dotfiles" --yes
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
link_mise_config
run_mise_bootstrap
print_done
