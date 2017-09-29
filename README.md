dotfiles
===

### Installation
```
$ ghq get -u -p yamadayuki/dotfiles
$ cd path/to/yamadayuki/dotfiles
$ fish install.fish
```

### Configuration

For OPAM
```
$ opam switch 4.02.3
$ opam update
$ opam pin add lock https://github.com/rgrinberg/opam-lock.git
$ opam lock --install < opam.lock
```
