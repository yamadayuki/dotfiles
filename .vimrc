" ファイルが読み込み可能かチェック
if filereadable(expand('$HOME/.vimrc.neobundle'))
  " source $HOME/.vimrc.neobundle " .vimrcファイル読み込み
  source $HOME/.vimrc.plug
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" 画面表示の設定
set number
set ruler
set cursorline
set cursorcolumn
set laststatus=2
set showmatch
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" カーソル移動の設定
set scrolloff=5
set sidescrolloff=5
set sidescroll=1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" ファイル処理関連
set confirm
set hidden
set autoread
set nobackup
set noswapfile
set clipboard+=unnamed,autoselect
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" 検索、置換関連
set nohlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
set gdefault
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" タブ、インデントの設定
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
""" OS関連
set mouse=a
set clipboard=unnamed
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" コマンドラインの設定
set wildmenu
set wildmode=list:longest,full
set history=10000
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ノーマルモードでコマンドラインモードに入る時の効率化
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

nnoremap s= <C-w>=
call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
call submode#map('bufmove', 'n', '', '>', '<C-w>>')
call submode#map('bufmove', 'n', '', '<', '<C-w><')
call submode#map('bufmove', 'n', '', '+', '<C-w>+')
call submode#map('bufmove', 'n', '', '-', '<C-w>-')

" fzf
set rtp+=~/.fzf

" 括弧の対応
" inoremap { {}<LEFT>
" inoremap [ []<LEFT>
" inoremap ( ()<LEFT>
" inoremap " ""<LEFT>
" inoremap ' ''<LEFT>
" function! DeleteParenthesesAdjoin()
"     let pos = col(".") - 1  " カーソルの位置．1からカウント
"     let str = getline(".")  " カーソル行の文字列
"     let parentLList = ["(", "[", "{", "\'", "\""]
"     let parentRList = [")", "]", "}", "\'", "\""]
"     let cnt = 0
"
"     let output = ""
"
"     " カーソルが行末の場合
"     if pos == strlen(str)
"         return "\b"
"     endif
"     for c in parentLList
"         " カーソルの左右が同種の括弧
"         if str[pos-1] == c && str[pos] == parentRList[cnt]
"             call cursor(line("."), pos + 2)
"             let output = "\b"
"             break
"         endif
"         let cnt += 1
"     endfor
"     return output."\b"
" endfunction
" " BackSpaceに割り当て
" inoremap <silent> <BS> <C-R>=DeleteParenthesesAdjoin()<CR>
