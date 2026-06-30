" todoリストを簡単に入力する
iab <buffer> tl - [ ]

" " 入れ子のリストを折りたたむ
" setlocal foldmethod=indent

" 現在行に対して実行する :s コマンドを返す
function! s:CheckSubCmd()
  let l:line=getline('.')

  " リストのチェックボックスをトグル
  if l:line=~?'\s*-\s*\[\s*\].*'
    return 's/\[.\]/[x]/'
  endif
  if l:line=~?'\s*-\s*\[x\].*'
    return 's/\[x\]/[ ]/'
  endif

  " 見出しのチェックボックスをトグル
  if l:line=~?'^\s*#\+\s\+\[\s*\].*'
    return 's/\[.\]/[x]/'
  endif
  if l:line=~?'^\s*#\+\s\+\[x\].*'
    return 's/\[x\]/[ ]/'
  endif

  " 見出しならチェックボックスを付与
  if l:line=~?'^\s*#\+\s.*'
    return 's/^\(\s*#\+\s\)/\1[ ] /'
  endif

  " それ以外はリストのチェックボックスを付与
  return 's/^\(\s*\)\(- \)\?/\1- [ ] /'
endfunction

" タイムスタンプの正規表現と生成 (Check / ToggleTimestamp で共有する SSOT)
let s:ts_re='\[\d\{8}_\d\{6}\] '
function! s:TsNow() abort
  return '[' . strftime('%Y%m%d_%H%M%S') . '] '
endfunction

" 現在行に対して実行する :s コマンド列を返す
" チェックを [ ] → [x]+ts → [x] → [ ] の順でトグルする
function! s:CheckSubCmds()
  let l:line=getline('.')

  " [x] [ts] → [x]  (ts だけ削除、チェックは維持)
  if l:line=~?'\[x\]' && l:line=~s:ts_re
    return ['s/' . s:ts_re . '//']
  endif
  " [x] → [ ]  (アンチェック)
  if l:line=~?'\[x\]'
    return [s:CheckSubCmd()]
  endif
  " [ ] → [x] [ts]  (チェック + タイムスタンプ付与)
  if l:line=~?'\[\s*\]'
    return [s:CheckSubCmd(), 's/\[x\] */[x] ' . s:TsNow() . '/']
  endif
  " チェックボックス無し → [ ] を付与
  return [s:CheckSubCmd()]
endfunction

" - : チェックボックスのトグル
function! Check()
  let l:curs=winsaveview()
  for l:cmd in s:CheckSubCmds()
    execute l:cmd
  endfor
  call winrestview(l:curs)
endfunction
" expand-region 等が張る global の _/- に上書きされないよう <buffer> で定義する
nnoremap <silent> <buffer> - :call Check()<CR>
" nnoremap <buffer> <Leader><Leader> :call Check()<CR>
" vnoremap <buffer> <Leader><Leader> :call Check()<CR>

" 現在行に対して実行する :s コマンドを返す
function! s:TimestampSubCmd()
  let l:tsre=s:ts_re

  " 既にタイムスタンプがあれば削除してトグルオフ
  if getline('.')=~l:tsre
    return 's/' . l:tsre . '//'
  endif

  let l:ts=s:TsNow()

  " チェックボックスがあればその直後に挿入
  if getline('.')=~'\[.\] '
    return 's/\[.\] /&' . l:ts . '/'
  endif

  " 見出しなら # の後ろに挿入
  if getline('.')=~'^\s*#\+\s'
    return 's/^\s*#\+\s\+\zs/' . l:ts . '/'
  endif

  " 無ければ行頭(- の後)に挿入
  return 's/^\s*\%(- \)\?\zs/' . l:ts . '/'
endfunction

" _ : 日付スタンプ [20260612_170000] の挿入/削除をトグル
function! ToggleTimestamp()
  let l:curs=winsaveview()
  execute s:TimestampSubCmd()
  call winrestview(l:curs)
endfunction
nnoremap <silent> <buffer> _ :call ToggleTimestamp()<CR>

" 見出し + 直後が xxxx 始まり = タイムスタンプ見出し か判定 (判定の SSOT)
function! s:IsTsHeading(line) abort
  return a:line =~# '^\s*#\+\s\+\d\d\d\d'
endfunction

" F3/F4/F5: タイムスタンプ見出しのタグ([JOB]/[PRV])をトグル、無ければ見出しを新規作成
" a:line=対象行, a:prefix=新規時の見出し記号, a:ts=新規時のタイムスタンプ文字列
function! MarkdownHeaderTagBuild(line, prefix, ts) abort
  " タイムスタンプ見出し => タグをトグル
  if s:IsTsHeading(a:line)
    if a:line =~# '\[JOB\]'
      return substitute(a:line, '\[JOB\]', '[PRV]', '')
    endif
    if a:line =~# '\[PRV\]'
      return substitute(a:line, '\[PRV\]', '[JOB]', '')
    endif
    " タグ無し: タイムスタンプ(先頭トークン)の直後に [JOB] を挿入
    return substitute(a:line, '^\(\s*#\+\s\+\S\+\)\s*', '\1 [JOB] ', '')
  endif
  " 非該当(空行/形式外): 現在行を見出しに書き換え、既存テキストは後ろに残す
  return a:prefix . a:ts . ' [JOB] ' . substitute(a:line, '^\s*', '', '')
endfunction

function! MarkdownHeaderTag(prefix, fmt) abort
  let l:line=getline('.')
  let l:create=!s:IsTsHeading(l:line)
  call setline('.', MarkdownHeaderTagBuild(l:line, a:prefix, strftime(a:fmt)))
  " 新規作成時のみ行末でインサート開始(見出しに続けて入力)
  if l:create
    startinsert!
  endif
endfunction
" normal のみ上書き(101_mapping.vim のグローバル append を markdown で置換)。
" insert/cmdline の <F3-F6> タイムスタンプ挿入・visual/op-pending は従来どおり残す。
" nnoremap <silent> <buffer> <F3> :call MarkdownHeaderTag('## ', '%Y-%m-%d (%a)')<CR>
" nnoremap <silent> <buffer> <F4> :call MarkdownHeaderTag('### ', '%Y%m%d_%H%M%S')<CR>
" nnoremap <silent> <buffer> <F5> :call MarkdownHeaderTag('### ', '%Y-%m-%dT%H:%M:%S%z')<CR>

