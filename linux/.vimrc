"jedi-vimのプレビューウィンドウを消す
set completeopt=menuone

" Ctrl + hjkl でウィンドウ間を移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Shift + 矢印でウィンドウサイズを変更
nnoremap <S-h> <C-w>>
nnoremap <S-j> <C-w><
nnoremap <S-k> <C-w>+
nnoremap <S-l> <C-w>-

set nocompatible					"vim互換
set clipboard=unnamed,autoselect   "クリップボードを共有

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
set title                           "タイトル
set number                          "行番号
set ruler							"ルーラーの設定
set nowrap							"折り返し設定
highlight Comment ctermfg=green
"** カラースキーマ設定 **
set t_Co=256
colorscheme jellybeans
"let g:molokai_original=1
set background=dark

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

" 行末のスペースをハイライト表示
augroup HighlightTrailingSpaces
  autocmd!
    autocmd VimEnter,WinEnter,ColorScheme * highlight TrailingSpaces term=underline guibg=Red ctermbg=Red
      autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
augroup END

" タブの可視化
set listchars=tab:≫-

"** タブ、インデントの設定 **
set tabstop=4                       "タブ文字幅
set shiftwidth=4                    "インデント幅
set expandtab	                    "挿入モードでタブ文字有効
set smartindent						"インデントの自動調整
set smarttab						"コンテキストに応じたタブの設定
set autoindent						"改行時に自動でインデント


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

"NeoBundle
"インストールはターミナルで以下のコマンド↓
"mkdir -p ~/.vim/bundle
"git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
"インストール完了後、gvim開いて、NeoBundleInstall
" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!

NeoBundle 'Shougo/vimproc.vim', {
			\ 'build' : {
			\     'windows' : 'tools\\update-dll-mingw',
			\     'cygwin' : 'make -f make_cygwin.mak',
			\     'mac' : 'make',
			\     'linux' : 'make',
			\     'unix' : 'gmake',
			\    },
			\ }
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'tell-k/vim-autopep8'
NeoBundle 'tyru/caw.vim.git'
nmap <Leader>c <Plug>(caw:i:toggle)
vmap <Leader>c <Plug>(caw:i:toggle)
NeoBundle 'sophacles/vim-processing'
NeoBundle 'thinca/vim-quickrun'
let g:quickrun_config = {}
let g:quickrun_config.processing =  {
      \     'command': 'processing-java',
      \     'exec': '%c --sketch=$PWD/ --output=/Library/Processing --run --force',
      \   }
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'taichouchou2/html5.vim'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'lilydjwg/colorizer'
NeoBundle 'tpope/vim-fugitive'
"検索速度上げる
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'rking/ag.vim'
"カラースキーム(jellybeans.vim)
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'scrooloose/nerdtree'
" コメントON/OFFを手軽に実行 <Ctrl+_>x2
NeoBundle 'tomtom/tcomment_vim'
:set statusline+=%{fugitive#statusline()}
" NeoBundle 'itchyny/lightline.vim'
" NeoBundle 'taketwo/vim-ros'
" taglist
NeoBundle 'vim-scripts/taglist.vim'
NeoBundle 'szw/vim-tags'
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.

" カレントディレクトリからホームディレクトリまでtagsを探す
set tags=.tags;~
function! s:execute_ctags() abort
  " 探すタグファイル名
  let tag_name = '.tags'
  " ディレクトリを遡り、タグファイルを探し、パス取得
  let tags_path = findfile(tag_name, '.;')
  " タグファイルパスが見つからなかった場合
  if tags_path ==# ''
    return
  endif

  " タグファイルのディレクトリパスを取得
  " `:p:h`の部分は、:h filename-modifiersで確認
  let tags_dirpath = fnamemodify(tags_path, ':p:h')
  " 見つかったタグファイルのディレクトリに移動して、ctagsをバックグラウンド実行（エラー出力破棄）
  execute 'silent !cd' tags_dirpath '&& ctags -R -f' tag_name '2> /dev/null &'
endfunction

augroup ctags
  autocmd!
  autocmd BufWritePost * call s:execute_ctags()
augroup END

" taglist
let Tlist_Ctags_Cmd = "/usr/bin/ctags"
let Tlist_Show_One_File = 1
let Tlist_Use_Right_Window = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Auto_Highlight_Tag = 1
let Tlist_WinWidth = 40
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Display_Tag_Scope = 1

"ag
" insert modeで開始
let g:unite_enable_start_insert = 0

" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

" grep検索
nnoremap <silent> ,g  :<C-u>Unite grep: -buffer-name=search-buffer<CR>
" カーソル位置の単語をgrep検索
nnoremap <silent> ,cg :<C-u>Unite grep: -buffer-name=search-buffer<CR><C-R><C-W>
" grep検索結果の再呼出
nnoremap <silent> ,r  :<C-u>UniteResume search-buffer<CR>

" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif
