# =============================================================================
# Completions Configuration (Fish external completer & Zoxide custom completer)
# References:
# - https://www.nushell.sh/cookbook/external_completers.html
# - https://www.nushell.sh/cookbook/custom_completers.html
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Fish External Completer (delegates external CLI completions to fish)
# -----------------------------------------------------------------------------
export def get_fish_completer [] {
    {|place|
        if not (which fish | is-not-empty) { return null }
        let cmd = ($place.command | str replace --all "'" "\\'" | str join " ")
        try {
            fish --command $"complete '--do-complete=($cmd)'"
            | from tsv --flexible --noheaders --no-infer
            | rename value description
            | update value {|row|
                let val = $row.value
                let need_quote = [" ", "[", "]", "(", ")", "'", "\"", "`"]
                if ($need_quote | any { |it| $it in $val }) and ($val | path exists) {
                    let expanded_path = if ($val | str starts-with "~") {
                        $val | path expand --no-symlink
                    } else {
                        $val
                    }
                    ($"\"($expanded_path | str replace --all "\"" "\\\"")\"")
                } else {
                    $val
                }
            }
        } catch {
            null
        }
    }
}

# -----------------------------------------------------------------------------
# 2. Zoxide Custom Completer (ported from config/fish/completions/z.fish)
# -----------------------------------------------------------------------------
def complete_zoxide_path [buffer: string] {
    if not (which zoxide | is-not-empty) {
        return { options: { sort: false }, completions: [] }
    }

    # Extract keywords typed after `z`
    let parts = ($buffer | str trim --left | split row " " | skip 1 | where { |it| $it | is-not-empty })
    let home = $nu.home-dir

    # Query zoxide for matching directories (excluding current directory)
    let lines = (do -i { ^zoxide query --list --exclude $env.PWD -- ...$parts }
        | complete
        | get stdout
        | lines
        | where { |it| $it | is-not-empty }
    )

    let completions = ($lines | each { |line|
        let desc = if ($line | str starts-with $home) {
            $"~($line | str substring ($home | str length)..)"
        } else {
            $line
        }
        {
            value: ($line | path basename)
            description: $desc
        }
    })

    {
        options: {
            sort: false
            completion_algorithm: "substring"
            case_sensitive: false
        }
        completions: $completions
    }
}

# Override zoxide's default filesystem directory completion with custom zoxide history completion
export def --env --wrapped z [...rest: string@complete_zoxide_path] {
    __zoxide_z ...$rest
}
