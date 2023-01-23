if !g:plug.is_installed("jumpcursor.vim")
  finish
endif

nmap [j <Plug>(jumpcursor-jump)
nmap <Leader>k <Plug>(jumpcursor-jump)
