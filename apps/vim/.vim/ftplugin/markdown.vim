" todoリストを簡単に入力する
iab tl - [ ]

" " 入れ子のリストを折りたたむ
" setlocal foldmethod=indent

function Check()
  let l:line=getline('.')
  let l:curs=winsaveview()
  if l:line=~?'\s*-\s*\[\s*\].*'
    s/\[.\]/[x]/
  elseif l:line=~?'\s*-\s*\[x\].*'
    s/\[x\]/[ ]/
  else
    s/- /- [ ] /
  endif
  call winrestview(l:curs)
endfunction
nnoremap <silent> - :call Check()<CR>
" nnoremap <buffer> <Leader><Leader> :call Check()<CR>
" vnoremap <buffer> <Leader><Leader> :call Check()<CR>

