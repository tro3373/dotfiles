let mapleader = "\<Space>"

" 表示上の行移動(エディタで表示されている行)であるgj,gkと、
" 実際の行移動(エディタの表示行ではなく改行コードを意識した実際の行)であるj,kを入れ替え
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
noremap <Down> gj
noremap <Up> gk

" insertモードから抜ける
inoremap <silent> jj <ESC>
" inoremap <silent> <C-j> j
inoremap <silent> kk <ESC>
" inoremap <silent> <C-k> k
" 挿入モードでのカーソル移動
" inoremap <C-j> <Down>
" inoremap <C-k> <Up>
" inoremap <C-h> <Left>
" inoremap <C-l> <Right>

nnoremap <C-u> 10k
nnoremap <C-d> 10j
nnoremap <C-b> 20k
nnoremap <C-f> 20j


nnoremap * *zz
nnoremap g* g*zz
nnoremap g# g#zz
" ビジュアルモード選択した部分を*で検索
vnoremap * "zy:let @/ = @z<CR>nzz
vnoremap " "zy:let @/ = @z<CR>nzz
" " for us keyboard
" nnoremap ; :
" nnoremap : ;
nnoremap " *zz
" nnoremap ' :
nnoremap n nzz
nnoremap N Nzz
nnoremap S *zz

" /検索時の / 入力補完
cnoremap <expr> / (getcmdtype() == '/') ? '\/' : '/'
" /? で検索時に現在の検索する語に単語境界を付与
" /hoge と入力した後に <C-o> を押すと /\<hoge\> に変換
cnoremap <C-o> <C-\>e(getcmdtype() == '' <Bar><Bar> getcmdtype() == '?') ? '\<' . getcmdline() . '\>' : getcmdline()<CR>


" Goto file under cursor
noremap gf gF
noremap gF gf


" 貼り付けたテキストを選択
noremap gV `[v`]

" Clip All
nmap <Leader>a ggVGy
" Esc Esc でハイライトOFF nohlsearch
nnoremap <Esc><Esc> :noh<CR>
" インサートモードを抜けたときIME Off
" inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
" ビジュアル選択後のインデント調整で２回目以降もビジュアル選択を残す設定
vnoremap < <gv
vnoremap > >gv
" 数字のインクリメント、デクリメントへのマッピング
nnoremap + <C-a>
nnoremap - <C-x>


" alias save
nnoremap <Leader>w :w<CR>
" alias quit
nnoremap <Leader>q :q<CR>


" Y で行末までコピー
nnoremap Y y$
" 改行抜きで一行クリップボードにコピー
nnoremap <Leader>y 0v$h"+y

" vp doesn't replace paste buffer
function! RestoreRegister()
  let @" = s:restore_reg
  let @+ = s:restore_reg
  let @* = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()


" カーソルの下の単語をヤンクした文字列で置換
" nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
" nnoremap <silent> ciy ciw<C-r>0<ESC>
function! s:ReplacePaste()
  let s:buf = @+
  " execute ":normal ciw".s:buf
  " echo "==> s:buf: (".s:buf.")"
  " return "\<ESC>"
  return "ciw".s:buf."\<ESC>"
endfunction
nnoremap <silent> <expr> ciy <sid>ReplacePaste()
nnoremap <silent> cy   ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
vnoremap <silent> cy   c<C-r>0<ESC>:let@/=@1<CR>:noh<CR>


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

"" 現在行をコメント化
map s# 0i# <ESC>
vmap # <c-V>0I#<esc>
" ハードタブ非表示
map sx :set lcs=tab:>\ ,trail:_,extends:\<Enter>
" ハードタブ表示
map sz :set lcs=tab:>.,trail:_,extends:\<Enter>
" 開いているファイルのディレクトリをリスティング
map sd :e %:h<Enter>
" 開いているファイルのディレクトリをカレントにする
map s\ :cd %:h<Enter><Enter>
" " エンコード指定の再読み込みメニューの表示
" map s9 <ALT-F>ere
" " make実行
" map sm :!make<Enter>
" 開いているファイルで JavascriptLint を実行
" map sj :! C:\Users\hogeuser\DOC\tools\jsl-0.3.0\jsl -process %<ENTER>


