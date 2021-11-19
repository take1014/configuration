syntax on

" clipboard setting
set clipboard=unnamed,autoselect

" beep sound
set visualbell t_vb=
set noerrorbells

" backup file
set nobackup
set nowritebackup
set noswapfile

" font and encoding
set guifont=Ricty\ 12
set guifontwide=Ricty\ 12
set encoding=utf-8
set fileencoding=utf-8
set fencs=iso-2022-jp,enc-jp,cp932

" window
set notitle
set number
set ruler
set nowrap
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set smarttab
set ai
highlight Comment ctermfg=green

" color scheme
set t_Co=256
colorscheme jellybeans

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
" taglist
Plug 'vim-scripts/taglist.vim'
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
" pylint
Plug 'scrooloose/syntastic'
" Initialize plugin system
call plug#end()

" Diagnostics and Highlight references settings for vim-lsp
let g:lsp_document_highlight_enabled = 0
let g:lsp_diagnostics_enabled = 0         " disable diagnostics support

" taglist
let Tlist_Ctags_Cmd = "/usr/bin/ctags"
let Tlist_Show_One_File = 1
let Tlist_Use_Right_Window = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Auto_Highlight_Tag = 1
let Tlist_WinWidth = 40
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Display_Tag_Scope = 1
" pylint
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_mode_map = {'mode': 'passive'}
