# Command Colors
set --global fish_color_normal brwhite
# set --global fish_color_autosuggestion brblack
# set --global fish_color_cancel         brcyan
set --global fish_color_command brblue
set --global fish_color_comment brblack
# set --global fish_color_cwd            brred
# set --global fish_color_end            brwhite
set --global fish_color_error brred
# set --global fish_color_escape         brcyan
# set --global fish_color_host           brgreen
# set --global fish_color_host_remote    bryellow
# set --global fish_color_match          brcyan --underline
set --global fish_color_operator brcyan
set --global fish_color_param brgreen
set --global fish_color_quote bryellow
set --global fish_color_redirection brcyan
# set --global fish_color_search_match   --background=brblack
# set --global fish_color_selection      --background=brblack
# set --global fish_color_user           brblue

set --global fish_pager_color_progress brcyan --reverse
# set --global fish_pager_color_background
set --global fish_pager_color_prefix brwhite --underline
set --global fish_pager_color_completion brwhite
set --global fish_pager_color_description bryellow
# set --global fish_pager_color_secondary_background  # null
# set --global fish_pager_color_secondary_completion  brblack
# set --global fish_pager_color_secondary_description brblack
# set --global fish_pager_color_secondary_prefix      brblack
# set --global fish_pager_color_selected_background   --background=brblack
# set --global fish_pager_color_selected_completion   bryellow
# set --global fish_pager_color_selected_description  bryellow
# set --global fish_pager_color_selected_prefix brblack

# Global variables
set --global sk_default_option --tiebreak=index --inline-info

# Key Bindings
bind \ct __sk_go_src
bind \cg __sk_code
bind \cr __sk_history
