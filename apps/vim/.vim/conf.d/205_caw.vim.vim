if !g:plug.is_installed("caw.vim")
  finish
endif

"=============================================
" caw 設定(コメントアウト トグル)
" http://d.hatena.ne.jp/ampmmn/20080925/1222338972
"=============================================
nmap <Leader>c <Plug>(caw:hatpos:toggle)
vmap <Leader>c <Plug>(caw:hatpos:toggle)
