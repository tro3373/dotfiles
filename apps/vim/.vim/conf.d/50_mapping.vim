"######################################################################
" mapping.vim
"      Vim/gVim共通で使用するキーバインドを定義する
"######################################################################
" .vimrcを編集する
command! Editvimrc edit $MYVIMRC
" .vimrcを再読み込みする
command! Reloadvimrc source $MYVIMRC

let mapleader = "\<Space>"

" 表示上の行移動(エディタで表示されている行)であるgj,gkと、
" 実際の行移動(エディタの表示行ではなく改行コードを意識した実際の行)であるj,kを入れ替え
nnoremap j gj
nnoremap k gk
noremap <Down> gj
noremap <Up> gk
nnoremap gj j
nnoremap gk k
nnoremap n nzz
nnoremap N Nzz
nnoremap S *zz
nnoremap * *zz
nnoremap g* g*zz
nnoremap g# g#zz
" <Space>h で先頭、<Space>l で行末へ
noremap <Space>h  ^
noremap <Space>l  $
" Goto file under cursor
noremap gf gF
noremap gF gf
" インサートモードでのESCエイリアスをjjに割り当て
inoremap <silent> jj <ESC>
" 数字のインクリメント、デクリメントへのマッピング
nnoremap + <C-a>
nnoremap - <C-x>

" Y で行末までコピー
nnoremap Y y$
" 改行抜きで一行クリップボードにコピー
nnoremap <Space>y 0v$h"+y

" ビジュアルモード選択した部分を*で検索
vnoremap * "zy:let @/ = @z<CR>nzz
" カーソルの下の単語をヤンクした文字列で置換
nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
nnoremap <silent> cy   ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
vnoremap <silent> cy   c<C-r>0<ESC>:let@/=@1<CR>:noh<CR>


" tabでインデント、Shift+tabでアンインデント
" <Tab> mapping で Ctrl + I が聞かなくなる為無効化
" inoremap <S-Tab> <C-O><LT><LT>
" nnoremap <Tab> >>
" nnoremap <S-Tab> <LT><LT>
" vnoremap <Tab> >
" vnoremap <S-Tab> <LT>

"" 現在行をコメント化 (/* */)
"map qq 0i/* <ESC>$a */<ESC>
"" 現在行をコメント化
"map s/ 0i// <ESC>
map s# 0i# <ESC>
vmap # <c-V>0I#<esc>
"vmap C :s/^#//<cr>
"vmap // <C-V>0I//<Esc>
"vmap c :s/^\/\///<CR>:noh<cr>K

" ハードタブ非表示
map sx :set lcs=tab:>\ ,trail:_,extends:\<Enter>
" ハードタブ表示
map sz :set lcs=tab:>.,trail:_,extends:\<Enter>
" 開いているファイルのディレクトリをリスティング
map sd :e %:h<Enter>
map qd :e %:h<Enter>
" 開いているファイルのディレクトリをカレントにする
map s\ :cd %:h<Enter><Enter>
" バックアップディレクトリを開く
map s0 :tabe $HOME/.vim/backup<ENTER>




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
" タブで現在のファイルを開いて Unite 全部検索
" nnoremap st :<C-u>tabnew %:p<CR>:<C-u>UniteWithBufferDir -direction=botright -auto-resize -buffer-name=files file_mru file buffer bookmark<CR>
" タブで Unite 全検索
nnoremap st :<C-u>tabnew<CR>:<C-u>UniteWithBufferDir -direction=botright -auto-resize -buffer-name=files file_mru file buffer bookmark<CR>
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
"nnoremap <silent> <Space>c :<C-u>Unite -direction=botright -auto-resize bookmark<CR>
"" ブックマークに追加
"nnoremap <silent> <Space>a :<C-u>UniteBookmarkAdd<CR>
" UniteBookMarkAdd で追加したディレクトリを Unite bookmark で開くときのアクションのデフォルトを Vimfiler に
call unite#custom_default_action('source/bookmark/directory' , 'vimfiler')

" unite.vim上でのキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
    " 単語単位からパス単位で削除するように変更
    imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

    " ESCキーを2回押すと終了する
    nmap <silent><buffer> <ESC><ESC> q
    imap <silent><buffer> <ESC><ESC> <ESC>q
endfunction


"=============================================
" unite-grep 設定
"=============================================
" unite-grepのキーマップ
" grep検索
" ディレクトリを指定して ag 検索
nnoremap <silent> ,dg :<C-u>Unite grep -direction=botright -auto-resize -buffer-name=search-buffer<CR>
" カーソル位置の単語を ag 検索
nnoremap <silent> ,g :<C-u>Unite grep:. -direction=botright -auto-resize -buffer-name=search-buffer<CR><C-R><C-W><CR>
" ビジュアルモードでは、選択した文字列をunite-grep
vnoremap <silent> ,g y:Unite grep:.:-iRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>
" grep検索結果の再呼出
nnoremap <silent> ,r :<C-u>UniteResume search-buffer -direction=botright -auto-resize<CR>
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
" unite grep に ag(The Silver Searcher) を使う
" http://qiita.com/items/c8962f9325a5433dc50d
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column --hidden'
  " let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
  " let g:unite_source_grep_max_candidates = 200
endif


" FZF 起動
" option に関しては、以下が詳しい
"   https://github.com/junegunn/fzf/wiki
"   http://koturn.hatenablog.com/entry/2015/11/26/000000
nnoremap <Space>o :FZF .<CR>
nnoremap <Space>f :FZF -q <C-R><C-W>
vnoremap <Space>f y:FZF -q <C-R>"
" Ag 起動
nnoremap <Space>g :Ag <C-R><C-W>
vnoremap <Space>g y:Ag <C-R>"

