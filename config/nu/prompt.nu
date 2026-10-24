# =============================================================================
# Nushell Custom Prompt (Starship alternative built natively in Nushell)
# =============================================================================

# Current directory with ~ shorthand (bold cyan)
def create_dir_prompt [] {
    let home = $nu.home-dir
    let pwd = $env.PWD
    let display_pwd = if ($pwd == $home) {
        "~"
    } else if ($pwd | str starts-with $home) {
        let rel = ($pwd | str substring ($home | str length)..)
        $"~($rel)"
    } else {
        $pwd
    }
    $"(ansi cyan_bold)($display_pwd)(ansi reset)"
}

# Git status (branch, tags, staged +, dirty *, untracked ?, ahead ⇡, behind ⇣)
def create_git_prompt [] {
    let is_git = (do -i { git rev-parse --is-inside-work-tree } | complete)
    if $is_git.exit_code != 0 or ($is_git.stdout | str trim) != "true" {
        return ""
    }

    let branch = (do -i { git branch --show-current } | complete | get stdout | str trim)
    let branch_name = if ($branch | is-empty) {
        let tag = (do -i { git describe --tags --exact-match } | complete | get stdout | str trim)
        if ($tag | is-not-empty) {
            $tag
        } else {
            let rev = (do -i { git rev-parse --short HEAD } | complete | get stdout | str trim)
            if ($rev | is-not-empty) { $rev } else { "detached" }
        }
    } else {
        $branch
    }

    let status_res = (do -i { git status --porcelain -b --ignore-submodules=dirty } | complete)
    if $status_res.exit_code != 0 {
        return $" (ansi dark_gray)on (ansi purple_bold)($branch_name)(ansi reset)"
    }

    let status_lines = ($status_res.stdout | lines)
    let branch_header = ($status_lines | first | default "")
    let file_lines = ($status_lines | skip 1)

    let ahead = if ($branch_header =~ 'ahead (\d+)') { "⇡" } else { "" }
    let behind = if ($branch_header =~ 'behind (\d+)') { "⇣" } else { "" }

    let has_staged = ($file_lines | any { |line| $line =~ '^[MADRC]' })
    let has_unstaged = ($file_lines | any { |line| $line =~ '^.[MADRU\?]' and not ($line =~ '^\?\?') })
    let has_untracked = ($file_lines | any { |line| $line =~ '^\?\?' })

    mut flags = []
    if $has_staged { $flags = ($flags | append $"(ansi green)+") }
    if $has_unstaged { $flags = ($flags | append $"(ansi red)*") }
    if $has_untracked { $flags = ($flags | append $"(ansi yellow)?") }
    if ($ahead | is-not-empty) { $flags = ($flags | append $"(ansi cyan)($ahead)") }
    if ($behind | is-not-empty) { $flags = ($flags | append $"(ansi magenta)($behind)") }

    let flag_str = ($flags | str join "")
    let flag_display = if ($flag_str | is-empty) { "" } else { $" [($flag_str)(ansi reset)]" }

    $" (ansi dark_gray)on (ansi purple_bold)($branch_name)(ansi reset)($flag_display)"
}

# Kubernetes context (bold red for gke_*, bold blue for others)
def create_k8s_prompt [] {
    let kubeconfig = ($env.KUBECONFIG? | default ($nu.home-dir | path join ".kube" "config"))
    if not ($kubeconfig | path exists) {
        return ""
    }

    if not (which kubectl | is-not-empty) {
        return ""
    }

    let ctx = (do -i { kubectl config current-context } | complete | get stdout | str trim)
    if ($ctx | is-empty) {
        return ""
    }

    let ctx_color = if ($ctx | str starts-with "gke_") {
        ansi red_bold
    } else {
        ansi blue_bold
    }

    $" (ansi dark_gray)via (ansi reset)[($ctx_color)☸ ($ctx)(ansi reset)]"
}

# Left prompt (directory + git + k8s)
def create_left_prompt [] {
    let dir = (create_dir_prompt)
    let git = (create_git_prompt)
    let k8s = (create_k8s_prompt)

    $"($dir)($git)($k8s)"
}

# Right prompt (command duration >2s + timestamp)
def create_right_prompt [] {
    let duration = if not ($env.CMD_DURATION_MS? | is-empty) {
        let ms = (try { $env.CMD_DURATION_MS | into int } catch { 0 })
        if $ms > 2000 {
            let s = ($ms / 1000 | math round --precision 1)
            $"(ansi yellow)($s)s "
        } else {
            ""
        }
    } else {
        ""
    }

    let time = (date now | format date "%H:%M:%S")
    $"($duration)(ansi dark_gray)($time)(ansi reset)"
}

# Apply prompt hooks
$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
$env.PROMPT_INDICATOR = {||
    if ($env.LAST_EXIT_CODE? == 0) {
        $"\n(ansi green_bold)❯ (ansi reset)"
    } else {
        $"\n(ansi red_bold)❯ (ansi reset)"
    }
}
$env.PROMPT_INDICATOR_VI_INSERT = {||
    if ($env.LAST_EXIT_CODE? == 0) {
        $"\n(ansi green_bold)❯ (ansi reset)"
    } else {
        $"\n(ansi red_bold)❯ (ansi reset)"
    }
}
$env.PROMPT_INDICATOR_VI_NORMAL = {||
    $"\n(ansi blue_bold)❮ (ansi reset)"
}
$env.PROMPT_MULTILINE_INDICATOR = {||
    $"(ansi dark_gray)::: (ansi reset)"
}

# -----------------------------------------------------------------------------
# Transient Prompt (collapses past executed prompts to simple 1 line)
# -----------------------------------------------------------------------------
$env.TRANSIENT_PROMPT_COMMAND = {|| "" }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR = {|| $"(ansi green_bold)❯ (ansi reset)" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| $"(ansi green_bold)❯ (ansi reset)" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| $"(ansi blue_bold)❮ (ansi reset)" }
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
