# =============================================================================
# Custom Commands (ported from config/fish/functions/*.fish)
# =============================================================================

# ip: fetch public IP info (renders as structured Nushell table)
export def ip [target?: string] {
    if ($target | is-empty) {
        http get "https://ipinfo.io/json"
    } else {
        http get $"https://ipinfo.io/($target)/json"
    }
}

# localip: fetch local IP address on macOS en0 interface
export def localip [] {
    ipconfig getifaddr en0
}

# wttr: display weather forecast
export def wttr [location?: string] {
    let loc = if ($location | is-empty) {
        try { (http get "https://ipinfo.io/json").city } catch { "" }
    } else {
        $location
    }
    curl $"wttr.in/($loc)"
}

# is_m1: check if running on Apple Silicon
export def is_m1 [] {
    (uname).machine == "arm64"
}

# mtog: convert video to optimized GIF using ffmpeg & imagemagick
export def mtog [input: string, output: string] {
    ffmpeg -i $input -vf "scale=800:-1,eq=brightness=0.05" -r 10 -f image2pipe -vcodec ppm - | convert -delay 5 -layers Optimize -loop 0 - $output
}

# ctop: container monitoring top in docker
export def ctop [] {
    docker run -ti --name ctop --rm -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest
}

# -----------------------------------------------------------------------------
# Docker cleanup utilities
# -----------------------------------------------------------------------------
export def drmc [] {
    let ids = (docker ps -aq | lines | str trim | where { |x| $x | is-not-empty })
    if ($ids | is-not-empty) {
        docker rm -f ...$ids
    } else {
        print "No containers to remove."
    }
}

export def drmi [] {
    let ids = (docker images -aq | lines | str trim | where { |x| $x | is-not-empty })
    if ($ids | is-not-empty) {
        docker rmi -f ...$ids
    } else {
        print "No images to remove."
    }
}

export def drmn [] {
    let ids = (docker network ls -q | lines | str trim | where { |x| $x | is-not-empty })
    if ($ids | is-not-empty) {
        docker network rm ...$ids
    } else {
        print "No networks to remove."
    }
}

# -----------------------------------------------------------------------------
# ghq + fzf helpers (__sk_go_src / zhq / __sk_code / __sk_browse_github)
# -----------------------------------------------------------------------------
export def --env zhq [] {
    let selected = (ghq list | fzf --height 40% --layout=reverse --tiebreak=index)
    if ($selected | is-not-empty) {
        let root = (ghq root | str trim)
        cd ($root | path join ($selected | str trim))
    }
}

export def sk-code [] {
    let selected = (ghq list | fzf --height 40% --layout=reverse --tiebreak=index)
    if ($selected | is-not-empty) {
        let root = (ghq root | str trim)
        code ($root | path join ($selected | str trim))
    }
}

export def sk-browse [] {
    let selected = (ghq list | fzf --height 40% --layout=reverse --tiebreak=index)
    if ($selected | is-not-empty) {
        let parts = ($selected | str trim | split row "/")
        let repo = if ($parts | length) >= 2 {
            $parts | skip 1 | str join "/"
        } else {
            $selected
        }
        gh repo view $repo --web
    }
}

# -----------------------------------------------------------------------------
# Directory listing utilities (sorted by modified time descending)
# -----------------------------------------------------------------------------
export def ll [path?: string] {
    if ($path | is-empty) {
        ls -l | sort-by modified -r
    } else {
        ls -l $path | sort-by modified -r
    }
}

export def la [path?: string] {
    if ($path | is-empty) {
        ls -a -l | sort-by modified -r
    } else {
        ls -a -l $path | sort-by modified -r
    }
}
