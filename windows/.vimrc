﻿" plug.vim settings
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

set termguicolors

"挙動を vi 互換ではなく、Vim のデフォルト設定にする設定
set nocompatible

"画面表示関係
colorscheme jellybeans              " カラースキーム設定
set number                          " 行番号の設定
" set guifont=Ricty:h8.5:cSHIFTJIS    " フォント設定
set guifont=Inconsolata:h8
set guifontwide=Migu\ 1M:h8
set cursorline                      " カーソルラインの色を変更する
hi clear CursorLine                 " カーソルラインの色をクリアに設定
set nowrap                          " 折り返さない

" ファイル処理関連の設定
set confirm         " 保存されていないファイルがあるときは終了前に保存確認
set hidden          " 保存されていないファイルがあるときでも別のファイルを開くことが出来る
set autoread        " 外部でファイルに変更がされた場合は読みなおす
set nobackup        " ファイル保存時にバックアップファイルを作らない
set noswapfile      " ファイル編集中にスワップファイルを作らない
set viminfo=        " viminfoファイルを作成しない
set noundofile      " undoファイルを作成しない
set autochdir	    " ﾌｧｲﾙを置いているﾌｫﾙﾀﾞをｶﾚﾝﾄとする.

" タブ/インデントの設定
set smartindent     " 改行時に自動でインデント
set tabstop=4       " 画面上でタブ文字が占める幅
set shiftwidth=4    " 自動インデントでずれる幅
autocmd FileType c,cpp,cc,h set tabstop=2
autocmd FileType c,cpp,cc,h set shiftwidth=2
set expandtab       " タブ入力を複数の空白入力に置き換える
set autoindent	    " 改行時に前の行のインデントを継続する
set softtabstop=4   " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set formatoptions=q " 自動で改行を許可しない

"検索/置換の設定
set hlsearch        " 検索文字列をハイライトする
set incsearch       " インクリメンタルサーチを行う
set ignorecase      " 大文字と小文字を区別しない
set smartcase       " 大文字と小文字が混在した言葉で検索を行った場合に限り、大文字と小文字を区別する
set wrapscan        " 最後尾まで検索を終えたら次の検索で先頭に移る
set gdefault        " 置換の時 g オプションをデフォルトで有効にする

" 動作環境との統合関連の設定
" OSのクリップボードをレジスタ指定無しで Yank, Put 出来るようにする
set clipboard=unnamed,unnamedplus
" インサートモードから抜けると自動的にIMEをオフにする
set iminsert=0

map <silent> <ESC> <ESC>:set iminsert=0<CR>
"デフォルトは半角入力
"set imdisable

"ビープの設定
"ビープ音すべてを無効にする
set visualbell t_vb=
set noerrorbells "エラーメッセージの表示時にビープを鳴らさない

" statusline
set statusline=%F
set laststatus=2
set notitle

set guioptions-=T                   "ツールバーを非表示
set guioptions-=m                   "メニューバーを非表示
set guioptions+=c                   "簡単な質問をポップアップダイアログではなく、コンソールを使うようにする。
set guioptions+=M                   "$VIMRUNTIME/menu.vim"を読み込まない。
