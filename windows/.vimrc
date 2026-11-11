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

" grep: use ag (the_silver_searcher) for :grep and :Ag when available
if executable('ag')
  set grepprg=ag\ --vimgrep
  set grepformat=%f:%l:%c:%m
  " :Ag passes its arguments to ag as-is (no %/# expansion, | is not a command separator)
  function! s:Ag(args) abort
    let l:efm = &errorformat
    let &errorformat = &grepformat
    try
      cgetexpr system(&grepprg . ' ' . a:args)
    finally
      let &errorformat = l:efm
    endtry
    cwindow
  endfunction
  command! -nargs=+ Ag call s:Ag(<q-args>)
endif

set termguicolors
set nocompatible
silent! colorscheme jellybeans
set number
set guifont=Inconsolata:h8
set guifontwide=Migu\ 1M:h8
set cursorline
hi clear CursorLine
set nowrap

set confirm
set hidden
set autoread
set nobackup
set noswapfile
set viminfo=
set noundofile
set autochdir

set smartindent
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
set softtabstop=2
set formatoptions=q

set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
set gdefault

set clipboard=unnamed,unnamedplus
set iminsert=0

map <silent> <ESC> <ESC>:set iminsert=0<CR>

set visualbell t_vb=
set noerrorbells

" statusline
set statusline=%F
set laststatus=2
set notitle

set guioptions-=T
set guioptions-=m
set guioptions+=c
set guioptions+=M
