# Nushell Environment Config File
# ~/.config/nushell/env.nu -> ~/dotfiles/config/nu/env.nu

# PATH conversion settings
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "MANPATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "PKG_CONFIG_PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
let dotfiles_nu = ($nu.home-dir | path join "dotfiles" "config" "nu")
$env.NU_LIB_DIRS = [
    $dotfiles_nu
    ($dotfiles_nu | path join "completions")
    ($nu.default-config-dir | path join "scripts")
]

# Directories to search for plugin binaries
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join "plugins")
]

# -----------------------------------------------------------------------------
# PATH Configuration (ported from config/fish/config.fish)
# -----------------------------------------------------------------------------
let home = $nu.home-dir

# Homebrew must come first so brewed tools take precedence over system tools
let prepend_paths = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
]

# User tools & shims (appended or added with priority)
let append_paths = [
    ($home | path join ".cargo" "bin")
    ($home | path join "dev" "bin")
    ($home | path join ".anyenv" "bin")
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    ($home | path join "google-cloud-sdk" "bin")
    ($home | path join ".local" "bin")
    ($home | path join ".docker" "bin")
    ($home | path join ".deno" "bin")
    ($home | path join "Library" "pnpm")
    ($home | path join ".antigravity-ide" "antigravity-ide" "bin")
    ($home | path join ".vite-plus" "bin")
]

# Build sanitized PATH list (only existing paths, preserving order and removing duplicates)
let current_paths = if ($env.PATH | describe) =~ '^list' {
    $env.PATH
} else {
    $env.PATH | split row (char esep)
}

$env.PATH = (
    ($prepend_paths | where { |p| $p | path exists })
    | append $current_paths
    | append ($append_paths | where { |p| $p | path exists })
    | uniq
)

# -----------------------------------------------------------------------------
# Environment Variables (ported from config/fish/config.fish)
# -----------------------------------------------------------------------------
$env.SHELL = (which nu | get 0?.path? | default "/opt/homebrew/bin/nu")

# Homebrew Prefix
$env.HOMEBREW_PREFIX = if ("/opt/homebrew" | path exists) {
    "/opt/homebrew"
} else if ("/usr/local" | path exists) {
    "/usr/local"
} else {
    ""
}

# Go
$env.GOPATH = ($home | path join "dev")

# Editor
$env.EDITOR = "vim"

# Fuzzy finders (fzf / skim)
$env.FZF_DEFAULT_OPTS = "--height 100% --layout=reverse"
$env.SKIM_DEFAULT_OPTIONS = "--ansi --layout=reverse --height 40%"

# bat theme
$env.BAT_THEME = "base16"

# Locales
$env.LANG = "en_US.UTF-8"
$env.LANGUAGE = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"
$env.LC_TYPE = "en_US.UTF-8"

# Terminal capabilities
$env.COLORTERM = "truecolor"

# GitHub CLI
$env.GH_BROWSER = "open"

# Deno & pnpm
$env.DENO_INSTALL = ($home | path join ".deno")
$env.PNPM_HOME = ($home | path join "Library" "pnpm")

# -----------------------------------------------------------------------------
# Tool init scripts (zoxide & mise), sourced from config.nu
# Generated here because env.nu runs before config.nu is parsed, so a fresh
# script takes effect on the same startup. Regenerated when the binary found in
# PATH is newer than its script: the Homebrew symlink is relinked on upgrade and
# `mise self-update` rewrites the binary (both without spawning the tool).
# -----------------------------------------------------------------------------
let nu_cache_dir = ($home | path join ".cache" "nushell")
mkdir $nu_cache_dir

for tool in [
    { name: "zoxide", init: {|| ^zoxide init nushell } }
    { name: "mise", init: {|| ^mise activate nu } }
] {
    let bin = (which $tool.name | get 0?.path?)
    if $bin == null {
        continue
    }

    let script = ($nu_cache_dir | path join $"($tool.name).nu")
    let stale = (not ($script | path exists)) or ((ls $bin | get 0.modified) > (ls $script | get 0.modified))
    if $stale {
        try { do $tool.init | save -f $script }
    }
}

