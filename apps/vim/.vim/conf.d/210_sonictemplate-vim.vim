" Indent Guide Settings
if !g:plug.is_installed("sonictemplate-vim")
  finish
endif

let g:sonictemplate_vim_template_dir = expand('~/.vim/sonictemplate')

let g:sonictemplate_key = '<leader>k'
let g:sonictemplate_intelligent_key = '<leader>K'
let g:sonictemplate_postfix_key = '<leader>k'
