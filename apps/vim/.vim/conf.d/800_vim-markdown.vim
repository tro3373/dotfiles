if !g:plug.is_installed("vim-markdown")
  finish
endif

"=============================================
" Markdown Syntax etc
" 'plasticboy/vim-markdown'
"=============================================
" hide/no hide markdown controll word
let g:vim_markdown_conceal = 1

" [vim-markdownを入れた時にインサートモードが遅くなったときの回避法 - ごずろぐ](https://gozuk16.hatenablog.com/entry/2017/12/27/232441)
" 折りたたみ設定
let g:vim_markdown_folding_disabled=1

let g:vim_markdown_liquid=1
let g:vim_markdown_math=0
let g:vim_markdown_frontmatter=1
let g:vim_markdown_toml_frontmatter=1
let g:vim_markdown_json_frontmatter=0

set nofoldenable
