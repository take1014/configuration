set clipboard=unnamedplus   "クリップボードを共有

"** ビープ音を無効にする **
set visualbell t_vb=
set noerrorbells 					"エラーメッセージの表示時にビープを鳴らさない

"** バックアップファイルの設定 **
set nobackup						"バックアップを取らない
set nowritebackup					"ファイル上書き時にバックアップを取らない
set noswapfile                      "swpの作成無効化

"** 半角文字の設定 **
set guifont=Ricty\ 12

"** 全角文字の設定 **
set guifontwide=Ricty\ 12
"g  オプション vimrc
"** 文字コード設定 **
set encoding=utf-8                  "エンコード設定
set fileencoding=utf-8              "保存するファイル
set fencs=iso-2022-jp,enc-jp,cp932  "開くファイル

"** 表示設定 **
syntax on                           "ハイライト表示
set notitle                         "タイトル
set number                          "行番号
set ruler							"ルーラーの設定
set nowrap							"折り返し設定
highlight Comment ctermfg=green
"** カラースキーマ設定 **
set t_Co=256
colorscheme jellybeans

"** 検索 **
set incsearch						"インクリメンタルサーチを有効
set hlsearch						"検索結果をハイライト表示
set wrapscan						"最終行まで検索したら先頭に戻る
set ignorecase 						"大文字と小文字を区別しない
set smartcase						"大文字と小文字が混在した言葉で検索を行った場合に限り、大文字と小文字を区別する

"** 置換 **
set gdefault 						"置換の時 g オプションをデフォルトで有効にする

"** GUIオプション **
set  guioptions-=m
set  guioptions-=T

"** statusline **
set statusline=%F
set laststatus=2

" 行末のスペースをハイライト表示
augroup HighlightTrailingSpaces
  autocmd!
    autocmd VimEnter,WinEnter,ColorScheme * highlight TrailingSpaces term=underline guibg=Red ctermbg=Red
      autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
augroup END

"** タブ、インデントの設定 **
set tabstop=4                       "タブ文字幅
set shiftwidth=4                    "インデント幅
set expandtab	                    "挿入モードでタブ文字有効
set smartindent						"インデントの自動調整
set smarttab						"コンテキストに応じたタブの設定
set ai						        "改行時に自動でインデント

"** 強調表示 **
set cursorline						"カーソル行を強調表示
set cursorcolumn					"現在の行を強調表示
set showmatch						"対応する括弧を強調表示
set showcmd							"入力中のコマンドを表示

"** ファイル別設定 **
filetype on
autocmd FileType c,cpp,perl,html set cindent

"grep時にquickfixウィンドウを開く
autocmd QuickfixCmdPost make,grep,grepadd,vimgrep if len(getqflist()) != 0 | copen | endif

"行末のスペース削除
autocmd BufWritePre * :%s/\s\+$//ge

" ** IME **
function! ImInActivate()
  call system('fcitx-remote -c')
endfunction
inoremap <silent> <C-[> <ESC>:call ImInActivate()<CR>

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
