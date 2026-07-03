# dotfiles

### Installation

```
$ bash <(curl -sSL https://raw.githubusercontent.com/yamadayuki/dotfiles/master/up)
```

### Post-installation

#### mise configuration

The mise system-wide configuration requires manual setup:

```bash
sudo mkdir -p /etc/mise
sudo cp ~/dotfiles/config/mise/config.toml /etc/mise/config.toml
```

**Note:** mise does not recognize symlinks in `/etc/mise`, so we copy the file instead of linking it. If you update `~/dotfiles/config/mise/config.toml`, remember to copy it again to `/etc/mise/config.toml`.

This allows:
- Global settings (`[settings]`, `[tasks]`) managed in dotfiles at `/etc/mise/config.toml`
- Tool-specific config (`[tools]`) managed by `mise use` at `~/.config/mise/config.toml`

See: https://mise.jdx.dev/configuration.html#system-config-etc-mise-config-toml

### Profiling

```
$ fish --profile-startup /tmp/fish.profile -i -c exit
$ sort -nk2 /tmp/fish.profile
```
