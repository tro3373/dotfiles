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
" " エラーリストウィンドウのサイズ
" let g:ale_list_window_size = 20
" ALEInfo ウィンドウのサイズ
augroup ALEInfoResize
  autocmd!
  autocmd FileType ale-info resize 30
augroup END
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
let g:ale_echo_msg_format = '[ALE:%linter%] [%severity%] [%code]: %%s'

" Disable LSP
let g:ale_disable_lsp = 0

" Linter
let g:ale_linters = {}
let g:ale_linters['javascript'] = ['biome', 'eslint']
let g:ale_linters['typescript'] = ['biome', 'eslint']
let g:ale_linters['javascriptreact'] = ['biome', 'eslint']
let g:ale_linters['typescriptreact'] = ['biome', 'eslint']
let g:ale_linters['shell'] = ['shellcheck']
let g:ale_linters['java'] = []
" let g:ale_linters['python'] = ['black', 'flake8', 'mypy']
" let g:ale_linters['python'] = ['flake8', 'mypy', 'pylint', 'pyright']
let g:ale_linters['python'] = ['ruff']
let g:ale_linters['go'] = ['golangci-lint', 'gobuild', 'staticcheck']
let g:ale_linters['vue'] = ['eslint']
let g:ale_linters['json'] = ['jsonlint']
let g:ale_linters['terraform'] = ['tflint', 'tfsec']
" let g:ale_linters['terraform'] = ['tflint']
let g:ale_linters['lua'] = ['luacheck']
let g:ale_linters['Dockerfile'] = ['hadolint']

