if !g:plug.is_installed("vim-markdown")
  finish
endif

"=============================================
" Markdown Syntax etc
" 'preservim/vim-markdown'
"=============================================
" hide/no hide markdown controll word
let g:vim_markdown_conceal = 1
" 0 Text is shown normally
" 1 Each block of concealed text is replaced with one
"   character.  If the syntax item does not have a custom
"   replacement character defined (see |:syn-cchar|) the
"   character defined in 'listchars' is used.
"   It is highlighted with the "Conceal" highlight group.
" 2 Concealed text is completely hidden unless it has a
"   custom replacement character defined (see
"   |:syn-cchar|).
" 3 Concealed text is completely hidden.
" set conceallevel = 2
" let g:vim_markdown_conceal_code_blocks = 0

" [vim-markdownを入れた時にインサートモードが遅くなったときの回避法 - ごずろぐ](https://gozuk16.hatenablog.com/entry/2017/12/27/232441)
" 折りたたみ設定
let g:vim_markdown_folding_disabled=1

let g:vim_markdown_liquid=1
let g:vim_markdown_math=0
let g:vim_markdown_frontmatter=1
let g:vim_markdown_toml_frontmatter=1
let g:vim_markdown_json_frontmatter=0

" 自動インデントのサイズを4(default)=>2に変更
let g:vim_markdown_new_list_item_indent = 2

set nofoldenable
