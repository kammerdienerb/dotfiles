" Don't try to be vi compatible
set nocompatible

" Turn on syntax highlighting
syntax on
" Show line numbers
" set number relativenumber
set number relativenumber

set cursorline

" Last line
set showmode
set showcmd

" Splits go to the right or down
set splitright
set splitbelow

" Show file stats
set ruler

" Blink cursor on error instead of beeping
set visualbell

" Encoding
set encoding=utf-8

" Whitespace
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

" General key mappings and commands
nnoremap <space> <nop>
let maplocalleader = " "
inoremap jj <esc>
cnoremap jj <c-f>
nnoremap <silent> <c-l> :bn <CR>
nnoremap <silent> <c-h> :bp <CR>
command W w
command Q q
cnoremap Q! q!
command Wq wq

nnoremap <leader>er :edit scp://
nnoremap <leader>vr :vsp  scp://

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

" system clipboard
map <silent> <c-y> "+y
map <silent> <c-p> "+p

" Cursor motion
set scrolloff=3
set backspace=indent,eol,start

" Move up/down editor lines
nnoremap j gj
nnoremap k gk

" Don't use the mouse
set mouse=

" Wildmenu
set wildmenu

" Searching
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

nnoremap /  :call Search_with_hl()<cr>
nnoremap n  :call Keys_with_hl("n")<cr>
nnoremap N  :call Keys_with_hl("N")<cr>
nnoremap *  :call Keys_with_hl("*")<cr>
nnoremap #  :call Keys_with_hl("#")<cr>
nnoremap g* :call Keys_with_hl("g*")<cr>
nnoremap g# :call Keys_with_hl("g#")<cr>