" Fixer
let g:ale_fixers = {}
" let g:ale_fixers['*']          = ['trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['(?!markdown)'] = ['trim_whitespace', 'remove_trailing_lines']
" let g:ale_fixers['javascript'] = ['prettier-eslint', 'prettier', 'eslint']
let g:ale_fixers['javascript'] = ['biome', 'prettier', 'eslint']
let g:ale_fixers['typescript'] = ['biome', 'prettier', 'eslint']
let g:ale_fixers['javascriptreact'] = ['biome', 'prettier', 'eslint']
let g:ale_fixers['typescriptreact'] = ['biome', 'prettier', 'eslint']
let g:ale_fixers['vue']        = ['prettier', 'eslint']
let g:ale_fixers['json']       = ['prettier', 'fixjson', 'jq']
let g:ale_fixers['scss']       = ['prettier', 'stylelint']
let g:ale_fixers['css']        = ['prettier', 'stylelint']
let g:ale_fixers['less']       = ['prettier', 'stylelint']
let g:ale_fixers['xml']        = ['xmllint']
let g:ale_fixers['stylus']     = ['stylelint']
let g:ale_fixers['c']          = ['clang-format']
let g:ale_fixers['cpp']        = ['clang-format']
let g:ale_fixers['rust']       = ['rustfmt']
" let g:ale_fixers['python']     = ['autopep8', 'yapf', 'isort']
" let g:ale_fixers['python']     = ['autoflake', 'black', 'isort', 'ruff']
" let g:ale_fixers['python']     = [ { buffer -> {'command': 'command -v task >&/dev/null && task fix'} } ]
let g:ale_fixers['python']     = ['ruff_format']
let g:ale_fixers['zsh']        = ['shfmt']
let g:ale_fixers['sh']         = ['shfmt']
let g:ale_fixers['go']         = ['goimports', 'gopls', 'gofmt' ]
" let g:ale_fixers['terraform']  = ['tflint']
let g:ale_fixers['terraform']  = ['trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers['yaml']       = ['yamlfmt']
let g:ale_fixers['lua']        = ['stylua']
" let g:ale_fixers['markdown']   = ['prettier']
" let g:ale_fixers['markdown'] = [{buffer, lines -> {'command': 'textlint -c ~/.config/textlintrc -o /dev/null --fix --no-color --quiet %t', 'read_temporary_file': 1}}]
" let g:ale_fixers['java']       = ['google_java_format']
let g:ale_fixers['java']       = [ { buffer -> {'command': 'command -v google-java-format>&/dev/null && google-java-format -a %s'} } ]
" let g:ale_fixers['dart']       = ['dart']
let g:ale_fixers['sql']        = [ { buffer -> {'command': 'command -v sql-formatter >&/dev/null && sql-formatter --config ~/.dot/apps/sql-formatter/config.json'} } ]
let g:ale_fixers['Dockerfile'] = [ { buffer -> {'command': 'command -v dockerfmt >&/dev/null && dockerfmt version >&/dev/null && dockerfmt -w %s', 'read_buffer': 1} } ]
" function! MyShellCheckFixer(buffer) abort
"   " 'command': 'shellcheck -f diff %s |patch -p1'
"   return {
"\   'command': 'shellcheck -f diff %s | (cd / && patch -p1 >&/dev/null)',
"\}
" endfunction
" execute ale#fix#registry#Add('shellcheck_fixer', 'MyShellCheckFixer', ['shell'], 'shellcheck fixer for shell')


" 各言語毎のオプション設定
" JavaScript/TypeScript
" let g:ale_javascript_prettier_use_local_config = 1 " ローカルの設定ファイルを考慮する
let g:ale_biome_fixer_apply_unsafe = 1 " --unsafe オプションを有効にする
" let g:ale_biome_executable = 'npx biome'
" let g:ale_biome_executable = './node_modules/.bin/biome'
" let g:ale_biome_options = '--write --unsafe'


" Go
let g:ale_go_golangci_lint_package = 1 "When set to `1`, the whole Go package will be checked instead of only the current file.
let g:ale_go_gofmt_options = '-s'
" " errcheck: check for unchecked errors
" let g:ale_go_golangci_lint_options = '-D errcheck'
let g:ale_go_gometalinter_options = '--enable=gosimple --enable=staticcheck'
" ST1000: - Incorrect or missing package comment
" パッケージに対する適切なコメントがない、または不適切なコメントがある場合に警告します。
" パッケージの目的や機能を簡潔に説明するコメントを期待します。
" ST1003: - Poorly chosen identifier
" 不適切な識別子（変数名、関数名、パッケージ名など）を使用している場合に警告します。
" 主な規則:
" パッケージ名は小文字のみを使用し、アンダースコアやキャメルケースを避ける
" 変数名やメソッド名は適切なキャメルケースを使用する
" 頭字語（例: URL、HTTP）は大文字または小文字で一貫して使用する
" ST1016: - Use consistent method receiver names
" 同じ型に対するメソッドレシーバの名前が一貫していない場合に警告します。
" 例えば、同じ構造体に対して異なるレシーバ名を使用すると警告されます:
" let g:ale_go_staticcheck_options = '-checks=all,-ST1000,-ST1003,-ST1016'
" ST1020: - The documentation of an exported function should start with the function's name
" エクスポートされた関数のドキュメンテーションコメントは、その関数の名前で始まるべき
let g:ale_go_staticcheck_options = '-checks=all,-ST1000'

" Shell
" SC1090: Use of uninitialized value. This warning is triggered when a shell script uses a variable that is not set.
" SC2059: Command not found. This warning is triggered when a shell script uses a command that is not executable.
" SC2155: Use of uninitialized value. This warning is triggered when a shell script uses a variable that is not declared.
" SC2164: Command not found in PATH. This warning is triggered when a shell script uses a command that is not found in the system's PATH.
" SC2086: Syntax error. This warning is triggered when a shell script uses a command with invalid syntax.
" SC2162: Command not found or not executable. This warning is triggered when a shell script uses a command that is not a valid command or not executable.
" SC2034: Unused variable. This warning is triggered when a shell script
let g:ale_sh_shellcheck_options = '-e SC1090,SC2059,SC2155,SC2164,SC2086,SC2162' " Ignore shellcheck error
" NOT WORK
" " .env ファイルに対してのみ SC2034 を無視
" " b: バッファローカル変数
" autocmd BufNewFile,BufRead .env let b:ale_sh_shellcheck_options = '-e SC1090,SC2059,SC2155,SC2164,SC2086,SC2162,SC2034'
"  -i,  --indent uint       0 for tabs (default), >0 for number of spaces
" -ci, --case-indent       switch cases will be indented
"  -s,  --simplify  simplify the code
let g:ale_sh_shfmt_options = '-i 2 -ci -s' " shfmt see .editorconfig?(not working... so specify option)

" Python
" let g:ale_python_autopep8_options = '--ignore=E501'              " ignore long-lines for autopep8 fixer
" W503: line break before binary operator
" E501: line too long
" E203: whitespace before ':'
" F401: module imported but unused
" E402: module level import not at top of file
" E701: multiple statements on one line (colon)
let g:ale_python_flake8_options = '--max-line-length=120 --ignore=W503,E501,E203'
" let g:ale_python_autopep8_options = ''
" let g:ale_python_isort_options = ''
" let g:ale_python_black_options = ''
" --ignore-missing-imports: ignore missing imports.
" --follow-imports=skip: controls how mypy handles imports.
"   The follow-imports option can take three values: normal, skip, and silent.
"     normal (default): follow imports and check the imported modules.
"     skip: skip checking the imported modules. This means that if an imported module has errors, mypy will not report them.
"     silent: not follow imports at all.
"             This means that if an imported module has errors,
"             mypy will not report them,
"             and the errors will only be reported
"             when the imported module is actually used.
let g:ale_python_mypy_options = '--ignore-missing-imports --follow-imports=skip'
" Terraform
" let g:ale_terraform_tflint_options = '-f json --recursive'

" let g:ale_fix_on_save_ignore = ['sh', 'javascript']
" let g:ale_fix_on_save_ignore = ['markdown', 'javascript']
" let g:ale_fix_on_save_ignore = ['vue']
"
" Dockerfile
" DL3008: Pin versions in apt-get install.
" DL3018: Pin versions in apk add
let g:ale_dockerfile_hadolint_options = '--ignore DL3008 --ignore DL3018'


" Disable for minified code and enable whitespace trimming
" Disable md linter because so slow.
" Disable linter for ui components(shadcn)
let g:ale_pattern_options = {
\   '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
\   '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
\   'md$': {'ale_linters': []},
\   '.*/node_modules/.*.ts$': {'ale_linters': [], 'ale_fixers': []},
\   '.*/node_modules/.*.js$': {'ale_linters': [], 'ale_fixers': []},
\   '.*/components/ui/.*.tsx$': {'ale_linters': [], 'ale_fixers': []},
\   '.*/site-packages/.*.py$': {'ale_linters': [], 'ale_fixers': []},
\   '.*/site-packages/.*.pyi$': {'ale_linters': [], 'ale_fixers': []},
\   '.*/go/pkg/mod/.*.go$': {'ale_linters': [], 'ale_fixers': []},
\   '.*/usr/lib/go/.*.go$': {'ale_linters': [], 'ale_fixers': []},
\   '.*/gen.go$': {'ale_linters': [], 'ale_fixers': []},
\   '/var/lib/snapd/snap/go/.*\.go$': {'ale_enabled': 0},
\   '/usr/local/go/.*\.go$': {'ale_enabled': 0},
\}
"\ 'pattern': {'ale_linters': [], 'ale_fixers': []},
"\ '\.*': {'ale_fixers': ['trim_whitespace', 'remove_trailing_lines']}}

" @see more https://wonderwall.hatenablog.com/entry/2017/03/01/223934
" @see more https://git.redbrick.dcu.ie/butlerx/dotfiles/src/commit/a2a016568fe534242589dbd9e476db8861d2f592/vimrc.d/ale.vim


" Mapping
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

function! ToggleALE() abort
  if !exists('g:ale_enabled')
    return
  endif
  if g:ale_enabled
    ALEDisable
    let g:ale_enabled = 0
    echo "==> ALE disabled."
  else
    ALEEnable
    let g:ale_enabled = 1
    echo "==> ALE enabled."
  endif
endfunction
command! ToggleALE call ToggleALE()
nnoremap <silent> <Space>b :call ToggleALE()<CR>
