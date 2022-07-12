if !g:plug.is_installed("preview-markdown.vim")
  finish
endif

" Preview in buffer Plugin

" see [skanehira/preview-markdown.vim: Markdown preview plugin for Vim](https://github.com/skanehira/preview-markdown.vim)
" :PreviewMarkdown [left|top|right|bottom|tab]

" skanehira/preview-markdown.vim用の設定値
let g:preview_markdown_vertical = 1
let g:preview_markdown_auto_update = 1
