# =============================================================================
# Completions Configuration (Fish external completer, Zoxide & Herdr Core `hc`)
# References:
# - https://www.nushell.sh/cookbook/external_completers.html
# - https://www.nushell.sh/cookbook/custom_completers.html
# - ~/.config/herdr-app/AGENTS.md
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

# -----------------------------------------------------------------------------
# 3. Herdr Core (`hc`) Custom Completions
# -----------------------------------------------------------------------------
def hc_list_terminals [all: bool] {
    if not (which hc | is-not-empty) { return [] }
    let args = if $all { ["ls", "--all", "--json"] } else { ["ls", "--json"] }
    try {
        ^hc ...$args | from json | get -o terminals | default []
    } catch {
        []
    }
}

def format_hc_terminals [terminals: list] {
    $terminals | each {|t|
        let status = if (($t.status? | describe) =~ '^record') {
            $t.status.state?
        } else {
            $t.status?
        }
        let loc = ($t.where? | default $t.cwd?)
        let addr_desc = ([$t.name?, $t.agent?, $status, $loc] | compact | where {|x| ($x | into string | is-not-empty) } | str join " · ")
        let addr_entry = { value: $t.address, description: $addr_desc }
        if ($t.name? | is-not-empty) {
            let name_desc = ([$t.address, $t.agent?, $status, $loc] | compact | where {|x| ($x | into string | is-not-empty) } | str join " · ")
            [$addr_entry, { value: $t.name, description: $name_desc }]
        } else {
            [$addr_entry]
        }
    } | flatten
}

# Live terminals (`hc ls --json`)
def complete_hc_terminal [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    format_hc_terminals (hc_list_terminals false)
}

# Live and finished terminals (`hc ls --all --json`)
def complete_hc_all_terminal [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    format_hc_terminals (hc_list_terminals true)
}

# Finished terminals only (for `hc rm`)
def complete_hc_finished_terminal [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    let finished = (hc_list_terminals true | where state? == "finished")
    format_hc_terminals $finished
}

# Configured remote machines (`hc machine ls --json`)
def complete_hc_machine [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    if not (which hc | is-not-empty) { return [] }
    try {
        ^hc machine ls --json
        | from json
        | get -o machines
        | default []
        | each {|m|
            let desc = ([$m.target?, $m.state?] | compact | str join " · ")
            { value: $m.name, description: $desc }
        }
    } catch {
        []
    }
}

# Templates (`hc templates --json`) + external commands for `hc run`
def complete_hc_run_target [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    let templates = if (which hc | is-not-empty) {
        try {
            ^hc templates --json
            | from json
            | get -o templates
            | default []
            | each {|t|
                { value: $t.name, description: $"template: ($t.description? | default $t.command?)" }
            }
        } catch {
            []
        }
    } else {
        []
    }
    let cmds = (try { $token.text | commandline complete -d --type command } catch { [] })
    $templates ++ $cmds
}

# Commands for `hc exec`
def complete_hc_command [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    try { $token.text | commandline complete -d --type command } catch { [] }
}

# Herdr labels (`herdr.space=<id>`, `herdr.tab=<id>`, etc. from ~/.config/herdr-app/AGENTS.md)
def complete_hc_label [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    let app_home = ($env.HERDR_APP_HOME? | default ($nu.home-dir | path join ".config" "herdr-app"))
    let view_file = ($app_home | path join "view.json")
    let active_labels = if ($view_file | path exists) {
        try {
            let view = (open --raw $view_file | from json)
            let space_id = ($view.active? | default "")
            let tab_id = if ($space_id | is-not-empty) {
                $view.spaces? | get -o $space_id | default ""
            } else {
                ""
            }
            [
                (if ($space_id | is-not-empty) { { value: $"herdr.space=($space_id)", description: "Active Herdr space" } })
                (if ($tab_id | is-not-empty) { { value: $"herdr.tab=($tab_id)", description: "Active Herdr tab" } })
            ] | compact
        } catch {
            []
        }
    } else {
        []
    }

    let static_labels = [
        { value: "herdr.space=", description: "Herdr space ID" }
        { value: "herdr.tab=", description: "Herdr tab ID" }
        { value: "herdr.pinned=true", description: "Pin agent to top of Herdr agent lists" }
        { value: "herdr.right-click=program", description: "Send right-clicks to terminal program" }
        { value: "herdr.right-click=menu", description: "Open Herdr menu on right-click" }
    ]

    $active_labels ++ $static_labels
}

