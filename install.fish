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
  echo "Link config files in dotfiles/config ."

  set -l dotfiles_path "$PWD/config"
  for file in (ls $dotfiles_path)
    ln -sf "$dotfiles_path/$file" "$HOME/.$file"
  end
end

print_title
link_files
