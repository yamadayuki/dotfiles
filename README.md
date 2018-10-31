# dotfiles

### Installation

```
$ bash <(curl -sSL https://raw.githubusercontent.com/yamadayuki/dotfiles/master/up)
```

### Configuration

For OPAM

```
$ opam switch 4.02.3
$ opam update
$ opam pin add lock https://github.com/rgrinberg/opam-lock.git
$ opam lock --install < opam.lock
```