"=============================================
" NERDTree 設定
"=============================================
if g:plug.is_installed("nerdtree")
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
endif

""=============================================
"" Lokaltog/vim-easymotion
""=============================================
"if g:plug.is_installed("vim-easymotion")
"    " http://blog.remora.cx/2012/08/vim-easymotion.html
"    " ホームポジションに近いキーを使う
"    let g:EasyMotion_keys='hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
"    " 「;」 + 何かにマッピング
"    let g:EasyMotion_leader_key=";"
"    " 1 ストローク選択を優先する
"    let g:EasyMotion_grouping=1
"    " カラー設定変更
"    hi EasyMotionTarget ctermbg=none ctermfg=red
"    hi EasyMotionShade  ctermbg=none ctermfg=blue
"endif


"=============================================
" neosnippet 設定
" http://rcmdnk.github.io/blog/2015/01/12/computer-vim/
" http://kazuph.hateblo.jp/entry/2012/11/28/105633
"=============================================
if g:plug.is_installed("neosnippet")
    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)
    xmap <C-k> <Plug>(neosnippet_expand_target)
    " honza/vim-snippets 等、元々snipmate用等に作られた物との互換性を上げるための設定
    let g:neosnippet#enable_snipmate_compatibility = 1
    " my-snippets
    "   => .vim/snippets
    " Shougo/neosnippet-snippets
    " honza/vim-snippets
    "  => target langs
    "       actionscript apache autoit c chef clojure cmake coffee cpp cs css
    "       dart diff django erlang eruby falcon go haml haskell html htmldjango
    "       htmltornado java javascript-jquery javascript jsp ledger lua make
    "       mako markdown objc perl php plsql po processing progress puppet
    "       python r rst ruby sh snippets sql tcl tex textile vim xslt yii-chtml yii zsh
    let g:neosnippet#snippets_directory = '~/.vim/snippets,~/.vim/plugged/vim-snippets/snippets,~/.vim/plugged/neosnippet-snippets/neosnippets'

    " SuperTab like snippets behavior.
    imap <expr><TAB> neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

    " For snippet_complete marker.
    if has('conceal')
      set conceallevel=2 concealcursor=i
    endif
endif

"=============================================
" smartchr 設定
" http://d.hatena.ne.jp/ampmmn/20080925/1222338972
"=============================================
if g:plug.is_installed("vim-smartchr")
    " 演算子の間に空白を入れる
    " inoremap <buffer><expr> < search('^#include\%#', 'bcn')? ' <': smartchr#one_of(' < ', ' << ', '<')
    " inoremap <buffer><expr> > search('^#include <.*\%#', 'bcn')? '>': smartchr#one_of(' > ', ' >> ', '>')
    " inoremap <buffer><expr> + smartchr#one_of(' + ', '++', '+')
    " inoremap <buffer><expr> - smartchr#one_of(' - ', '--', '-')
    " inoremap <buffer><expr> / smartchr#one_of(' / ', '// ', '/')
    " *はポインタで使うので、空白はいれない
    " inoremap <buffer><expr> & smartchr#one_of(' & ', ' && ', '&')
    inoremap <buffer><expr> % smartchr#one_of(' % ', '%')
    inoremap <buffer><expr> <Bar> smartchr#one_of(' <Bar> ', ' <Bar><Bar> ', '<Bar>')
    inoremap <buffer><expr> , smartchr#one_of(', ', ',')
    " 3項演算子の場合は、後ろのみ空白を入れる
    inoremap <buffer><expr> ? smartchr#one_of('? ', '?')
    " inoremap <buffer><expr> : smartchr#one_of(': ', '::', ':')

    " " =の場合、単純な代入や比較演算子として入力する場合は前後にスペースをいれる。
    " " 複合演算代入としての入力の場合は、直前のスペースを削除して=を入力
    " inoremap <buffer><expr> = search('\(&\<bar><bar>\<bar>+\<bar>-\<bar>/\<bar>>\<bar><\) \%#', 'bcn')? '<bs>= '
    "     \ : search('\(*\<bar>!\)\%#', 'bcn') ? '= '
    "     \ : smartchr#one_of(' = ', ' == ', '=')

    " " 下記の文字は連続して現れることがまれなので、二回続けて入力したら改行する
    " inoremap <buffer><expr> } smartchr#one_of('}', '}<cr>')
    " inoremap <buffer><expr> ; smartchr#one_of(';', ';<cr>')
    " 「->」は入力しづらいので、..で置換え
    " inoremap <buffer><expr> . smartchr#loop('.', '->', '...')
    " 行先頭での@入力で、プリプロセス命令文を入力
    inoremap <buffer><expr> @ search('^\(#.\+\)\?\%#','bcn')? smartchr#one_of('#define', '#include', '#ifdef', '#endif', '@'): '@'

    inoremap <buffer><expr> " search('^#include\%#', 'bcn')? ' "': '"'
    " if文直後の(は自動で間に空白を入れる
    inoremap <buffer><expr> ( search('\<\if\%#', 'bcn')? ' (': '('
endif

"=============================================
" caw 設定(コメントアウト トグル)
" http://d.hatena.ne.jp/ampmmn/20080925/1222338972
"=============================================
if g:plug.is_installed("caw.vim")
    nmap <Leader>c <Plug>(caw:i:toggle)
    vmap <Leader>c <Plug>(caw:i:toggle)
endif

"=============================================
" Markdown Preview
" vim-markdown, preview, open-browser
"=============================================
if g:plug.is_installed("vim-markdown")
    " 折りたたみなし設定
    let g:vim_markdown_folding_disabled=1
endif
if g:plug.is_installed("previm")
    if g:plug.is_installed("open-browser.vim")
        au BufRead,BufNewFile *.md set filetype=markdown
        let g:previm_open_cmd = 'google-chome'
    endif
endif
