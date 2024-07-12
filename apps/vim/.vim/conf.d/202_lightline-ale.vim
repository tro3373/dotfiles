if !g:plug.is_installed("lightline-ale")
  finish
endif

" let g:lightline#ale#indicator_checking = "ale:\uf110"
" let g:lightline#ale#indicator_infos = "ale:\uf129"
" let g:lightline#ale#indicator_warnings = "ale:\uf071"
" let g:lightline#ale#indicator_errors = "ale:\uf05e"
" let g:lightline#ale#indicator_ok = "ale:\uf00c"
let g:lightline#ale#indicator_checking = "ale:..."
let g:lightline#ale#indicator_infos = "ale:I"
let g:lightline#ale#indicator_warnings = "ale:W"
let g:lightline#ale#indicator_errors = "ale:E"
let g:lightline#ale#indicator_ok = "ale:OK"