# SSH config hosts for `hc machine add`
def complete_hc_ssh_host [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    let ssh_config = ($nu.home-dir | path join ".ssh" "config")
    if not ($ssh_config | path exists) { return [] }
    try {
        open --raw $ssh_config
        | lines
        | str trim
        | where {|line| $line =~ '(?i)^Host\s+' }
        | each {|line| $line | split words | skip 1 }
        | flatten
        | where {|h| not ($h | str contains "*") and not ($h | str contains "?") and not ($h | str starts-with "!") }
        | uniq
        | each {|h| { value: $h, description: "SSH config host" } }
    } catch {
        []
    }
}

def complete_hc_send_if [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    [
        { value: "idle", description: "Only send if terminal status is idle" }
        { value: "working", description: "Only send if terminal status is working" }
    ]
}

def complete_hc_wait_children [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    [
        { value: "any", description: "Wait for next child's news or a message to you" }
        { value: "all", description: "Wait until none of the children is working" }
    ]
}

def complete_hc_key [token: record] {
    if ($token.text | str starts-with "-") { return [] }
    [
        { value: "enter", description: "Enter / Return" }
        { value: "esc", description: "Escape" }
        { value: "tab", description: "Tab" }
        { value: "space", description: "Space" }
        { value: "backspace", description: "Backspace" }
        { value: "delete", description: "Delete" }
        { value: "up", description: "Up arrow" }
        { value: "down", description: "Down arrow" }
        { value: "left", description: "Left arrow" }
        { value: "right", description: "Right arrow" }
        { value: "home", description: "Home" }
        { value: "end", description: "End" }
        { value: "pageup", description: "Page Up" }
        { value: "pagedown", description: "Page Down" }
        { value: "ctrl+c", description: "Interrupt (SIGINT)" }
        { value: "ctrl+d", description: "EOF" }
        { value: "ctrl+z", description: "Suspend (SIGTSTP)" }
        { value: "ctrl+l", description: "Clear screen" }
        { value: "ctrl+\\", description: "Detach" }
    ]
}

# Run programs and coding agents in terminals that stay alive
export extern "hc" [
    --json                                      # JSON output even in a terminal
    --skill                                     # Print manual for running and coordinating programs and agents
    --licenses                                  # Print what hc includes and their licenses
    --version (-V)                              # Print version
    --help (-h)                                 # Print help
]

# Start a program, or a template by name with its task
export extern "hc run" [
    --json                                      # JSON output even in a terminal
    --name: string                              # Name, unique among live terminals (1-32 of a-z 0-9 - _)
    --cwd: directory                            # Working directory
    --on: string@complete_hc_machine            # Run on another machine (from `hc machine ls`)
    --label: string@complete_hc_label           # Labels, key=value (repeatable)
    --parent: string@complete_hc_terminal       # Parent terminal (default: the terminal it is started from)
    --no-parent                                 # No parent, even when started from a terminal
    --no-notify                                 # Don't type notes about it into its parent
    --outlive-parent                            # Keep it running when its parent's program ends
    --rm                                        # Remove it right after it exits
    --keep                                      # Replace lost programs with a shell in place
    --bg                                        # Start it and come back at once
    --timeout: number                           # Seconds before a wait checks in, leaving it running
    --help (-h)                                 # Print help
    cmd?: string@complete_hc_run_target         # Program or template name
    ...args: any                                # Program arguments or template task
]

# List live terminals
export extern "hc ls" [
    --all                                       # Include finished terminals
    --json                                      # JSON output even in a terminal
    --label: string@complete_hc_label           # Only terminals carrying all of these labels (repeatable)
    --help (-h)                                 # Print help
]

