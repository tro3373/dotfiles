if !g:plug.is_installed("gtags.vim")
  finish
endif

" カーソル位置の単語を Gtags で検索
nnoremap <C-j> :GtagsCursor<Enter>
" 関数一覧
nnoremap <C-l> :Gtags -f %<Enter>
" Grep
nnoremap <C-g> :Gtags -g
" 使用箇所検索
nnoremap <C-h> :Gtags -r
" 次の要素
nnoremap <C-n> :cn<Enter>
" １つ前の要素
nnoremap <C-p> :cp<Enter>
