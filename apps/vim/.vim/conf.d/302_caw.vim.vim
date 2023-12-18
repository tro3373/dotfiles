if !g:plug.is_installed("caw.vim")
  finish
endif

"=============================================
" caw 設定(コメントアウト トグル)
" http://d.hatena.ne.jp/ampmmn/20080925/1222338972
"=============================================
nmap <Leader>c <Plug>(caw:hatpos:toggle)
vmap <Leader>c <Plug>(caw:hatpos:toggle)

" [Support for JSX and TSX Issue #91 tyru/caw.vim](https://github.com/tyru/caw.vim/issues/91)
autocmd BufNewFile,BufRead *.jsx set ft=javascript.jsx
autocmd BufNewFile,BufRead *.tsx set ft=typescript.tsx
autocmd FileType javascript.jsx call s:set_jsx_comment()
autocmd FileType typescript.tsx call s:set_jsx_comment()

function! s:set_jsx_comment() abort
  let &l:commentstring = ''
  unlet! b:caw_oneline_comment
  let b:caw_wrap_oneline_comment = ['{/*', '*/}']
endfunction