# Show one terminal
export extern "hc get" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    terminal?: string@complete_hc_all_terminal  # Terminal address, name, or machine/address
]

# Put this terminal on a core terminal (detach: ctrl+\)
export extern "hc attach" [
    --json                                      # JSON output even in a terminal
    --observe                                   # Watch only: never type or resize
    --history: int                              # Scrollback lines to show first (main screen only)
    --help (-h)                                 # Print help
    terminal?: string@complete_hc_terminal      # Terminal address, name, or machine/address
]

# Print a terminal's screen and history
export extern "hc read" [
    --json                                      # JSON output even in a terminal
    --lines: int                                # Lines of history above the screen
    --help (-h)                                 # Print help
    terminal?: string@complete_hc_all_terminal  # Terminal address, name, or machine/address
]

# End a terminal's program (hangup, then escalate)
export extern "hc kill" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    terminal?: string@complete_hc_terminal      # Terminal address, name, or machine/address
]

# Remove a finished terminal
export extern "hc rm" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    terminal?: string@complete_hc_finished_terminal # Finished terminal address, name, or machine/address
]

# Set labels (key=value; key= removes)
export extern "hc label" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    terminal: string@complete_hc_all_terminal   # Terminal address, name, or machine/address
    ...labels: string@complete_hc_label         # Labels to set (key=value; key= removes one)
]

# Keep a live terminal after loss (--off disables)
export extern "hc keep" [
    --json                                      # JSON output even in a terminal
    --off                                       # Disable keeping this live terminal after loss
    --help (-h)                                 # Print help
    terminal: string@complete_hc_terminal       # Terminal address, name, or machine/address
]

# Paste text into a terminal and press Enter
export extern "hc send" [
    --force                                     # Type even if the program is blocked
    --json                                      # JSON output even in a terminal
    --if: string@complete_hc_send_if            # Only type if status is idle or working
    --wait                                      # Wait for the turn this send started
    --timeout: number                           # With --wait: seconds before it checks in
    --help (-h)                                 # Print help
    terminal: string@complete_hc_terminal       # Terminal address, name, or machine/address
    text: string                                # Text pasted and submitted with Enter
]

# Press named keys (enter, esc, up, ctrl+c, alt+x, f5, a...)
export extern "hc keys" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    terminal: string@complete_hc_terminal       # Terminal address, name, or machine/address
    ...keys: string@complete_hc_key             # Key names (enter, esc, tab, up, ctrl+c, ...)
]

# Press the stop key and report what happened
export extern "hc interrupt" [
    --json                                      # JSON output even in a terminal
    --timeout: number                           # Seconds to watch for an effect (default 10)
    --help (-h)                                 # Print help
    terminal?: string@complete_hc_terminal      # Terminal address, name, or machine/address
]

# Wait for your children (--children any) or one terminal
export extern "hc wait" [
    --children: string@complete_hc_wait_children # Wait on children instead (any, all)
    --json                                      # JSON output even in a terminal
    --output: string                            # End when output printed after wait starts contains this text
    --timeout: number                           # Seconds before it checks in
    --help (-h)                                 # Print help
    terminal?: string@complete_hc_terminal      # Terminal address, name, or whose children to wait on
]

# Send a local file beside a terminal (on its machine)
export extern "hc put" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    terminal: string@complete_hc_terminal       # Terminal address, name, or machine/address
    file: path                                  # Local file to send
]

# Run one program without a terminal, here or on a machine
export extern "hc exec" [
    --json                                      # JSON output even in a terminal
    --on: string@complete_hc_machine            # Run on another machine (from `hc machine ls`)
    --cwd: directory                            # Working directory
    --env: string                               # Set on top of the core's environment, key=value (repeatable)
    --timeout: number                           # Seconds before it and everything it started are ended
    --stdin (-i)                                # Feed what is piped into hc to its stdin
    --help (-h)                                 # Print help
    cmd: string@complete_hc_command             # Program to run
    ...args: any                                # Program arguments
]

