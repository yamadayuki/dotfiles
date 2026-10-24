# =============================================================================
# Nushell Configuration File
# ~/.config/nushell/config.nu -> ~/dotfiles/config/nu/config.nu
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Tool Integrations (zoxide & mise)
# -----------------------------------------------------------------------------
let cache_dir = ($nu.home-dir | path join ".cache" "nushell")
if not ($cache_dir | path exists) {
    mkdir $cache_dir
}

let zoxide_cache_file = ($cache_dir | path join "zoxide.nu")
if not ($zoxide_cache_file | path exists) {
    if (which zoxide | is-not-empty) {
        try { ^zoxide init nushell | save -f $zoxide_cache_file }
    }
}

let mise_cache_file = ($cache_dir | path join "mise.nu")
if not ($mise_cache_file | path exists) {
    if (which mise | is-not-empty) {
        try { ^mise activate nu | save -f $mise_cache_file }
    }
}

# Sourcing with parse-time constants (null is a safe no-op if file does not exist yet)
const zoxide_path = if ("~/.cache/nushell/zoxide.nu" | path exists) { "~/.cache/nushell/zoxide.nu" } else { null }
source $zoxide_path

const mise_path = if ("~/.cache/nushell/mise.nu" | path exists) { "~/.cache/nushell/mise.nu" } else { null }
source $mise_path

# -----------------------------------------------------------------------------
# 2. Modular Configurations
# -----------------------------------------------------------------------------
use theme.nu get_theme
use completions.nu [get_fish_completer, z]

source prompt.nu
source aliases.nu
source commands.nu
source docker_db.nu

# -----------------------------------------------------------------------------
# 3. General Configuration ($env.config)
# -----------------------------------------------------------------------------
$env.config = {
    show_banner: false
    buffer_editor: "vim"
    color_config: (get_theme)

    table: {
        mode: "rounded"
        index_mode: "always"
        show_empty: true
        trim: {
            methodology: "wrapping"
            wrapping_try_keep_words: true
        }
    }

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
        external: {
            enable: true
            max_results: 100
            completer: (get_fish_completer)
        }
    }

    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "sqlite"
        isolation: false
    }

    hooks: {
        # Ported from fish_title.fish: updates terminal window title
        pre_prompt: [
            { ||
                let home = $nu.home-dir
                let current_dir = ($env.PWD | str replace $home "~")
                print -n $"\e]0;($current_dir)\a"
            }
        ]
    }

    keybindings: [
        # Ctrl+T: Interactive repo jump using ghq + fzf (zhq)
        {
            name: ghq_cd
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "zhq"
            }
        }
        # Ctrl+G: Open repo in VSCode using ghq + fzf (sk-code)
        {
            name: ghq_code
            modifier: control
            keycode: char_g
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "sk-code"
            }
        }
    ]
}
