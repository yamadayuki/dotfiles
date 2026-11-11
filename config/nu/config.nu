# =============================================================================
# Nushell Configuration File
# ~/.config/nushell/config.nu -> ~/dotfiles/config/nu/config.nu
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Tool Integrations (zoxide; mise is sourced at the end of this file)
# -----------------------------------------------------------------------------
# The init scripts are (re)generated in env.nu, which runs before this file is parsed.
# Sourcing with parse-time constants (null is a safe no-op if file does not exist)
# zoxide stays before completions.nu so its custom `z` overrides zoxide's.
const zoxide_path = if ("~/.cache/nushell/zoxide.nu" | path exists) { "~/.cache/nushell/zoxide.nu" } else { null }
source $zoxide_path

# -----------------------------------------------------------------------------
# 2. Modular Configurations
# -----------------------------------------------------------------------------
use theme.nu get_theme
use abbr.nu [get_abbr_menu, get_abbr_keybindings]
use completions.nu *

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
    # Check PATH and highlight valid vs invalid/missing commands in real-time (like fish)
    highlight_resolved_externals: true
    # Enable Kitty keyboard protocol for reliable modifier key handling (e.g. Ghostty)
    use_kitty_protocol: true
    bracketed_paste: true

    # Safety: move to trash by default instead of permanent delete (use `rm -p` for permanent)
    rm: {
        always_trash: true
    }

    edit_mode: "emacs"
    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }

    table: {
        mode: "rounded"
        index_mode: "always"
        show_empty: true
        header_on_separator: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: "wrapping"
            wrapping_try_keep_words: true
        }
    }

    datetime_format: {
        normal: "%Y-%m-%d %H:%M:%S"
        table: "%Y-%m-%d %H:%M:%S"
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
        # Ignore commands starting with a space to prevent logging sensitive secrets
        ignore_space_prefixed: true
    }

    hooks: {
        # Auto-page long tables/lists to interactive explore if exceeding terminal height
        display_output: { ||
            let result = $in
            let term_rows = (try { (term size).rows } catch { 25 })
            if (($result | describe) =~ 'list|table') and (try { ($result | length) > ($term_rows - 4) } catch { false }) {
                $result | explore
            } else {
                $result | table
            }
        }
        pre_prompt: [
            # Ported from fish_title.fish: updates terminal window title
            { ||
                let home = $nu.home-dir
                let current_dir = ($env.PWD | str replace $home "~")
                print -n $"\e]0;($current_dir)\a"
            }
            # Notify on completion of long-running commands (> 10s)
            { ||
                let duration_ms = ($env.CMD_DURATION_MS? | default 0 | into int)
                if $duration_ms >= 10000 {
                    let sec = ($duration_ms / 1000 | math round --precision 1)
                    let last_cmd = (try { history | last 1 | get 0.command } catch { "Command" })
                    try {
                        ^osascript -e $"display notification \"Finished in ($sec)s\" with title \"($last_cmd)\""
                    }
                }
            }
        ]
    }

    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        (get_abbr_menu)
    ]

    keybindings: [
        # Space / Enter: expand abbreviations (e.g. `gs` -> `git status --short`, `git st` -> `git status`)
        ...(get_abbr_keybindings)
        # Up arrow: Filter history by current buffer prefix
        {
            name: history_menu_up
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menu name: history_menu }
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        # Alt+Enter / Shift+Enter: Insert newline without executing
        {
            name: newline_insert_alt
            modifier: alt
            keycode: enter
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: insertnewline }
        }
        {
            name: newline_insert_shift
            modifier: shift
            keycode: enter
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: insertnewline }
        }
        # Ctrl+Backspace / Alt+Backspace: Delete previous word
        {
            name: backward_delete_word_ctrl
            modifier: control
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
        {
            name: backward_delete_word_alt
            modifier: alt
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
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

# -----------------------------------------------------------------------------
# 4. mise
# -----------------------------------------------------------------------------
# Sourced after `$env.config` is assigned: its `pre_prompt` hook would otherwise be
# replaced by the `pre_prompt` list above.
const mise_path = if ("~/.cache/nushell/mise.nu" | path exists) { "~/.cache/nushell/mise.nu" } else { null }
source $mise_path
