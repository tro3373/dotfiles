if !g:plug.is_installed("vim-markdown")
  finish
endif

" 見出し/リンク色の SSOT を読み込む (ロード順非依存にするため明示 source)
let s:md_palette_file = expand('<sfile>:p:h') . '/010_md_palette.vim'
if filereadable(s:md_palette_file)
  execute 'source' s:md_palette_file
endif

"=============================================
" Colorscheme for Markdown files
" NOTE: check syntax group
"   `:echo synIDattr(synID(line('.'), col('.'), 1), 'name')`
function! s:MarkdownHighlight()
  if !exists('g:md_palette')
    return
  endif
  let p = g:md_palette
  execute 'highlight mkdLink guifg=' . p.link.gui . ' ctermfg=' . p.link.cterm
  execute 'highlight htmlH1 guifg=' . p.h1.gui . ' ctermfg=' . p.h1.cterm
  execute 'highlight htmlH2 guifg=' . p.h2.gui . ' ctermfg=' . p.h2.cterm
  execute 'highlight htmlH3 guifg=' . p.h3.gui . ' ctermfg=' . p.h3.cterm
  execute 'highlight mkdHeading guifg=' . p.h2.gui . ' ctermfg=' . p.h2.cterm
endfunction
autocmd FileType markdown call s:MarkdownHighlight()
"=============================================
"
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

" 自動インデントのサイズを4(default)=>0に変更
" NOTE: 0 で次の行の開始位置を前の行と同じにする!
let g:vim_markdown_new_list_item_indent = 0

set nofoldenable
