" Markdown 見出し/リンク色の SSOT
" 旧 vim の vim-markdown syntax group (htmlH1 等) と
" nvim-treesitter の @markup group の両方が参照する。
let g:md_palette = {
  \ 'h1':   {'gui': '#a3be8c', 'cterm': 144},
  \ 'h2':   {'gui': '#81a1c1', 'cterm': 109},
  \ 'h3':   {'gui': '#d08770', 'cterm': 173},
  \ 'link2': {'gui': '#ff8800', 'cterm': 208},
  \ 'link': {'gui': '#fff1ab', 'cterm': 208},
  \ 'marker': {'gui': '#5f87af', 'cterm': 67},
  \ }
