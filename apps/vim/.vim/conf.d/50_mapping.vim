"######################################################################
" mapping.vim
"      Vim/gVim共通で使用するキーバインドを定義する
"      unite関連の設定は uniterc.vim で行なっている
"######################################################################

" .vimrcを編集する
command! Ev edit $MYVIMRC

" .vimrcを再読み込みする
command! Rv source $MYVIMRC

" バックアップディレクトリを開く
map qb :tabe $HOME/.vim/backup<ENTER> 

" 開いているファイルのディレクトリをカレントにする
map q\ :cd %:h<Enter><Enter>

" 現在行をコメント化 (/* */)
map qq 0i/* <ESC>$a */<ESC>

" 現在行をコメント化 (//)
map q/ 0i//<ESC>

" 開いているファイルのディレクトリをリスティング
map qd :e %:h<Enter>

" 新規タブを開く
map qt :tabnew<ENTER>

" エンコード指定の再読み込みメニューの表示
map q9 <ALT-F>ere

" 開いているファイルで JavascriptLint を実行
" map qj :! C:\Users\hogeuser\DOC\tools\jsl-0.3.0\jsl -process %<ENTER>

" 次のタブ
map <C-TAB> :tabn<Enter>

" Tlistを表示
map tl :Tlist<Enter>

" 開いているファイルのパスをコピー
map qp :CopyPath<Enter>

" 次の要素
map <C-n> :cn<Enter>

" １つ前の要素
map <C-p> :cp<Enter>

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

" ハードタブ非表示
map qx :set lcs=tab:  ,trail:_,extends:\<Enter>

" ハードタブ表示
map qz :set lcs=tab:>.,trail:_,extends:\<Enter>


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

" Vimの便利な画面分割＆タブページ
"    http://qiita.com/tekkoc/items/98adcadfa4bdc8b5a6ca
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sn gt
nnoremap sp gT
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap sT :<C-u>Unite tab<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sQ :<C-u>bd<CR>
nnoremap sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
nnoremap sB :<C-u>Unite buffer -buffer-name=file<CR>

call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
call submode#map('bufmove', 'n', '', '>', '<C-w>>')
call submode#map('bufmove', 'n', '', '<', '<C-w><')
call submode#map('bufmove', 'n', '', '+', '<C-w>+')
call submode#map('bufmove', 'n', '', '-', '<C-w>-')
