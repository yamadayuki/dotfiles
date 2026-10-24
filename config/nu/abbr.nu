# =============================================================================
# Abbreviations (fish-like `abbr`, expanded on Space / Enter)
# Expanded through a menu source instead of `$env.config.abbreviations`, which
# also expands path arguments of internal commands (`cd l` -> `cd ls -la`) and
# can't expand a word after a command (`git st`).
# Prefix with `^` (`^gs`) to run the raw word.
# =============================================================================

# Expanded only at a command position (line start, after `|` / `;`, inside blocks)
const abbreviations = {
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

# Expanded only right after the command, like fish's `abbr --command git st status`
# (e.g. `git st<Space>` -> `git status `)
const subcommand_abbreviations = {
    git: {
        st: "status"
        co: "checkout"
        sw: "switch"
        br: "branch"
        ci: "commit"
    }
}

# Menu source: the expansion of the word just before the cursor, if any.
# `$place.command` is the parsed argv of the command under the cursor (`^git` -> `git`),
# `$place.target` is the byte span of the word under the cursor (without `^`).
def expand_abbr [buffer: string, place: record] {
    let start = $place.target.start
    if $place.cursor != $place.target.end {
        return []
    }

    let expansion = if $place.kind == "command" {
        let before = if $start > 0 {
            $buffer | encode utf8 | bytes at ($start - 1)..<$start | decode utf8
        } else {
            ""
        }
        if $before == "^" {
            return []
        }
        $abbreviations | get -o $place.command.0
    } else if ($place.command | length) == 2 {
        $subcommand_abbreviations | get -o $place.command.0 | get -o $place.command.1
    }
    if $expansion == null {
        return []
    }

    [{ value: $expansion, span: $place.target }]
}

# A lone suggestion is applied at once by `completions.quick`; otherwise the menu stays empty
export def get_abbr_menu [] {
    {
        name: abbr_menu
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
        source: {|buffer, place| expand_abbr $buffer $place }
    }
}

# The menu only opens when no other menu is active, so Enter still accepts a
# completion / history selection
export def get_abbr_keybindings [] {
    [
        # Space: try the menu, close it if it found nothing, then insert the space
        {
            name: abbr_space
            modifier: none
            keycode: space
            mode: [emacs, vi_insert]
            event: [
                { send: menu name: abbr_menu }
                { send: esc }
                { edit: insertchar value: " " }
            ]
        }
        # Enter: try the menu, then submit (an empty menu lets Enter through);
        # `esc` only runs when Enter didn't submit, e.g. on an incomplete line
        {
            name: abbr_enter
            modifier: none
            keycode: enter
            mode: [emacs, vi_insert]
            event: [
                { send: menu name: abbr_menu }
                { send: enter }
                { send: esc }
            ]
        }
    ]
}
