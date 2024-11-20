if !g:plug.is_installed("vim-commentary")
  finish
endif

" v: 文字単位の visual mode
" x: visual mode
xmap <Leader>c  <Plug>Commentary
" nmap <Leader>c  <Plug>Commentary
" o: オペレータ待ちの状態
" n: ノーマルモード
omap <Leader>c  <Plug>Commentary
nmap <Leader>c  <Plug>CommentaryLine

autocmd FileType markdown setlocal commentstring=>\ %s
