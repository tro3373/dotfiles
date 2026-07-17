if !executable('fzf')
  finish
endif

if !g:plug.is_installed("fzf.vim")
  finish
endif

" option に関しては、以下が詳しい
"   https://github.com/junegunn/fzf/wiki
"   http://koturn.hatenablog.com/entry/2015/11/26/000000
" nnoremap ,l :FZF .<CR>
" vnoremap ,l y:FZF -q <C-R>"<CR>
" nnoremap ,j :FZF -q <C-R><C-W>
" vnoremap ,j y:FZF -q <C-R>"


let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:50%' --preview 'bat --color=always --style=header,grid --line-range :500 {}'"

" ウィンドウサイズ変更したい場合
let g:fzf_layout = { 'window': { 'width': 1.0, 'height': 1.0, 'yoffset': 0.5, 'xoffset': 0.5, 'border': 'sharp' } }

" fzf の terminal buffer に限り <Esc> を fzf(既定の esc:abort)へ素通しする。
" nvim は map テーブル上で <C-[> を <Esc> と同一キーに正規化するため、
" nvim/lua/base.lua の t-mode <C-[> マップが <Esc> まで食い、fzf を閉じる前に
" terminal-normal へ抜けてしまう。buffer-local マップは global より優先されるので
" ここで打ち消す(fzf.vim が terminal buffer に setf fzf する)。
augroup fzf_esc_abort
  autocmd!
  autocmd FileType fzf tnoremap <buffer> <Esc> <Esc>
augroup END

" ----------------------------------------------------------------------------
" fzf で選択した項目を新しいタブで開くための共通ヘルパー
" ----------------------------------------------------------------------------

" Enter で選択を新タブ('tab split' = Ctrl-t 相当)で開くよう g:fzf_action を
" 一時上書きして Fn を実行する。fzf#vim#files / fzf#wrap 系は呼び出し時に
" g:fzf_action を同期キャプチャするため、Fn 実行直後に復元しても選択時の挙動は
" 変わらない。Ctrl-t/x/v の既存設定は extend で温存する。
" sink が s:common_sink の files/history では複数選択時に各項目が個別タブで開く。
function! s:open_in_tab(Fn) abort
  let l:had = exists('g:fzf_action')
  let l:orig = get(g:, 'fzf_action', {})
  let g:fzf_action = extend(copy(l:orig), {'enter': 'tab split'})
  try
    call a:Fn()
  finally
    call s:restore_fzf_action(l:had, l:orig)
  endtry
endfunction

" g:fzf_action を元の状態へ戻す。元々未設定だった場合に空 dict {} を残すと、
" 後続の fzf#wrap が '--expect='(キー無し) を生成して fzf がエラー終了(code 2)
" するため、unlet で未設定状態へ正しく戻す。
function! s:restore_fzf_action(had, orig) abort
  if a:had
    let g:fzf_action = a:orig
    return
  endif
  unlet! g:fzf_action
endfunction

" grep(rg)結果 'file:line:col:text' の選択行を、選択数ぶん個別ウィンドウで開いて
" 該当行へジャンプする sink。fzf#vim#grep 標準の s:ag_handler は先頭1件のみ
" 開き残りを quickfix へ送るため、spec の sink* で置き換えて各マッチを展開する。
" a:lines[0] は fzf の --expect キー。Enter/Ctrl-t は個別タブ、Ctrl-x/v は
" split/vsplit と既存の files/history 側(g:fzf_action)に挙動を揃える。
function! s:open_grep_in_tabs(lines) abort
  if len(a:lines) < 2
    return
  endif
  let l:cmd = get({'ctrl-x': 'split', 'ctrl-v': 'vsplit'}, a:lines[0], 'tabedit')
  for l:line in a:lines[1:]
    let l:m = matchlist(l:line, '\(.\{-}\):\(\d\+\):\(\d*\):')
    if empty(l:m)
      continue
    endif
    execute l:cmd fnameescape(l:m[1])
    call cursor(str2nr(l:m[2]), str2nr(l:m[3]))
    normal! zvzz
  endfor
endfunction

" 【解説】開発ライブ実況 #1 (Vim / Go) 編 by メルペイ Architect チーム Backend エンジニア #mercari_codecast | メルカリエンジニアリング
" https://engineering.mercari.com/blog/entry/mercari_codecast_1/
" rg + fzf による grep 検索の共通処理。除外スコープ(ignore_file)だけを引数で
" 切り替える。q=検索語, d=対象ディレクトリ(空なら git root)。
" 選択(複数可)した各マッチは s:open_grep_in_tabs で個別タブに展開する。
function! s:rip_grep(q, d, ignore_file) abort
  let l:target_dir = a:d
  if a:d == ''
    let l:target_dir = GetGitRoot()
  endif
  " fzf#vim#with_preview で ctrl+h/l で左右するようにできないか？
  let l:spec = fzf#vim#with_preview({'options': '--query="' . a:q . '" --delimiter : --nth 4.. --reverse'}, 'right:50%', '?')
  let l:spec['sink*'] = function('s:open_grep_in_tabs')
  call fzf#vim#grep(
      \   'rg --ignore-file ' . a:ignore_file . ' --glob "!.git/" --column --line-number --no-heading --hidden --smart-case "'.a:q.'" '.l:target_dir,
      \   1,
      \   l:spec,
      \   0,
      \)
endfunction

" <Leader>g/G: テスト・モック・md を除外した絞り込み grep。
function! s:find_rip_grep(q, d) abort
  call s:rip_grep(a:q, a:d, '~/.vim/.rgignore_for_go')
