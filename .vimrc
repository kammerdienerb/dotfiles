""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""" Basic Settings """""""""""""""""""""""""""""""" 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Don't try to be vi compatible
set nocompatible

" Turn on syntax highlighting
syntax on

" Show line numbers
set number relativenumber

" Highlight the current line differently
set cursorline

" Show last command
set showcmd

" Splits go to the right or down
set splitright
set splitbelow

" Blink cursor on error instead of beeping
set visualbell

" Encoding
set encoding=utf-8

" Whitespace and indentation
set wrap linebreak nolist
set breakindent
let &showbreak="  ↳"
" let &showbreak=  "  ⋯"
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround
set autoindent
set smartindent
filetype indent on

" Cursor motion
set scrolloff=3
set backspace=indent,eol,start

" Don't use the mouse
set mouse=

" Wildmenu
set wildmenu

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""" Key mappings and commands """""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = " "
nnoremap <space> <nop>
inoremap jj <esc>
cnoremap jj <c-f>
command W w
command Q q
cnoremap Q! q!
command Wq wq

" Move up/down editor lines
nnoremap <silent> j gj
nnoremap <silent> k gk

" system clipboard
map <silent> <c-y> "+y
map <silent> <c-p> "+p

" Remote editing
nnoremap <leader>er :edit scp://
nnoremap <leader>vr :vsp  scp://

" Word count
xnoremap <leader>wc g<C-g>:<C-U>echo v:statusmsg<CR>

" Compile error checking
function Make_Check()
    let output = system("make check 2>&1")
    if v:shell_error == 0
        echo "No Errors"
    else
        let nocolor = system("echo " . shellescape(output) . " | perl -pe 's/\x1b\[[0-9;]*m//g'")
        echo nocolor
    endif
endfunction

nnoremap <silent> <leader>mc :call Make_Check()<CR>

" Spell check toggle
function! Toggle_sc()
    if exists('b:use_spell_check')
        if b:use_spell_check == 1
            setlocal nospell
            let b:use_spell_check = 0
            echo("Spell check off")
        else
            setlocal spell spelllang=en_us
            let b:use_spell_check = 1
            echo("Spell check on")
        endif
    else
        setlocal spell spelllang=en_us
        let b:use_spell_check = 1
        echo("Spell check on")
    endif
endfunction

noremap <silent> <leader>sc :call Toggle_sc()<cr>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""" Navigation """"""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Buffers
nnoremap <silent> <c-l> :bn<cr>
nnoremap <silent> <c-h> :bp<cr>
set wildcharm=<c-l>
cnoremap <c-h> <s-tab>

fu! Buff_menu()
    if len(getbufinfo({'buflisted':1})) > 1
        call feedkeys(":buffer [Z")
    else
        echo "No other buffers"
    endif
endfu

nnoremap <silent> <leader>b :call Buff_menu()<cr>

" Files
nnoremap <leader>f :find <c-l><s-tab>

" Content
fu! Ggrepper(pattern)
    execute(":noautocmd vimgrep /" . a:pattern . "/j *")
    execute(":copen")
endfu

command! -nargs=+ Grep execute 'silent grep! -Irn . -e <args>' | copen | execute 'silent /<args>'

nnoremap <leader>g :Grep 

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""" Searching """"""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set incsearch
set smartcase
set showmatch
set hlsearch
nohl

let g:check_search_hl = 0

fu! Disable_search_hl()
    if g:check_search_hl == 1
        let g:check_search_hl = 0
        set nohlsearch
        redraw
    endif
endfu

fu! Restore_Disable_search_hl()
    augroup HLSearch
        au HLSearch CursorMoved * :call Disable_search_hl()
        au HLSearch InsertEnter * :call Disable_search_hl()
    augroup end
endfu

call Restore_Disable_search_hl()

fu! Skip_once_Disable_search_hl()
    au! HLSearch
    augroup HLSearch
        au HLSearch CursorMoved * :call Restore_Disable_search_hl()
        au HLSearch InsertEnter * :call Restore_Disable_search_hl()
    augroup end
endfu

fu! Enable_search_hl()
    let g:check_search_hl = 1
    set hlsearch
    redraw
endfu

fu! Keys_with_hl(key)
    call feedkeys(a:key, 'n')
    call Enable_search_hl()
    call Skip_once_Disable_search_hl()
endfu

fu! Search_with_hl()
    let @/ = ""
    call Keys_with_hl("/")
endfu

nnoremap <silent> /  :call Search_with_hl()<cr>
nnoremap <silent> n  :call Keys_with_hl("n")<cr>
nnoremap <silent> N  :call Keys_with_hl("N")<cr>
nnoremap <silent> *  :call Keys_with_hl("*")<cr>
nnoremap <silent> #  :call Keys_with_hl("#")<cr>
nnoremap <silent> g* :call Keys_with_hl("g*")<cr>
nnoremap <silent> g# :call Keys_with_hl("g#")<cr>

function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""" Appearance """""""""""""""""""""""""""""""""" 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" in case we're in TMUX
let &t_8f = "[38;2;%lu;%lu;%lum"
let &t_8b = "[48;2;%lu;%lu;%lum"

color iceberg

if has('termguicolors')
    set termguicolors
endif

" Statusline
set noshowmode
set noruler
set laststatus=2

fu! Visual_mode_kind()
    let l:m = mode()
    if l:m == 'v'
        return 'v'
    elseif l:m == 'V'
        return 'l'
    elseif l:m == ""
        return 'b'
    endif

    return ''
endfu

set statusline=
set statusline+=%#SpellCap#%{(mode()=='n')?'\ \ NORMAL\ ':''}
set statusline+=%#SpellLocal#%{(mode()=='i')?'\ \ INSERT\ ':''}
set statusline+=%#SpellBad#%{(mode()=='R')?'\ \ RPLACE\ ':''}
set statusline+=%#SpellRare#%{(Visual_mode_kind()=='v')?'\ \ VISUAL\ ':''}
set statusline+=%#SpellRare#%{(Visual_mode_kind()=='l')?'\ \ V-LINE\ ':''}
set statusline+=%#SpellRare#%{(Visual_mode_kind()=='b')?'\ \ V-BLCK\ ':''}
set statusline+=%#IncSearch#     " colour
set statusline+=\ %t\                   " short file name
set statusline+=%=                          " right align
set statusline+=%#IncSearch#   " colour
set statusline+=\ %Y\                   " file type
set statusline+=%#SpellCap#     " colour
set statusline+=\ %3l::%-3c\         " line + column
set statusline+=%#IncSearch#       " colour
set statusline+=\ %3p%%\                " percentage

" Tabular
" Roll my own completion? With toggle
" LaTeX 
" Commenting
