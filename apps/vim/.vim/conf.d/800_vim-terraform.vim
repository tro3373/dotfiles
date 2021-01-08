if !g:plug.is_installed('vim-terraform')
  finish
endif

"=============================================
" hashivim/vim-terraform
"=============================================
" " Allow vim-terraform to align settings automatically with Tabularize.
" let g:terraform_align=1
" " Allow vim-terraform to automatically fold (hide until unfolded) sections of terraform code. Defaults to 0 which is off.
" let g:terraform_fold_sections=1
" Allow vim-terraform to automatically format
let g:terraform_fmt_on_save = 1
