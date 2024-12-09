syntax on

" clipboard setting
if has("unix") && !has("macunix")
  " linux
  set clipboard=unnamedplus
elseif has("macunix")
  " macOSX
  set clipboard=unnamed,autoselect
endif

" beep sound
set visualbell t_vb=
set noerrorbells

" backup file
set nobackup
set nowritebackup
set noswapfile

" font and encoding
set encoding=utf-8
set fileencoding=utf-8
set fencs=iso-2022-jp,enc-jp,cp932

" window
set notitle
set number
set ruler
set nowrap
" tab settings
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set smarttab
set ai
highlight Comment ctermfg=green

" color scheme
set t_Co=256
silent! colorscheme jellybeans

" search option
set incsearch
set hlsearch
set wrapscan
set ignorecase
set smartcase

" replacement
set gdefault

" Backspace behaviour
set backspace=indent,eol,start

"** statusline **
set statusline=%F
set laststatus=2
set cursorline
set cursorcolumn
set showmatch
set showcmd
" plug.vim settings
" if unix
"curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" else if windows
"iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
"    ni $HOME/vimfiles/autoload/plug.vim -Force
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
" Color scheme
Plug 'nanotech/jellybeans.vim'
" NERDTree
Plug 'scrooloose/nerdtree'
" vim-lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
" auto complete
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
" grep
Plug 'rking/ag.vim'
" hightlight
Plug 'sheerun/vim-polyglot'
" autocomplete '',"",() etc...
Plug 'cohama/lexima.vim'
" comment
Plug 'tpope/vim-commentary'
" Initialize plugin system
call plug#end()

" Diagnostics and Highlight references settings for vim-lsp
let g:lsp_document_highlight_enabled = 0
let g:lsp_diagnostics_enabled = 0         " disable diagnostics support
let g:lsp_signs_enabled = 0
