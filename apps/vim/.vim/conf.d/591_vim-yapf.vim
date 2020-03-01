if !g:plug.is_installed('vim-yapf')
  finish
endif

"=============================================
" yapf
"=============================================
let g:yapf_style = "pep8"
" let g:yapf_style = "google"
nnoremap <leader>f :call Yapf()<cr>
