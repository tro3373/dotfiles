"=============================================
" Grep 設定
"=============================================
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column --hidden'
  let g:unite_source_grep_recursive_opt = ''
  " let g:unite_source_grep_max_candidates = 200
elseif executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor'
  let g:unite_source_grep_recursive_opt = ''
else
  " カーソル位置の単語を ag 検索
  nnoremap <silent> <Leader>g :<C-u>Unite grep:. -direction=botright -auto-resize -buffer-name=search-buffer<CR><C-R><C-W><CR>
  " ビジュアルモードでは、選択した文字列をunite-grep
  vnoremap <silent> <Leader>g y:Unite grep:.:-iRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>
  " ディレクトリを指定して ag 検索
  nnoremap <silent> ,g :<C-u>Unite grep -direction=botright -auto-resize -buffer-name=search-buffer<CR>
  " grep検索結果の再呼出
  nnoremap <silent> ,r :<C-u>UniteResume search-buffer -direction=botright -auto-resize<CR>
endif
