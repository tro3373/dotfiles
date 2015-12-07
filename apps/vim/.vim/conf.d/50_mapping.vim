"######################################################################
" mapping.vim
"      Vim/gVim共通で使用するキーバインドを定義する
"######################################################################
" .vimrcを編集する
command! Editvimrc edit $MYVIMRC
" .vimrcを再読み込みする
command! Reloadvimrc source $MYVIMRC

" 表示上の行移動(エディタで表示されている行)であるgj,gkと、
" 実際の行移動(エディタの表示行ではなく改行コードを意識した実際の行)であるj,kを入れ替え
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
" <Space>h で先頭、<Space>l で行末へ
noremap <Space>h  ^
noremap <Space>l  $


" s prefix 設定
" Vimの便利な画面分割＆タブページ
"    http://qiita.com/tekkoc/items/98adcadfa4bdc8b5a6ca
nnoremap s <Nop>
" ウィンドウ間移動
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
" ウィンドウ入れ替え
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
"" ウィンドウ回転
"nnoremap sr <C-w>r
" ウィンドウ幅調整
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
call submode#map('bufmove', 'n', '', '>', '<C-w>>')
call submode#map('bufmove', 'n', '', '<', '<C-w><')
call submode#map('bufmove', 'n', '', '+', '<C-w>+')
call submode#map('bufmove', 'n', '', '-', '<C-w>-')
" タブ移動
nnoremap sn gt
nnoremap sp gT
" 終了コマンド
nnoremap sq :<C-u>q<CR>
nnoremap sQ :<C-u>bd<CR>


"=============================================
" Unite 設定
"=============================================
"" 入力モードで開始する
"let g:unite_enable_start_insert = 1
" 画面分割(縦分割)
nnoremap ss :<C-u>sp<CR>
" 画面分割(横分割)
nnoremap sv :<C-u>vs<CR>
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>:<C-u>UniteWithBufferDir -buffer-name=files file_mru file buffer bookmark<CR>
" タブ一覧
nnoremap sT :<C-u>Unite tab<CR>
nnoremap sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
nnoremap sB :<C-u>Unite buffer -buffer-name=file<CR>
" ファイル一覧
nnoremap sf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap sr :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap sm :<C-u>Unite file_mru<CR>
 " 全部乗せ
nnoremap sa :<C-u>UniteWithBufferDir -buffer-name=files file_mru file buffer bookmark<CR>
" unite.vim上でのキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
    " 単語単位からパス単位で削除するように変更
    imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

    " ESCキーを2回押すと終了する
    nmap <silent><buffer> <ESC><ESC> q
    imap <silent><buffer> <ESC><ESC> <ESC>q
endfunction


" カーソルの下の単語をヤンクした文字列で置換
nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
nnoremap <silent> cy   ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
vnoremap <silent> cy   c<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
" ビジュアルモード選択した部分を*で検索
vnoremap * "zy:let @/ = @z<CR>n


" 現在行をコメント化 (/* */)
map qq 0i/* <ESC>$a */<ESC>
" 現在行をコメント化
map s/ 0i// <ESC>
map s# 0i# <ESC>
map s- 0i-- <ESC>


" ハードタブ非表示
map sx :set lcs=tab:  ,trail:_,extends:\<Enter>
" ハードタブ表示
map sz :set lcs=tab:>.,trail:_,extends:\<Enter>
" 開いているファイルのディレクトリをリスティング
map sd :e %:h<Enter>
map qd :e %:h<Enter>
" 開いているファイルのパスをコピー
map sc :CopyPath<Enter>
" 開いているファイルのディレクトリをカレントにする
map s\ :cd %:h<Enter><Enter>
" バックアップディレクトリを開く
map sba :tabe $HOME/.vim/backup<ENTER>




" Tlistを表示
map tl :Tlist<Enter>
" 次の要素
map <C-n> :cn<Enter>
" １つ前の要素
map <C-p> :cp<Enter>
" エンコード指定の再読み込みメニューの表示
map q9 <ALT-F>ere
"" 新規タブを開く
"map qt :tabnew<ENTER>
"" 次のタブ
"map <C-TAB> :tabn<Enter>



" カーソル位置の単語を Gtags で検索
map <C-]> :GtagsCursor<Enter>
" 要素名を指定して Gtags で検索
map <C-t> :Gtags -f %<Enter>
" Gtagsのタグファイルを作成
map <C-g> :Gtags
" Gtagsで山椒検索
map <C-@> :Gtags -r


" make実行
map qm :!make<Enter>
" 開いているファイルで JavascriptLint を実行
" map qj :! C:\Users\hogeuser\DOC\tools\jsl-0.3.0\jsl -process %<ENTER>


" 開いているファイルのディレクトリをエクスプローラで開く
if has("win32") || has("win64")
    " Windows
    "map qn :!nautilus %:h<ENTER> 

elseif has("win32Unix")
    " Cygwin
    "map qn :!nautilus %:h<ENTER> 

elseif has("macunix")
    " Mac OS-X
    "map qn :!nautilus %:h<ENTER> 

elseif has("unix")
    " BSD, Linux
    map qn :!nautilus %:h<ENTER> 

else
    " その他
endif


"=============================================
" Plugin 設定 NERDTree
"=============================================
" 隠しファイルをデフォルトで表示させる
let NERDTreeShowHidden = 1
" デフォルトでツリーを表示させる
" autocmd VimEnter * execute 'NERDTree'
"<C-e>でNERDTreeをオンオフ
" map <silent> <C-e>   :NERDTreeToggle<CR>
" lmap <silent> <C-e>  :NERDTreeToggle<CR>
nmap <silent> <C-e>      :NERDTreeToggle<CR>
vmap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
omap <silent> <C-e>      :NERDTreeToggle<CR>
imap <silent> <C-e> <Esc>:NERDTreeToggle<CR>

