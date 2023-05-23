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
" let g:ale_lint_on_text_changed = 'always'
" Open時にチェック
let g:ale_lint_on_enter = 1
" ファイル保存時に実行
let g:ale_fix_on_save = 1
" 画面表示領域を常に表示
let g:ale_sign_column_always = 1
" エラーリストを常に表示
let g:ale_open_list = 1
" エラーと警告がなくなっても開いたままにするか
let g:ale_keep_list_wildow_open = 0
" ハイライト無効
highlight clear ALEErrorSign
highlight clear ALEWarningSign
" ALE completion
let g:ale_completion_enabled = 1


" シンボル変更
let g:ale_sign_error = '!!'
let g:ale_sign_warning = '=='
let g:ale_echo_msg_info_str = 'I'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
" let g:ale_echo_msg_format = '[%linter%] [%severity%] %code: %%s'
let g:ale_echo_msg_format = '[ALE:%linter%] %code: %%s'


" ローカルの設定ファイルを考慮する
let g:ale_javascript_prettier_use_local_config = 1

let g:ale_go_gofmt_options = '-s'
let g:ale_go_gometalinter_options = '--enable=gosimple --enable=staticcheck'

" Ignore shellcheck error
let g:ale_sh_shellcheck_options = '-e SC1090,SC2059,SC2155,SC2164,SC2086,SC2162'
" shfmt see .editorconfig?(not working... so specify option)
let g:ale_sh_shfmt_options = '-i 2 -ci -s'

" let g:ale_python_flake8_options = '--ignore=E501,E402,F401,E701' " ignore long-lines, import on top of the file, unused modules and statement with colon
" let g:ale_python_autopep8_options = '--ignore=E501'              " ignore long-lines for autopep8 fixer

" let g:ale_linters = {
"\   'javascript': ['eslint'],
"\   'shell': ['shellcheck'],
"\   'java': [],
"\   'python': ['flake8'],
"\}                                " 特定の言語のみチェック
"\   'java': [],
let g:ale_linters = {}
let g:ale_linters['javascript'] = ['eslint']
let g:ale_linters['typescript'] = ['eslint']
let g:ale_linters['shell'] = ['shellcheck']
let g:ale_linters['java'] = []
let g:ale_linters['python'] = ['flake8']
let g:ale_linters['go'] = ['gometalinter', 'gobuild']
let g:ale_linters['vue'] = ['eslint']
let g:ale_linters['json'] = ['jsonlint']


" function! MyShellCheckFixer(buffer) abort
"   " 'command': 'shellcheck -f diff %s |patch -p1'
"   return {
"\   'command': 'shellcheck -f diff %s | (cd / && patch -p1 >&/dev/null)',
"\}
" endfunction
" execute ale#fix#registry#Add('shellcheck_fixer', 'MyShellCheckFixer', ['shell'], 'shellcheck fixer for shell')

let g:ale_fixers = {}
" let g:ale_fixers['*']          = ['trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['(?!markdown)'] = ['trim_whitespace', 'remove_trailing_lines']
" let g:ale_fixers['javascript'] = ['prettier-eslint', 'prettier', 'eslint']
let g:ale_fixers['javascript'] = ['prettier', 'eslint']
let g:ale_fixers['typescript'] = ['prettier', 'eslint']
let g:ale_fixers['vue']        = ['prettier', 'eslint']
let g:ale_fixers['json']       = ['prettier', 'fixjson', 'jq']
let g:ale_fixers['scss']       = ['prettier', 'stylelint']
let g:ale_fixers['css']        = ['prettier', 'stylelint']
let g:ale_fixers['less']       = ['prettier', 'stylelint']
let g:ale_fixers['stylus']     = ['stylelint']
let g:ale_fixers['c']          = ['clang-format']
let g:ale_fixers['cpp']        = ['clang-format']
let g:ale_fixers['rust']       = ['rustfmt']
let g:ale_fixers['python']     = ['autopep8', 'yapf', 'isort']
let g:ale_fixers['zsh']        = ['shfmt']
let g:ale_fixers['sh']         = ['shfmt']
let g:ale_fixers['go']         = ['gofmt', 'goimports']
" let g:ale_fixers['markdown']   = ['prettier']
" let g:ale_fixers['markdown'] = [{buffer, lines -> {'command': 'textlint -c ~/.config/textlintrc -o /dev/null --fix --no-color --quiet %t', 'read_temporary_file': 1}}]
let g:ale_fixers['java']       = ['google_java_format']
" let g:ale_fixers['dart']       = ['dart']
let g:ale_fixers['sql']       = [ { buffer -> {'command': 'command -v sql-formatter >&/dev/null && sql-formatter --config ~/.dot/apps/sql-formatter/config.json'} } ]

" let g:ale_fix_on_save_ignore = ['sh', 'javascript']
" let g:ale_fix_on_save_ignore = ['markdown', 'javascript']
" let g:ale_fix_on_save_ignore = ['vue']


" Ctrl k+j でエラー間移動
" nmap <silent> <C-k> <Plug>(ale_previous_wrap)
" nmap <silent> <C-j> <Plug>(ale_next_wrap)
" alt k & j to jump through errors
nmap <silent> <M-k> <Plug>(ale_previous_wrap)
nmap <silent> <M-j> <Plug>(ale_next_wrap)

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
