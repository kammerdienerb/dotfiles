" Don't try to be vi compatible
set nocompatible

" helps force plugins to load correctly when it is turned back on below
filetype off

let mapleader = " "

" https://github.com/vim/vim/issues/3117
if has('python3')
  silent! python3 1
endif

" plugins

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

" autocomplete
Plug 'ncm2/ncm2'

function! Toggle_ac()
    if exists('b:ncm2_enable')
        if b:ncm2_enable == 1
            call ncm2#disable_for_buffer()
        else
            call ncm2#enable_for_buffer()
        endif
    else
        call ncm2#enable_for_buffer()
    endif
endfunction

noremap <silent> <leader>ac :call Toggle_ac()<cr>

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
" nord colorscheme
Plug 'arcticicestudio/nord-vim'
" quantum colorscheme
Plug 'tyrannicaltoucan/vim-quantum'
let g:quantum_black=1
" show buffers in tabline
Plug 'ap/vim-buftabline'
" LaTeX
Plug 'lervag/vimtex'
let g:vimtex_compiler_latexmk = {'callback' : 0}
let g:vimtex_view_method = 'skim'
" fzf fuzzy file finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

tnoremap jj <esc>

nnoremap <silent> <leader>f :call Fzf_files()<CR>
nnoremap <silent> <leader>g :FzfGrep<CR>

" ripgrep
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep

    command! -bang -nargs=* FzfGrep
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color="always" --smart-case --hidden --follow --glob "!.git/*" '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%'),
  \   <bang>0)


endif

" Files
function! Fzf_files()
  let l:fzf_files_options = '--preview "bat --theme="OneHalfDark" --style=numbers,changes --color always "{1..}" | head -'.&lines.'"'

  function! s:files()
    return split(system($FZF_DEFAULT_COMMAND), '\n')
  endfunction

  function! s:edit_file(item)
    execute 'silent e ' a:item
  endfunction

  call fzf#run({
        \ 'source': <sid>files(),
        \ 'sink':   function('s:edit_file'),
        \ 'options': '-m ' . l:fzf_files_options,
        \ 'down':    '40%' })
endfunction

function! Fzf_grep()
    call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case ', 1)
  " call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" | tr -d "\017"', 1, fzf#vim#with_preview('up:60%'), 1)
endfunction

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

" autocmd InsertEnter * set cursorline
" autocmd InsertLeave * set nocursorline

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
set termguicolors
set ttyfast
if &term == "screen"
  set t_Co=256
endif
" disable Background Color Erase (BCE) so that color schemes
" render properly when inside 256-color tmux and GNU screen.
" see also http://snk.tuxfamily.org/log/vim-256color-bce.html
set t_ut=

" Wildmenu
set wildmenu

" Searching
set hlsearch
set incsearch
set smartcase
set showmatch

" Color scheme (terminal)
set background=dark
colorscheme nord

" if $TERM == 'xterm-kitty'
"     if filereadable(expand('~/.config/kitty/kitty.conf'))
"         if system("file -h ~/.config/kitty/kitty.conf | grep -c 'symbolic link'") == "1\n"
"             if system("realpath ~/.config/kitty/kitty.conf | grep -c 'light'") == "1\n"
"                 color stellarized
"             else
"                 set background=dark
"                 color neodark
"             endif
"         endif
"     endif
" else
"     set background=dark
"     color neodark
" endif
