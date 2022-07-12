if !g:plug.is_installed("previm")
  finish
endif

"=============================================
" Markdown Preview Syntax etc
" 'kannokanno/previm'
" preview
"=============================================
if executable('chrome.exe')
  let g:previm_open_cmd = 'chrome.exe'
elseif g:is_mac
  let g:previm_open_cmd = 'open -a "Google Chrome"'
else
  let g:previm_open_cmd = 'chrome'
endif
