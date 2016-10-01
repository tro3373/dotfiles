"######################################################################
" mapping.vim
"      Vim/gVim共通で使用するキーバインドを定義する
"######################################################################
" .vimrcを編集する
command! Editvimrc edit $MYVIMRC
" .vimrcを再読み込みする
command! Reloadvimrc source $MYVIMRC

let mapleader = "\<Space>"

nnoremap ,8 :e ++enc=utf-8<CR>
nnoremap ,9 :e ++enc=cp932<CR>
" 表示上の行移動(エディタで表示されている行)であるgj,gkと、
" 実際の行移動(エディタの表示行ではなく改行コードを意識した実際の行)であるj,kを入れ替え
nnoremap j gj
nnoremap k gk
noremap <Down> gj
noremap <Up> gk
nnoremap gj j
nnoremap gk k
" insertモードから抜ける
inoremap <silent> jj <ESC>
inoremap <silent> <C-j> j
inoremap <silent> kk <ESC>
inoremap <silent> <C-k> k
" 挿入モードでのカーソル移動
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
nnoremap n nzz
nnoremap N Nzz
nnoremap S *zz
nnoremap * *zz
nnoremap g* g*zz
nnoremap g# g#zz
" Goto file under cursor
noremap gf gF
noremap gF gf
" 数字のインクリメント、デクリメントへのマッピング
nnoremap + <C-a>
nnoremap - <C-x>
" 貼り付けたテキストを選択
noremap gV `[v`]
" Y で行末までコピー
nnoremap Y y$
" 改行抜きで一行クリップボードにコピー
nnoremap <Leader>y 0v$h"+y
" alias save
nnoremap <Leader>w :w<CR>
" Visual line
nmap <Leader><Leader> V

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


" ビジュアルモード選択した部分を*で検索
vnoremap * "zy:let @/ = @z<CR>nzz
" カーソルの下の単語をヤンクした文字列で置換
nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
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
" 設定ファイルディレクトリを開く
map s0 :tabe $HOME/.vim/conf.d/50_mapping.vim<ENTER>
" バックアップディレクトリを開く
map s9 :tabe $HOME/.vim/backup<ENTER>
" " エンコード指定の再読み込みメニューの表示
" map s9 <ALT-F>ere
" " make実行
" map sm :!make<Enter>
" 開いているファイルで JavascriptLint を実行
" map sj :! C:\Users\hogeuser\DOC\tools\jsl-0.3.0\jsl -process %<ENTER>


"=============================================
" unite-outline 設定
"=============================================
if g:plug.is_installed("unite-outline")
    let g:unite_split_rule = 'botright'
    noremap ,u <ESC>:Unite -vertical -winwidth=40 outline<Return>
endif

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
"nnoremap <silent> <Leader>c :<C-u>Unite -direction=botright -auto-resize bookmark<CR>
"" ブックマークに追加
"nnoremap <silent> <Leader>a :<C-u>UniteBookmarkAdd<CR>
" UniteBookMarkAdd で追加したディレクトリを Unite bookmark で開くときのアクションのデフォルトを Vimfiler に
call unite#custom_default_action('source/bookmark/directory' , 'vimfiler')


"=============================================
" CtrlP 設定
"=============================================
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.exe
if g:plug.is_installed("ctrlp.vim")
    nnoremap <Leader>o :CtrlP<CR>
    nnoremap <Leader>p :CtrlP<CR>
    " Guess vcs root dir
    let g:ctrlp_working_path_mode = 'ra'
    let g:ctrlp_extensions = ['funky', 'tag', 'quickfix', 'dir', 'line', 'mixed']
    let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:18'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]\.(git|hg|svn)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'some_bad_symbolic_links',
      \ }

    if executable('ag')
        "let g:ctrlp_clear_cache_on_exit = 0
        let g:ctrlp_use_caching = 0
        set grepprg=ag\ --nogroup\ --nocolor
        let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    elseif g:is_windows
        let g:ctrlp_user_command = 'dir %s /-n /b /s /a-d'  " Windows
    else
      let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
      let g:ctrlp_prompt_mappings = {
        \ 'AcceptSelection("e")': ['<Space>', '<cr>', '<2-LeftMouse>'],
        \ }
    endif

    let g:ctrlp_funky_matchtype = 'path'
    let g:ctrlp_funky_syntax_highlight = 1
    nnoremap <Leader>@ :CtrlPFunky<Cr>
    " narrow the list down with a word under cursor
    " nnoremap <Leader>@@ :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
    if !g:is_windows
        if g:plug.is_installed("cpsm")
            let g:ctrlp_match_func = {'match': 'cpsm#CtrlPMatch'}
        endif
    endif
endif

