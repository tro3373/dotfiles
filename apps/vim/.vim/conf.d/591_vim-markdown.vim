if !g:plug.is_installed("vim-markdown")
  finish
endif

"=============================================
" Markdown Preview Syntax etc
" 'plasticboy/vim-markdown'
" vim-markdown, preview, open-browser
"=============================================
" hide/no hide markdown controll word
let g:vim_markdown_conceal = 1
" 折りたたみ設定
let g:vim_markdown_folding_disabled=1

