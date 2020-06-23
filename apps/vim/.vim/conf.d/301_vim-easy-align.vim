if !g:plug.is_installed("vim-easy-align")
  finish
endif

" au FileType markdown vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>
" Visual Select + Enter and * (select target) and | (select keyword)
vmap <Enter> <Plug>(EasyAlign)