endfunction
nnoremap <silent> <Leader>g :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), '')<CR>
" nnoremap <silent> <Leader>G :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>G :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), getcwd())<CR>
vnoremap <silent> <Leader>g "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), '')<CR>
" vnoremap <silent> <Leader>G "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), expand('%:p:h'))<CR>
vnoremap <silent> <Leader>G "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), getcwd())<CR>

" <Leader>f/F: .nouse のみ除外した広い grep。
function! s:find_rip_grep_fuzzy(q, d) abort
  call s:rip_grep(a:q, a:d, '~/.vim/.rgignore')
endfunction
nnoremap <silent> <Leader>f :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), '')<CR>
" nnoremap <silent> <Leader>F :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>F :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), getcwd())<CR>
vnoremap <silent> <Leader>f "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), '')<CR>
" vnoremap <silent> <Leader>F "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), expand('%:p:h'))<CR>
vnoremap <silent> <Leader>F "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), getcwd())<CR>

function! s:find_rip_grep_files(q, d) abort
  let l:target_dir = a:d
  if a:d == ''
    let l:target_dir = GetGitRoot()
  endif
  " 選択(Enter)したファイルを新しいタブで開く。-m で複数選択した場合は各ファイルが
  " 個別タブで開く(s:open_in_tab が g:fzf_action を一時上書きする)。
  " ambiwidth=double(日本語環境)では Unicode の pointer/marker の幅判定がずれ、
  " カーソル行が1桁左へずれて末尾文字が二重に見える。fzf#vim#with_preview と同じく
  " ASCII 記号へ倒して防ぐ(with_preview を通さない files 系には自動付与されないため)。
  let l:options = ['--query=' . a:q, '--info=inline', '-m']
  if &ambiwidth ==# 'double'
    call add(l:options, '--no-unicode')
  endif
  " source を rg の更新日時降順に差し替え、最近更新したファイルを上位に出す。
  " '--sortr modified' = 新しい順。dir 指定で target_dir 配下を相対パス列挙する。
  call s:open_in_tab({ -> fzf#vim#files(l:target_dir, {'source': 'rg --files --sortr modified', 'options': l:options}) })
endfunction
" nnoremap <silent> <Leader>; :<C-u>silent call <SID>find_rip_grep_files(expand('<cword>'), '')<CR>
" nnoremap <silent> <Leader>: :<C-u>silent call <SID>find_rip_grep_files(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>l :<C-u>silent call <SID>find_rip_grep_files('', '')<CR>
nnoremap <silent> <Leader>L :<C-u>silent call <SID>find_rip_grep_files('', expand('%:p:h'))<CR>

" :History(MRU) を、cwd 配下のファイルを先頭へ寄せて表示する。
" fzf には特定項目だけ上位ブーストする機能が無いため、独自に source を組み立てる。
" fzf#vim#_recent_files() は :History と同じソース([現在ファイル]+[開いている
" バッファ]+[oldfiles] を uniq した :~:. 表示パス)。:~:. は cwd 配下のみ相対
" パスになるため、先頭が ~ or / でないものを cwd 配下と判定し前方へ寄せる
" (各グループ内の MRU 順は維持する安定パーティション)。
function! s:history_cwd_first() abort
  let l:files = fzf#vim#_recent_files()
  let l:under = filter(copy(l:files), 'v:val !~# "^[~/]"')
  let l:other = filter(copy(l:files), 'v:val =~# "^[~/]"')
  " 選択(Enter)したファイルを新しいタブで開く。-m で複数選択した場合は各ファイルが
  " 個別タブで開く(s:open_in_tab が g:fzf_action を一時上書きする)。
  call s:open_in_tab({ -> fzf#run(fzf#wrap('history-cwd-first',
        \ fzf#vim#with_preview({
        \   'source':  l:under + l:other,
        \   'options': ['-m', '--prompt', 'Hist> ', '--info=inline'],
        \ }), 0)) })
endfunction

" st: bin/memo の vim 版(s:fire_memo)を開く。
" 旧 ctrlp 環境(vim)では 220_ctrlp.vim.vim の `st`(CtrlPMRU)を温存し、
" ctrlp を廃止した環境(nvim)でのみ再割当する。
" cwd 優先 History(history_cwd_first)は st から外し <Leader>p に残す。
if !g:plug.is_installed('ctrlp.vim')
  nnoremap <silent> st :<C-u>tabnew<CR>:call <SID>history_cwd_first()<CR>
  " nnoremap <silent> st :<C-u>tabnew<CR>:<C-u>silent call <SID>fire_memo()<CR>
  nnoremap <silent> <Leader>p :<C-u>silent call <SID>history_cwd_first()<CR>
endif

" bin/memo の vim 版。収集ロジック(.memo + job/prv 最新ログ)は bin/memo へ SSOT 化し、
" `memo --list` の出力を fzf の source にする。'dir' を git root にすることで、
"   1. memo --list が git root で実行され .memo の git root 相対パスが正しく出る
"   2. 選択された相対パスも common_sink が w:fzf_pushd.dir(=git root)基準で開く
" 選択(複数可)した各ファイルを個別タブで開く(s:open_in_tab)。
function! s:fire_memo() abort
  call s:open_in_tab({ -> fzf#run(fzf#wrap('fire-memo',
        \ fzf#vim#with_preview({
        \   'source':  'memo --list',
        \   'dir':     GetGitRoot(),
        \   'options': ['-m', '--prompt', 'Memo> ', '--info=inline'],
        \ }), 0)) })
endfunction
command! Memo call s:fire_memo()
