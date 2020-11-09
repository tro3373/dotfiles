UsePlugin 'previm'
"if !g:plug.is_installed("previm")
"  finish
"endif

UsePlugin 'open-browser.vim'
" if !g:plug.is_installed("open-browser.vim")
"   finish
" endif

"=============================================
" previm
"=============================================
if g:is_windows
  let g:previm_open_cmd = 'chrome'
else
  let g:previm_open_cmd = 'google-chrome'
endif
