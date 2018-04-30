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
" unhighlight search results after movement
Plug 'romainl/vim-cool'
" alignment
Plug 'godlygeek/tabular'
" asyncronous linting
Plug 'w0rp/ale'
" completion
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1
" neodark colorscheme
Plug 'KeitaNakamura/neodark.vim'
let g:neodark#use_256color = 1
let g:neodark#terminal_transparent = 1
" show buffers in tabline
Plug 'ap/vim-buftabline'
call plug#end()

" Turn on syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

" Show line numbers
set number

" Split to the right
set splitright

" Show file stats
set ruler

" Blink cursor on error instead of beeping (grr)
set visualbell

" Encoding
set encoding=utf-8

" Whitespace
set wrap
set textwidth=79
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround
set autoindent
set cindent

" General key mappings and commands
inoremap jj <esc>
cnoremap jj <esc>
nnoremap <c-l> :bn <CR>
nnoremap <c-h> :bp <CR>
command W w
command Q q
command Wq wq

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

" Last line
set showmode
set showcmd

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
