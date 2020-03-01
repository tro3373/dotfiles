if !g:plug.is_installed('ale')
  finish
endif

"=============================================
" ale
"=============================================
" 保存時チェック
let g:ale_lint_on_save = 1
" ファイル変更時チェック
let g:ale_lint_on_text_changed = 0
" Open時にチェック
let g:ale_lint_on_enter = 1
" 画面表示領域を常に表示
let g:ale_sign_column_always = 1
" エラーリストを常に表示
let g:ale_open_list = 1
" エラーと警告がなくなっても開いたままにするか
let g:ale_keep_list_wildow_open = 0

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'shell': ['shellcheck'],
\   'java': [],
\   'python': ['flake8'],
\}                                " 特定の言語のみチェック
"\   'java': [],
" let g:ale_sign_error = '!!'
" let g:ale_sign_warning = '=='

let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier-eslint']

" ファイル保存時に実行
let g:ale_fix_on_save = 1

" ローカルの設定ファイルを考慮する
let g:ale_javascript_prettier_use_local_config = 1

" Ctrl k+j でエラー間移動
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)


" nmap <silent> <Subleader>p <Plug>(ale_previous)
" nmap <silent> <Subleader>n <Plug>(ale_next)
" nmap <silent> <Subleader>a <Plug>(ale_toggle)
"
" function! s:ale_list()
"   let g:ale_open_list = 1
"   call ale#Queue(0, 'lint_file')
" endfunction
" command! ALEList call s:ale_list()
" nnoremap <Subleader>m  :ALEList<CR>
" autocmd MyAutoGroup FileType qf nnoremap <silent> <buffer> q :let g:ale_open_list = 0<CR>:q!<CR>
" autocmd MyAutoGroup FileType help,qf,man,ref let b:ale_enabled = 0
"
" if dein#tap('lightline.vim')
"   autocmd MyAutoGroup User ALELint call lightline#update()
" endif
"
let g:ale_sh_shellcheck_options = '-e SC1090,SC2059,SC2155,SC2164,SC2086,SC2162'
