" todoリストを簡単に入力する
iab <buffer> tl - [ ]

" " 入れ子のリストを折りたたむ
" setlocal foldmethod=indent

function! Check()
  let l:line=getline('.')
  let l:curs=winsaveview()

  if l:line=~?'\s*-\s*\[\s*\].*'
    s/\[.\]/[x]/
  elseif l:line=~?'\s*-\s*\[x\].*'
    s/\[x\]/[ ]/
  elseif l:line=~?'^\s*#\+\s\+\[\s*\].*'
    s/\[.\]/[x]/
  elseif l:line=~?'^\s*#\+\s\+\[x\].*'
    s/\[x\]/[ ]/
  elseif l:line=~?'^\s*#\+\s.*'
    s/^\(\s*#\+\s\)/\1[ ] /
  else
    s/^\(\s*\)\(- \)\?/\1- [ ] /
  endif

  call winrestview(l:curs)
endfunction
" expand-region 等が張る global の _/- に上書きされないよう <buffer> で定義する
nnoremap <silent> <buffer> - :call Check()<CR>
" nnoremap <buffer> <Leader><Leader> :call Check()<CR>
" vnoremap <buffer> <Leader><Leader> :call Check()<CR>

" 現在行に対して実行する :s コマンドを返す
function! s:TimestampSubCmd()
  let l:tsre='\[\d\{4}\d\{2}\d\{2}_\d\{2}\d\{2}\d\{2}\] '

  " 既にタイムスタンプがあれば削除してトグルオフ
  if getline('.')=~l:tsre
    return 's/' . l:tsre . '//'
  endif

  let l:ts='[' . strftime('%Y%m%d_%H%M%S') . '] '

  " チェックボックスがあればその直後に挿入
  if getline('.')=~'\[.\] '
    return 's/\[.\] /&' . l:ts . '/'
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

