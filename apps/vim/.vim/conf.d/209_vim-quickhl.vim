" Indent Guide Settings
if !g:plug.is_installed("vim-quickhl")
  finish
endif

nmap <Space><Space> <Plug>(quickhl-manual-this)
xmap <Space><Space> <Plug>(quickhl-manual-this)
nmap <Space><Esc> <Plug>(quickhl-manual-reset)
xmap <Space><Esc> <Plug>(quickhl-manual-reset)