"=============================================
" FZF 設定
"=============================================
if executable('fzf')
    if g:plug.is_installed("fzf.vim")
        " option に関しては、以下が詳しい
        "   https://github.com/junegunn/fzf/wiki
        "   http://koturn.hatenablog.com/entry/2015/11/26/000000
        nnoremap <Leader>l :FZF .<CR>
        vnoremap <Leader>l y:FZF -q <C-R>"<CR>
        nnoremap <Leader>j :FZF -q <C-R><C-W>
        vnoremap <Leader>j y:FZF -q <C-R>"
    endif
endif


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
" Grep 設定
"=============================================
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor --column --hidden'
    " let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
    " let g:unite_source_grep_max_candidates = 200
    if g:plug.is_installed("ag.vim")
        " カーソル位置の単語を ag 検索
        nnoremap <Leader>g :Ag <C-R><C-W><CR>
        vnoremap <Leader>g y:Ag <C-R>"<CR>
    endif
else
    " カーソル位置の単語を ag 検索
    nnoremap <silent> <Leader>g :<C-u>Unite grep:. -direction=botright -auto-resize -buffer-name=search-buffer<CR><C-R><C-W><CR>
    " ビジュアルモードでは、選択した文字列をunite-grep
    vnoremap <silent> <Leader>g y:Unite grep:.:-iRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>
    " ディレクトリを指定して ag 検索
    nnoremap <silent> ,g :<C-u>Unite grep -direction=botright -auto-resize -buffer-name=search-buffer<CR>
    " grep検索結果の再呼出
    nnoremap <silent> ,r :<C-u>UniteResume search-buffer -direction=botright -auto-resize<CR>
endif

"=============================================
" gtags 設定
"=============================================
if g:plug.is_installed("gtags.vim")
    " カーソル位置の単語を Gtags で検索
    nnoremap <C-j> :GtagsCursor<Enter>
    " 関数一覧
    nnoremap <C-l> :Gtags -f %<Enter>
    " Grep
    nnoremap <C-g> :Gtags -g
    " 使用箇所検索
    nnoremap <C-h> :Gtags -r
    " 次の要素
    nnoremap <C-n> :cn<Enter>
    " １つ前の要素
    nnoremap <C-p> :cp<Enter>
endif

"=============================================
" taglist 設定
"=============================================
if g:plug.is_installed("taglist.vim")
    " Tlistを表示
    map tl :Tlist<Enter>
endif

"=============================================
" Expand Region
" visually select increasingly larger regions of text
"=============================================
if g:plug.is_installed("vim-expand-region")
    vmap v <Plug>(expand_region_expand)
    vmap <C-v> <Plug>(expand_region_shrink)
endif

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
    nmap <Leader>c <Plug>(caw:hatpos:toggle)
    vmap <Leader>c <Plug>(caw:hatpos:toggle)
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
        let g:previm_open_cmd = 'google-chrome'
    endif
endif

"=============================================
" Memolist
"=============================================
if g:plug.is_installed('memolist.vim')
    let g:memolist_path = "$HOME/works/memos"
    let g:memolist_memo_suffix = "md"
    let g:memolist_memo_date = "%Y-%m-%d %H:%M"
    let g:memolist_memo_date = "epoch"
    let g:memolist_memo_date = "%D %T"
    let g:memolist_prompt_tags = 1
    let g:memolist_prompt_categories = 1
    let g:memolist_qfixgrep = 0
    let g:memolist_vimfiler = 0
    "let g:memolist_template_dir_path = "path/to/dir"
    nmap <Leader>ml :exe "CtrlP" g:memolist_path<cr><f5>
    nmap <Leader>mc :MemoNew<cr>
    nmap <Leader>mg :MemoGrep<cr>
endif


" 開いているファイルのディレクトリをエクスプローラで開く
if g:is_windows
    " Windows
    "map qn :!nautilus %:h<ENTER>
elseif g:is_cygwin
    " Cygwin
    "map qn :!nautilus %:h<ENTER>
elseif g:is_mac
    " Mac OS-X
    "map qn :!nautilus %:h<ENTER>
elseif g:is_linux
    " BSD, Linux
    map qn :!nautilus %:h<ENTER>
else
    " その他
endif


" yank to remote
let g:y2r_config = {
    \   'tmp_file': '/tmp/exchange_file',
    \   'key_file': expand('$HOME') . '/.exchange.key',
    \   'host': 'localhost',
    \   'port': 52224,
    \ }
function! Yank2Remote()
    call writefile(split(@", '\n'), g:y2r_config.tmp_file, 'b')
    let s:params = ['cat %s %s | nc -w1 %s %s']
    for s:item in ['key_file', 'tmp_file', 'host', 'port']
        let s:params += [shellescape(g:y2r_config[s:item])]
    endfor
    let s:ret = system(call(function('printf'), s:params))
endfunction
nnoremap <silent> ,y :call Yank2Remote()<CR>

