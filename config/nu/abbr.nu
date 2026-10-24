# =============================================================================
# Abbreviations (fish-like `abbr`, expanded by reedline on Space / Enter)
# Prefix with `^` or press Ctrl+Z right after expansion to keep the raw word.
# Removed entries keep expanding until Nushell is restarted.
# =============================================================================

export def get_abbreviations [] {
    {
        # ls
        l: "ls -la"
        # git
        g: "git"
        gs: "git status --short"
        ga: "git add"
        gc: "git commit"
        gco: "git checkout"
        gsw: "git switch"
        gd: "git diff"
        gl: "git lg"
        gp: "git push"
        gpl: "git pull"
    }
}

# -----------------------------------------------------------------------------
# Subcommand abbreviations (like fish's `abbr --command git st status`)
# Expanded only right after the command, e.g. `git st<Space>` -> `git status `.
# Built-in abbreviations can't do this: reedline matches a single word and
# Nushell never expands external command arguments.
# -----------------------------------------------------------------------------
const subcommand_abbreviations = {
    git: {
        st: "status"
        co: "checkout"
        sw: "switch"
        br: "branch"
        ci: "commit"
    }
}

# Menu source: the expansion of the `<command> <word>` just before the cursor, if any.
# `$place.command` is the parsed argv of the command under the cursor (`^git` -> `git`)
# and `$place.target` is the byte span of the word under the cursor.
def expand_subcommand_abbr [place: record] {
    let words = $place.command
    if ($words | length) != 2 or $place.cursor != $place.target.end {
        return []
    }

    let expansion = ($subcommand_abbreviations | get -o $words.0 | get -o $words.1)
    if $expansion == null {
        return []
    }

    [{ value: $expansion, span: $place.target }]
}

# A lone suggestion is applied at once by `completions.quick`; otherwise the menu stays empty
export def get_subcommand_abbr_menu [] {
    {
        name: subcommand_abbr_menu
        only_buffer_difference: false
        marker: ""
        type: {
            layout: columnar
            columns: 1
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: {|place| expand_subcommand_abbr $place }
    }
}

# The menu only opens when no other menu is active, so Enter still accepts a
# completion / history selection; the built-in abbreviations still expand on
# the inserted space and on Enter
export def get_subcommand_abbr_keybindings [] {
    [
        # Space: try the menu, close it if it found nothing, then insert the space
        {
            name: subcommand_abbr_space
            modifier: none
            keycode: space
            mode: [emacs, vi_insert]
            event: [
                { send: menu name: subcommand_abbr_menu }
                { send: esc }
                { edit: insertchar value: " " }
            ]
        }
        # Enter: try the menu, then submit (an empty menu lets Enter through);
        # `esc` only runs when Enter didn't submit, e.g. on an incomplete line
        {
            name: subcommand_abbr_enter
            modifier: none
            keycode: enter
            mode: [emacs, vi_insert]
            event: [
                { send: menu name: subcommand_abbr_menu }
                { send: enter }
                { send: esc }
            ]
        }
    ]
}