# Read, write or edit a file here or on a machine
export extern "hc file" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Print a text file, or lines of it (--offset, --limit)
export extern "hc file read" [
    --json                                      # JSON output even in a terminal
    --on: string@complete_hc_machine            # On another machine (from `hc machine ls`)
    --cwd: directory                            # Where a relative path starts
    --offset: int                               # First line to give, from 1
    --limit: int                                # At most this many lines
    --help (-h)                                 # Print help
    path: path                                  # File path (absolute, or relative to cwd)
]

# Write what is piped in as the file, making missing folders
export extern "hc file write" [
    --json                                      # JSON output even in a terminal
    --on: string@complete_hc_machine            # On another machine (from `hc machine ls`)
    --cwd: directory                            # Where a relative path starts
    --help (-h)                                 # Print help
    path: path                                  # File path (absolute, or relative to cwd)
]

# Replace exact text found once (--old X --new Y, repeatable)
export extern "hc file edit" [
    --json                                      # JSON output even in a terminal
    --on: string@complete_hc_machine            # On another machine (from `hc machine ls`)
    --cwd: directory                            # Where a relative path starts
    --old: string                               # Exact text found once in the file (repeatable)
    --new: string                               # Replacement text (paired with --old in order)
    --help (-h)                                 # Print help
    path: path                                  # File path (absolute, or relative to cwd)
]

# List templates (~/.config/herdr-core/templates)
export extern "hc templates" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Follow fact changes as they happen
export extern "hc events" [
    --json                                      # JSON output even in a terminal
    --terminal: string@complete_hc_all_terminal # Only this terminal
    --children-of: string@complete_hc_all_terminal # Only children of this terminal
    --label: string@complete_hc_label           # Only terminals carrying all of these labels (repeatable)
    --help (-h)                                 # Print help
]

# Start, stop or inspect the core
export extern "hc server" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Start the core
export extern "hc server start" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Stop the core and park kept terminals
export extern "hc server stop" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Show the core's status
export extern "hc server status" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Restart the core; programs keep running
export extern "hc server restart" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Swap this hc for another build and restart (terminals keep running)
export extern "hc update" [
    --from: path                                # A herdr-core binary to use
    --json                                      # JSON output even in a terminal
    --version: string                           # At least this release (e.g. 0.1.4)
    --force                                     # Allow an older version or another protocol generation
    --help (-h)                                 # Print help
]

# Other machines, reached over ssh
export extern "hc machine" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Add a machine you reach with ssh
export extern "hc machine add" [
    --json                                      # JSON output even in a terminal
    --via: string                               # Reach it with this command instead of ssh (needs --name)
    --temp                                      # Mark it short-lived (a sandbox for a task)
    --install                                   # Copy this hc there when missing or too old, without asking
    --name: string                              # Name for this machine here (default: target's host)
    --session: string                           # The hc session on that machine
    --help (-h)                                 # Print help
    target?: string@complete_hc_ssh_host        # SSH target (host, user@host, or Host from ~/.ssh/config)
]

# List the machines added here
export extern "hc machine ls" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]

# Log in again after the machine says it needs one
export extern "hc machine login" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    machine: string@complete_hc_machine         # The machine's name
]

# Copy this hc there and restart hc there (its terminals keep running)
export extern "hc machine update" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    machine: string@complete_hc_machine         # The machine's name
]

# Give a machine a new name here
export extern "hc machine rename" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    machine: string@complete_hc_machine         # Current machine name
    new_name: string                            # New machine name
]

# Forget a machine (its terminals keep running there)
export extern "hc machine rm" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
    machine: string@complete_hc_machine         # The machine's name
]

# Speak the protocol over stdin/stdout (ssh box hc connect)
export extern "hc connect" [
    --json                                      # JSON output even in a terminal
    --session: string                           # The hc session to reach, like HC_SESSION
    --help (-h)                                 # Print help
]

# Every API method with its JSON Schema, for app builders
export extern "hc schema" [
    --json                                      # JSON output even in a terminal
    --help (-h)                                 # Print help
]