" 設定ファイルディレクトリを開く
function! Settings()
    :tabe $HOME/.vim/conf.d/
endfunction
command! Settings call Settings()
command! Editvimrc call Settings()
" doc ディレクトリを開く
function! Doc(...)
  let dotdir = GetDotDir()
  let target = dotdir.'/docs'
  if a:0 != 0
    let tmp = target.'/'.a:1.'.md'
    if filewritable(tmp)
      let target = tmp
    endif
  endif
  exe "tabe" target
endfunction
command! -nargs=? Doc call Doc(<f-args>)

nmap <Leader>0 :Settings<CR>
nmap <Leader>9 :tabe $HOME/.vim/snippets<CR>
nmap <Leader>8 :Doc<CR>
nmap <Leader>7 :tabe $HOME/works/00_memos<CR>
nmap <Leader>6 :tabe $HOME/.vim/backup<CR>
nmap <Leader>h :h <C-R><C-W><CR>

" エンコーディングutf-8を指定して開き直す
nnoremap ,8 :e ++enc=utf-8<CR>
" エンコーディングcp932を指定して開き直す
nnoremap ,9 :e ++enc=cp932<CR>

cmap <F3> <C-R>=strftime("%Y-%m-%d")<CR>
imap <F3> <C-R>=strftime("%Y-%m-%d")<CR>
cmap <F4> <C-R>=strftime("%Y%m%d_%H%M%S")<CR>
imap <F4> <C-R>=strftime("%Y%m%d_%H%M%S")<CR>


" 画面分割(縦分割)
nnoremap ss :<C-u>sp<CR>
" 画面分割(横分割)
nnoremap sv :<C-u>vs<CR>
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
" タブで現在のファイルを開いて Unite 全部検索
" nnoremap st :<C-u>tabnew %:p<CR>:<C-u>UniteWithBufferDir -direction=botright -auto-resize -buffer-name=files file_mru file buffer bookmark<CR>
" タブで Unite 全検索
" nnoremap st :<C-u>tabnew<CR>:<C-u>UniteWithBufferDir -direction=botright -auto-resize -buffer-name=files file_mru file buffer bookmark<CR>
" タブ 新規
nnoremap st :<C-u>tabnew<CR>
" タブで複製
nnoremap sc :<C-u>tabnew %<CR>
" タブ一覧
nnoremap sT :<C-u>Unite tab -direction=botright -auto-resize<CR>
nnoremap sb :<C-u>Unite buffer_tab -direction=botright -auto-resize -buffer-name=file<CR>
nnoremap sB :<C-u>Unite buffer -direction=botright -auto-resize -buffer-name=file<CR>
" ファイル一覧
nnoremap sf :<C-u>UniteWithBufferDir -direction=botright -auto-resize -buffer-name=files file<CR>
" レジスタ一覧
nnoremap sr :<C-u>Unite -direction=botright -auto-resize -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap sm :<C-u>Unite file_mru -direction=botright -auto-resize<CR>
 " 全部乗せ
nnoremap sa :<C-u>UniteWithBufferDir -direction=botright -auto-resize -buffer-name=files file_mru file buffer bookmark<CR>
"" ブックマーク一覧
"nnoremap <silent> <Leader>c :<C-u>Unite -direction=botright -auto-resize bookmark<CR>
"" ブックマークに追加
"nnoremap <silent> <Leader>a :<C-u>UniteBookmarkAdd<CR>
" UniteBookMarkAdd で追加したディレクトリを Unite bookmark で開くときのアクションのデフォルトを Vimfiler に
call unite#custom_default_action('source/bookmark/directory' , 'vimfiler')



" 開いているファイルのディレクトリをエクスプローラで開く
if g:is_windows
  " Windows
  "map qn :!nautilus %:h<ENTER>
elseif g:is_cygmsys2
  " Cygwin/Msys2
  "map qn :!nautilus %:h<ENTER>
elseif g:is_mac
  " Mac OS-X
  map qn :!open %:h<ENTER>
elseif g:is_linux
  " BSD, Linux
  map qn :!nautilus %:h<ENTER>
else
  " その他
endif


