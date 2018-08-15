" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

" https://github.com/vim/vim/issues/3117
if has('python3')
  silent! python3 1
endif

" Plugins

" vvish, my vim shell
source ~/vvish.vim

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
 " better find on line
Plug 'justinmk/vim-sneak'
let g:sneak#label = 1
" alignment
Plug 'godlygeek/tabular'
" asynchronous linting
Plug 'w0rp/ale'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_save = 1
let g:ale_linters = { 'c' : ['clang', 'gcc'], 'cpp' : ['clang', 'gcc'] }
let g:ale_c_gcc_options     = '-std=c99 -Iinclude'
let g:ale_c_clang_options   = '-std=c99 -Iinclude'
let g:ale_cpp_gcc_options   = '-std=c++11 -Iinclude'
let g:ale_cpp_clang_options = '-std=c++11 -Iinclude'
" completion
if !has('nvim')
    Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2'
" enable ncm2 for all buffer
autocmd BufEnter * call ncm2#enable_for_buffer()
" note that must keep noinsert in completeopt, the others is optional
set completeopt=noinsert,menuone,noselect
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-pyclang'
let g:ncm2_pyclang#library_path = substitute(system('dirname $(which llvm-config)'), '\n$', '', '').'/../lib'
" put a .clang_complete in your project path to get better C/C++ completion

" neodark colorscheme
Plug 'KeitaNakamura/neodark.vim'
let g:neodark#use_256color = 1
let g:neodark#terminal_transparent = 1
" stellarized colorscheme
Plug 'nightsense/stellarized'
" show buffers in tabline
Plug 'ap/vim-buftabline'
" LaTeX
Plug 'lervag/vimtex'
let g:vimtex_compiler_latexmk = {'callback' : 0}
let g:vimtex_view_method = 'skim'
" fzf fuzzy file finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
nnoremap <c-f> :Files <CR>
" improved search
Plug 'pgdouyon/vim-evanesco'
" C++ highlighting
Plug 'octol/vim-cpp-enhanced-highlight'
let g:cpp_experimental_template_highlight = 1
" Comment stuff out
Plug 'tpope/vim-commentary'
autocmd FileType bjou setlocal commentstring=#\ %s
" Restore cursor position
Plug 'farmergreg/vim-lastplace'
call plug#end()

" Turn on syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

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
cnoremap jj <esc>
nnoremap <c-l> :bn <CR>
nnoremap <c-h> :bp <CR>
command W w
command Q q
command Wq wq

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

" Rendering
set ttyfast

" Wildmenu
set wildmenu

" Searching
set hlsearch
set incsearch
set smartcase
set showmatch

" Color scheme (terminal)
set t_Co=256

if $TERM == 'xterm-kitty'
    if filereadable(expand('~/.config/kitty/kitty.conf'))
        if system("file -h ~/.config/kitty/kitty.conf | grep -c 'symbolic link'") == "1\n"
            if system("realpath ~/.config/kitty/kitty.conf | grep -c 'light'") == "1\n"
                set termguicolors
                color stellarized
            else
                set background=dark
                color neodark
            endif
        endif
    endif
else
    set background=dark
    color neodark
endif
