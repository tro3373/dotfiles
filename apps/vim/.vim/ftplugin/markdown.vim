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

" _ : 日付スタンプ [20260612_170000] の挿入/削除をトグル
function! ToggleTimestamp()
  let l:curs=winsaveview()
  let l:tsre='\[\d\{4}\d\{2}\d\{2}_\d\{2}\d\{2}\d\{2}\] '
  if getline('.')=~l:tsre
    execute 's/' . l:tsre . '//'
  else
    let l:ts='[' . strftime('%Y%m%d_%H%M%S') . '] '
    if getline('.')=~'\[.\] '
      execute 's/\[.\] /&' . l:ts . '/'
    else
      execute 's/^\s*\%(- \)\?\zs/' . l:ts . '/'
    endif
  endif
  call winrestview(l:curs)
endfunction
nnoremap <silent> <buffer> _ :call ToggleTimestamp()<CR>

