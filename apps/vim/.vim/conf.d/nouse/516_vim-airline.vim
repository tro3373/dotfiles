if !g:plug.is_installed("vim-airline")
  finish
endif

"" Powerline font を使用する
let g:airline_powerline_fonts = 1
" tabline 設定
let g:airline#extensions#tabline#enabled = 1
" タブに何かしらの番号を表示する設定
let g:airline#extensions#tabline#show_tab_nr = 1
" タブ番号を表示する設定
let g:airline#extensions#tabline#tab_nr_type = 1
" タブ区切り設定
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = '|'
" branch 表示
let g:airline#extensions#branch#enabled = 1
" hunk 表示
let g:airline#extensions#hunks#enabled = 1
