" github_dark: derived from Ghostty's bundled "GitHub Dark" terminal theme
" (config/ghostty/config, also used by hunk via config/hunk/config.toml),
" so Vim's palette lines up with the rest of the terminal.

hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'github_dark'

let s:fg      = ['#8b949e', 246] " ghostty foreground
let s:dim     = ['#4d4d4d', 239] " ghostty palette 8 (bright black)
let s:red     = ['#f78166', 209] " ghostty palette 1/9
let s:green   = ['#56d364', 78]  " ghostty palette 2/10
let s:yellow  = ['#e3b341', 179] " ghostty palette 3/11
let s:blue    = ['#6ca4f8', 111] " ghostty palette 4/12
let s:magenta = ['#db61a2', 169] " ghostty palette 5/13
let s:cyan    = ['#2b7489', 23]  " ghostty palette 6/14
let s:white   = ['#ffffff', 231] " ghostty palette 7/15
let s:cursor  = ['#c9d1d9', 253] " ghostty cursor-color
let s:selbg   = ['#3b5070', 60]  " ghostty selection-background
let s:panel   = ['#161b22', 235] " GitHub's canonical elevated dark surface
let s:bg      = ['#101216', 234] " ghostty background

function! s:Hi(group, fg, bg, attr) abort
  let l:cmd = 'hi ' . a:group
  if !empty(a:fg)
    let l:cmd .= ' guifg=' . a:fg[0] . ' ctermfg=' . a:fg[1]
  endif
  if !empty(a:bg)
    let l:cmd .= ' guibg=' . a:bg[0] . ' ctermbg=' . a:bg[1]
  else
    let l:cmd .= ' guibg=NONE ctermbg=NONE'
  endif
  if a:attr !=# ''
    let l:cmd .= ' gui=' . a:attr . ' cterm=' . a:attr
  endif
  execute l:cmd
endfunction

" UI, left transparent so Ghostty's background/opacity/blur shows through
call s:Hi('Normal', s:fg, '', '')
call s:Hi('NonText', s:dim, '', '')
call s:Hi('EndOfBuffer', s:dim, '', '')
call s:Hi('LineNr', s:dim, '', '')
call s:Hi('CursorLineNr', s:yellow, '', 'bold')
call s:Hi('CursorLine', '', s:panel, '')
call s:Hi('SignColumn', '', '', '')
call s:Hi('FoldColumn', s:dim, '', '')
call s:Hi('Folded', s:dim, s:panel, '')
call s:Hi('ColorColumn', '', s:panel, '')
call s:Hi('VertSplit', s:panel, '', '')
call s:Hi('WinSeparator', s:panel, '', '')
call s:Hi('StatusLine', s:fg, s:panel, '')
call s:Hi('StatusLineNC', s:dim, s:panel, '')
call s:Hi('TabLine', s:dim, s:panel, '')
call s:Hi('TabLineFill', '', s:panel, '')
call s:Hi('TabLineSel', s:white, s:selbg, 'bold')
call s:Hi('Pmenu', s:fg, s:panel, '')
call s:Hi('PmenuSel', s:white, s:selbg, '')
call s:Hi('PmenuSbar', '', s:panel, '')
call s:Hi('PmenuThumb', '', s:selbg, '')
call s:Hi('WildMenu', s:white, s:selbg, '')
call s:Hi('Visual', '', s:selbg, '')
call s:Hi('VisualNOS', '', s:selbg, '')
call s:Hi('Search', s:bg, s:yellow, '')
call s:Hi('IncSearch', s:bg, s:yellow, 'bold')
call s:Hi('MatchParen', s:white, s:selbg, 'bold')
call s:Hi('Cursor', s:bg, s:cursor, '')
call s:Hi('Directory', s:blue, '', '')
call s:Hi('Title', s:blue, '', 'bold')
call s:Hi('ModeMsg', s:green, '', '')
call s:Hi('MoreMsg', s:green, '', '')
call s:Hi('Question', s:green, '', '')
call s:Hi('WarningMsg', s:yellow, '', '')
call s:Hi('ErrorMsg', s:white, s:red, '')
call s:Hi('QuickFixLine', '', s:panel, '')

" Diff
call s:Hi('DiffAdd', s:green, s:panel, '')
call s:Hi('DiffChange', s:yellow, s:panel, '')
call s:Hi('DiffDelete', s:red, s:panel, '')
call s:Hi('DiffText', s:white, s:selbg, 'bold')

" Spelling
call s:Hi('SpellBad', s:red, '', 'undercurl')
call s:Hi('SpellCap', s:blue, '', 'undercurl')
call s:Hi('SpellLocal', s:cyan, '', 'undercurl')
call s:Hi('SpellRare', s:magenta, '', 'undercurl')

" Syntax
call s:Hi('Comment', s:dim, '', 'italic')
call s:Hi('Constant', s:yellow, '', '')
call s:Hi('String', s:green, '', '')
call s:Hi('Character', s:green, '', '')
call s:Hi('Number', s:yellow, '', '')
call s:Hi('Boolean', s:yellow, '', '')
call s:Hi('Float', s:yellow, '', '')
call s:Hi('Identifier', s:blue, '', '')
call s:Hi('Function', s:magenta, '', '')
call s:Hi('Statement', s:red, '', '')
call s:Hi('Conditional', s:red, '', '')
call s:Hi('Repeat', s:red, '', '')
call s:Hi('Label', s:red, '', '')
call s:Hi('Operator', s:cyan, '', '')
call s:Hi('Keyword', s:red, '', '')
call s:Hi('Exception', s:red, '', '')
call s:Hi('PreProc', s:magenta, '', '')
call s:Hi('Include', s:magenta, '', '')
call s:Hi('Define', s:magenta, '', '')
call s:Hi('Macro', s:magenta, '', '')
call s:Hi('PreCondit', s:magenta, '', '')
call s:Hi('Type', s:blue, '', '')
call s:Hi('StorageClass', s:blue, '', '')
call s:Hi('Structure', s:blue, '', '')
call s:Hi('Typedef', s:blue, '', '')
call s:Hi('Special', s:cyan, '', '')
call s:Hi('SpecialChar', s:cyan, '', '')
call s:Hi('Tag', s:cyan, '', '')
call s:Hi('Delimiter', s:fg, '', '')
call s:Hi('SpecialComment', s:dim, '', 'italic')
call s:Hi('Debug', s:red, '', '')
call s:Hi('Underlined', s:blue, '', 'underline')
call s:Hi('Ignore', s:dim, '', '')
call s:Hi('Error', s:white, s:red, '')
call s:Hi('Todo', s:bg, s:yellow, 'bold')

delfunction s:Hi
