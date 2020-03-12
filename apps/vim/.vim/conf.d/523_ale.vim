if !g:plug.is_installed('ale')
  finish
endif

"=============================================
" ale
"=============================================
" 画面表示領域を常に表示
let g:ale_sign_column_always = 1
" エラーリストを常に表示
let g:ale_open_list = 1
" エラーと警告がなくなっても開いたままにするか
let g:ale_keep_list_wildow_open = 0
" シンボル変更
let g:ale_sign_error = '!!'
let g:ale_sign_warning = '=='
" ハイライト無効
highlight clear ALEErrorSign
highlight clear ALEWarningSign

" 保存時チェック
let g:ale_lint_on_save = 1
" ファイル変更時チェック
let g:ale_lint_on_text_changed = 0
" Open時にチェック
let g:ale_lint_on_enter = 1
" ファイル保存時に実行
let g:ale_fix_on_save = 1
" ローカルの設定ファイルを考慮する
let g:ale_javascript_prettier_use_local_config = 1

" Ignore shellcheck error
let g:ale_sh_shellcheck_options = '-e SC1090,SC2059,SC2155,SC2164,SC2086,SC2162'

let g:ale_go_gofmt_options = '-s'
let g:ale_go_gometalinter_options = '--enable=gosimple --enable=staticcheck'
let g:ale_completion_enabled = 1
let g:ale_echo_msg_info_str = 'I'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
" let g:ale_echo_msg_format = '[%linter%] [%severity%] %code: %%s'
let g:ale_echo_msg_format = '[%linter%] %code: %%s'


" let g:ale_linters = {
"\   'javascript': ['eslint'],
"\   'shell': ['shellcheck'],
"\   'java': [],
"\   'python': ['flake8'],
"\}                                " 特定の言語のみチェック
"\   'java': [],
let g:ale_linters = {}
let g:ale_linters['javascript'] = ['eslint']
let g:ale_linters['shell'] = ['shellcheck']
let g:ale_linters['java'] = []
let g:ale_linters['python'] = ['flake8']
let g:ale_linters['go'] = ['gometalinter', 'gobuild']


let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier-eslint', 'prettier', 'eslint', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['json']       = ['prettier', 'fixjson', 'jq',  'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['scss']       = ['prettier', 'stylelint', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['css']        = ['prettier', 'stylelint', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['less']       = ['prettier', 'stylelint', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['stylus']     = ['stylelint', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['c']          = ['clang-format', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['cpp']        = ['clang-format', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['rust']       = ['rustfmt', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['python']     = ['autopep8', 'yapf', 'isort', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['zsh']        = ['shfmt', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['sh']         = ['shfmt', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['go']         = ['gofmt', 'goimports', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['markdown']   = ['prettier']
" let g:ale_fixers['markdown'] = [{buffer, lines -> {'command': 'textlint -c ~/.config/textlintrc -o /dev/null --fix --no-color --quiet %t', 'read_temporary_file': 1}}]
let g:ale_fixers['vue']        = ['prettier', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['java']       = ['google_java_format', 'trim_whitespace', 'remove_trailing_lines']

" let g:ale_fix_on_save_ignore = ['sh', 'javascript']


" Ctrl k+j でエラー間移動
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
" " alt k & j to jump through errors
" nmap <silent> <M-k> <Plug>(ale_previous_wrap)
" nmap <silent> <M-j> <Plug>(ale_next_wrap)

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

" if dein#tap('lightline.vim')
"   autocmd MyAutoGroup User ALELint call lightline#update()
" endif


"" Disable for minified code and enable whitespace trimming
let g:ale_pattern_options = {
  \ '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
  \ '\.min\.css$': {'ale_linters': [], 'ale_fixers': []}}",
  "\ '\.*': {'ale_fixers': ['trim_whitespace', 'remove_trailing_lines']}}

" @see more https://wonderwall.hatenablog.com/entry/2017/03/01/223934
" @see more https://git.redbrick.dcu.ie/butlerx/dotfiles/src/commit/a2a016568fe534242589dbd9e476db8861d2f592/vimrc.d/ale.vim
