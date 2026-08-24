function __sk_history
    set -l query (commandline)
    history merge
    history -z | sk --read0 $sk_default_option -q $query | perl -pe 'chomp if eof' | read -lz result
    and commandline -- $result
    commandline -f repaint
end
