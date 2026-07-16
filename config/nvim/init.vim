" Neovim doesn't read ~/.vimrc, so extend runtimepath to cover ~/.vim
" (where the shared colorscheme lives) and reuse that vimrc as-is; its
" has('nvim') branches handle the few Vim/Neovim differences.
let &runtimepath = &runtimepath . ',' . expand('~/.vim')
source ~/.vimrc
