if !g:plug.is_installed("nerdtree")
  finish
endif

"=============================================
" NERDTree 設定
"=============================================
" 隠しファイルをデフォルトで表示させる
let NERDTreeShowHidden = 1
" デフォルトでツリーを表示させる
" autocmd VimEnter * execute 'NERDTree'
"<C-e>でNERDTreeをオンオフ
" map <silent> <C-e>   :NERDTreeToggle<CR>
" lmap <silent> <C-e>  :NERDTreeToggle<CR>
nmap <silent> <C-e>      :NERDTreeToggle<CR>
vmap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
omap <silent> <C-e>      :NERDTreeToggle<CR>
imap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
