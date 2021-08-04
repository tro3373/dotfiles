if !g:plug.is_installed("vim-markdown")
  finish
endif

"=============================================
" Markdown Syntax etc
" 'plasticboy/vim-markdown'
"=============================================
" hide/no hide markdown controll word
let g:vim_markdown_conceal = 1
" 折りたたみ設定
let g:vim_markdown_folding_disabled=1
