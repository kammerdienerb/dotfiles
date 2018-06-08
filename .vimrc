" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

" Plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
 " better find on line
Plug 'justinmk/vim-sneak'
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
Plug 'maralla/completor.vim'
let g:completor_clang_binary = 'clang'
" if has('nvim')
"   Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" else
"   Plug 'Shougo/deoplete.nvim'
"   Plug 'roxma/nvim-yarp'
"   Plug 'roxma/vim-hug-neovim-rpc'
" endif
" let g:deoplete#enable_at_startup = 1
" neodark colorscheme
Plug 'KeitaNakamura/neodark.vim'
let g:neodark#use_256color = 1
let g:neodark#terminal_transparent = 1
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
" let &showbreak="  ↳"
let &showbreak=  "  ⋯"
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

" Use the mouse
set mouse=a

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
set background=dark

color neodark

" Solarized
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1
" put https://raw.github.com/altercation/vim-colors-solarized/master/colors/solarized.vim
" in ~/.vim/colors/ and uncomment:
" colorscheme solarized
