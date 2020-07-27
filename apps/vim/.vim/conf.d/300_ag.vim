if !g:plug.is_installed("ag.vim")
  finish
endif

" カーソル位置の単語を ag 検索
nnoremap <Leader>g :Ag <C-R><C-W><CR>
vnoremap <Leader>g y:Ag <C-R>"<CR>
nnoremap <Leader>b :AgBuffer <C-R><C-W><CR>
vnoremap <Leader>b y:AgBuffer <C-R>"<CR>
