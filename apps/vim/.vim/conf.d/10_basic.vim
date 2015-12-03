"######################################################################
"   basic.vim
"           基本設定
"           エディタ機能やVim自体の動作に関わる設定を行う
"######################################################################

" UTF-8をデフォルト文字コードセットに設定
set enc=utf-8
" ビープ音を鳴らさない
set vb t_vb=
" Backspace を有効にする
set backspace=indent,eol,start
" 自動読み直し
set autoread
" ターミナル時でもマウスを使えるようにする
set mouse=a
set guioptions+=a
set ttymouse=xterm2
" C-vの矩形選択で行末より後ろもカーソルを置ける
set virtualedit=block

" ~/.vim/backupをバックアップ先ディレクトリに指定する
set backup
set backupdir=$HOME/.vim/backup
let &directory = &backupdir
" Undoファイルの出力先を設定
set undodir=$HOME/.vim/undo


" インクリメンタルサーチを有効にする
set incsearch
" 検索結果のハイライト表示を有効にする
set hlsearch
" 大文字と小文字を区別しない
set ignorecase
" ビジュアルモード選択した部分を*で検索
vnoremap * "zy:let @/ = @z<CR>n
" 検索時に大文字を含んでいたら大/小を区別
"set smartcase


" ヤンクした際にクリップボードへ配置する
let OSTYPE = system('uname')
if OSTYPE == "Darwin\n"
    " For Mac
    " set clipboard+=unnamed,autoselect
    " set clipboard=unnamed,autoselect
    set clipboard=unnamed
elseif OSTYPE == "Linux\n"
    " For Linux
    " set clipboard=unnamed,autoselect
    set clipboard=unnamed
    set clipboard=unnamedplus
    vmap <C-c> :w !xsel -ib<CR><CR>
    vmap <C-y> :w !xsel -ib<CR><CR>
endif
" カーソルの下の単語をヤンクした文字列で置換
nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
nnoremap <silent> cy   ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
vnoremap <silent> cy   c<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
" 挿入モードからノーマルモードに戻る時にペーストモードを自動で解除
autocmd InsertLeave * set nopaste


" Ｃ言語スタイルのインデントを使用する
set cindent
" ファイル中の<TAB>を見た目4文字に展開する(既に存在する<TAB>の見た目の設定)
set tabstop=4
" インデントやシフトオペレータで挿入/削除されるインデントの幅を4文字分にする
set shiftwidth=4
" TABキーを押した際に挿入される空白の量を0文字分にする
set softtabstop=0
" <TAB>を空白スペース文字に置き換える
set expandtab
" オートインデント
set autoindent
" 賢いインデント
set smartindent
"フォーマット揃えをコメント以外有効にする
set formatoptions-=c

" コマンド補完機能
" set wildmenu
" zsh like な補完に
" set wildmode=longest,list:longest


" =============================================
" Plugin 設定 NERDTree
" 隠しファイルをデフォルトで表示させる
let NERDTreeShowHidden = 1
" デフォルトでツリーを表示させる
autocmd VimEnter * execute 'NERDTree'
"<C-e>でNERDTreeをオンオフ
" map <silent> <C-e>   :NERDTreeToggle<CR>
" lmap <silent> <C-e>  :NERDTreeToggle<CR>
nmap <silent> <C-e>      :NERDTreeToggle<CR>
vmap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
omap <silent> <C-e>      :NERDTreeToggle<CR>
imap <silent> <C-e> <Esc>:NERDTreeToggle<CR>

