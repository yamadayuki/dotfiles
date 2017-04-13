set shell=/usr/local/bin/zsh

" Check whether the file is readable
if filereadable(expand('$HOME/.vimrc.plug'))
  " source $HOME/.vimrc.neobundle .vimrcファイル読み込み
  source $HOME/.vimrc.plug
endif

" "dein Scripts-----------------------------
" if &compatible
"   set nocompatible
" endif
"
" " Required:
" set runtimepath+=/Users/yamadayuuki/dev/src/github.com/Shougo/dein.vim
"
" " Required:
" call dein#begin('/Users/yamadayuuki/.vim/dein')
"
" " Let dein manage dein
" " Required:
" call dein#add('Shougo/dein.vim')
"
" " Add or remove your plugins here:
" call dein#add('Shougo/neosnippet.vim')
" call dein#add('Shougo/neosnippet-snippets')
"
" " You can specify revision/branch/tag.
" call dein#add('Shougo/vimshell', { 'rev': '3787e5' })
"
" " Required:
" call dein#end()
"
" " Required:
" filetype plugin indent on
" syntax enable
"
" " If you want to install not installed plugins on startup.
" "if dein#check_install()
" "  call dein#install()
" "endif
"
" "End dein Scripts-------------------------


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Display
set number
set ruler
" set cursorline
" set cursorcolumn
set laststatus=2
set showmatch
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Cursor
set scrolloff=5
set sidescrolloff=5
set sidescroll=1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" File
set confirm
set hidden
set autoread
set nobackup
set noswapfile
set clipboard+=unnamed,autoselect
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Search, Displacement
set nohlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
set gdefault
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Tab, Indent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent
set backspace=indent,eol,start

augroup fileTypeIndent
  autocmd!
  autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4 autoindent smartindent
  autocmd BufNewFile,BufRead *.php setlocal tabstop=4 softtabstop=4 shiftwidth=4 autoindent smartindent
  autocmd BufNewFile,BufRead *.rb setlocal tabstop=2 softtabstop=2 shiftwidth=2 autoindent smartindent
augroup END

set pastetoggle=<C-e>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" OS
set mouse=a
set clipboard=unnamed
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Command line
set wildmenu
set wildmode=list:longest,full
set history=10000
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" netrw
let g:netrw_liststyle = 3
let g:netrw_altv = 1
let g:netrw_alto = 1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Normal -> Command
nnoremap ; :

nnoremap s <Nop>
nnoremap sh <C-w>h
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap st :<C-u>tabnew<CR>
nnoremap sn gt
nnoremap sp gT
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>

nnoremap q <Nop>
nnoremap qq :<C-u>q<CR>
nnoremap qw :<C-u>wq<CR>

nnoremap s= <C-w>=
call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
call submode#map('bufmove', 'n', '', '>', '<C-w>>')
call submode#map('bufmove', 'n', '', '<', '<C-w><')
call submode#map('bufmove', 'n', '', '+', '<C-w>+')
call submode#map('bufmove', 'n', '', '-', '<C-w>-')
