if !g:plug.is_installed("vim-lsp")
  finish
endif

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  " nmap <buffer> gd <plug>(lsp-definition)
  " nmap <buffer> <C-]> <plug>(lsp-definition)
  nmap <buffer> <C-]> :tab split<cr>:LspDefinition<cr>
  " nmap <buffer> <C-]> :tab LspDefinition<cr>
  " nmap <buffer> <C-]> :leftabove LspDefinition
  " nmap <buffer> <C-]> :rightbelow vertical LspDefinition<cr>
  " nmap <buffer> <C-]> :tab LspDefinition
  " nmap <buffer> <C-]> LspDefinition
  nmap <buffer> <f2> <plug>(lsp-rename)
  nmap <buffer> <C-n> <plug>(lsp-next-error)
  nmap <buffer> <C-p> <plug>(lsp-previouse-error)
  " Auto Import
  autocmd BufWritePre <buffer> call execute('LspCodeActionSync source.organizeImports')
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  " https://qiita.com/kitagry/items/216c2cf0066ff046d200
  " Auto Format
  " autocmd BufWritePre <buffer> LspDocumentFormatSync
augroup END
command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('$HOME/.vim/lsp.log')
let g:lsp_log_verbose=1
let g:lsp_log_file = expand('$HOME/.vim/lsp.log')

" let g:lsp_signs_enabled = 1
" let g:lsp_signs_error = {'text': '✗'}
" let g:lsp_signs_warning = {'text': '‼', 'icon': '/path/to/some/icon'}
" let g:lsp_signs_hint = {'text': 'h', 'icon': '/path/to/some/other/icon'}

let g:lsp_diagnostics_enabled = 1           " ファイルの変更に伴いリアルタイムにエラー表示
let g:lsp_diagnostics_echo_cursor = 1       " enable echo under cursor when in normal mode
let g:lsp_diagnostics_echo_delay = 500      " diagnostics の表示ディレイ設定
" (WARN) indent-guid and float setting enable will be error!
let g:lsp_diagnostics_float_cursor = 0      " enable echo floating cursor when in normal mode
let g:lsp_diagnostics_float_delay = 500     " diagnostics の表示ディレイ設定

let g:lsp_text_edit_enabled = 1             " textEdit を有効(LS がバグってるなら無効に)
let g:lsp_virtual_text_enabled = 0
let g:lsp_fold_enabled = 0                  " 折り畳み無効
let g:lsp_signature_help_enabled = 1        " シグニチャヘルプ(重い場合は無効に)
let g:lsp_completion_resolve_timeout = 0    " 補完候補情報の問い合わせをブロックしない(Ctrl+n,pでガタつく場合に設定)
let g:lsp_anync_completion = 0              " 補完候補の問い合わせをブロックしない(重い場合に設定)


let g:asyncomplete_log_file = expand('$HOME/.vim/asyncomplete.log')
" let g:asyncomplete_popup_delay = 200        " ポップアップ表示ディレイ(default: 30)
let g:asyncomplete_auto_popup = 1           " 自動で入力補完ポップアップを表示

" To enable preview window
" allow modifying the completeopt variable, or it will be overridden all the time
let g:asyncomplete_auto_completeopt = 0     " 自動で入力補完ポップアップを表示
" menuone:対象が1件しかなくても常に補完ウィンドウを表示
" noinsert:補完ウィンドウを表示時に挿入しない
" noselect:メニューからマッチを {訳注:自動では} 選択せず、ユーザーに自分で選ぶことを強制する。
" preview:現在選択されている候補についての付加的な情報をプレビューウィンドウに表示する。
" set completeopt=menuone,noinsert
" set completeopt+=preview
" set completeopt=menuone,noinsert,noselect,preview
set completeopt=menuone,noinsert,noselect


" 補完表示時のEnterで改行をしない
inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" imap <c-space> <Plug>(asyncomplete_force_refresh)


" " 動作が重くなるのを回避するのにファイルタイプを指定して、asyncompleteを有効にする場合
" " see https://qiita.com/hokorobi/items/b4be36253262373fbefc
" let g:asyncomplete_enable_for_all = 0
" autocmd vimrc FileType autohotkey,autoit,cfg,git,go,groovy,java,javascript,python,snippet,toml,vim,vb,xsl call asyncomplete#enable_for_buffer()


" completor の登録
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
   \ 'name': 'neosnippet',
   \ 'whitelist': ['*'],
   \ 'priority': 5,
   \ 'completor': function('asyncomplete#sources#neosnippet#completor'),
   \ }))
" au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
"      \ 'name': 'buffer',
"      \ 'priority': 11,
"      \ 'whitelist': ['*'],
"      \ 'completor': function('asyncomplete#sources#buffer#completor'),
"      \ }))
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
     \ 'name': 'file',
     \ 'priority': 12,
     \ 'whitelist': ['*'],
     \ 'completor': function('asyncomplete#sources#file#completor'),
     \ }))
" au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necosyntax#get_source_options({
"      \ 'name': 'necosyntax',
"      \ 'priority': 9,
"      \ 'whitelist': ['*'],
"      \ 'completor': function('asyncomplete#sources#necosyntax#completor'),
"      \ }))
" au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
"      \ 'name': 'necovim',
"      \ 'whitelist': ['vim'],
"      \ 'priority': 10,
"      \ 'completor': function('asyncomplete#sources#necovim#completor'),
"      \ }))

" language server を指定
" let g:lsp_settings_filetype_javascript = ['eslint-language-server']
" let g:lsp_settings = {
"\   'pyls': {
"\     'workspace_config': {
"\       'pyls': {
"\         'configurationSources': ['flake8']
"\       }
"\     }
"\   },
"\}

