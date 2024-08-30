if !g:plug.is_installed("vim-lsp") || g:is_windows
  finish
endif

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  " nmap <buffer> gd <plug>(lsp-definition)
  " nmap <buffer> <C-]> <plug>(lsp-definition)
  " nmap <buffer> <C-]> :tab split<cr>:LspDefinition<cr>
  nmap <buffer> <C-]> :tab LspDefinition<cr>
  " nmap <buffer> <C-]> :tab LspDefinition<cr>
  " nmap <buffer> <C-]> :leftabove LspDefinition
  " nmap <buffer> <C-]> :rightbelow vertical LspDefinition<cr>
  " nmap <buffer> <C-]> :tab LspDefinition
  " nmap <buffer> <C-]> LspDefinition
  nmap <buffer> <C-[> <plug>(lsp-document-diagnostics)
  nmap <buffer> <f1> <plug>(lsp-code-action)
  nmap <buffer> <f2> <plug>(lsp-rename)
  nmap <buffer> <C-n> <plug>(lsp-next-error)
  nmap <buffer> <C-p> <plug>(lsp-previouse-error)

  " Official settings
  " nmap <buffer> gd <plug>(lsp-definition)
  " nmap <buffer> gr <plug>(lsp-references)
  " nmap <buffer> gi <plug>(lsp-implementation)
  " nmap <buffer> gt <plug>(lsp-type-definition)
  " nmap <buffer> <leader>rn <plug>(lsp-rename)
  " nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
  " nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
  " nmap <buffer> K <plug>(lsp-hover)
  " ------------------------------------------------------------------------------------------------------------------
  " WARNING!!! `LspCodeActionSync source.organizeImports` is not work in nvim.
  "            disable codeaction on save because now code format will run in
  "            ale plugin.
  " https://qiita.com/kitagry/items/216c2cf0066ff046d200
  " Auto Import
  " autocmd BufWritePre <buffer> call execute('LspCodeActionSync source.organizeImports')
  " Auto Format
  " autocmd BufWritePre <buffer> LspDocumentFormatSync
  " autocmd BufWritePre <buffer> call execute(['LspCodeActionSync source.organizeImports'])
  " autocmd BufWritePre <buffer> call execute(['LspDocumentFormatSync'])
  " autocmd BufWritePre <buffer> call execute(['LspCodeActionSync source.organizeImports', 'LspDocumentFormatSync'])
  " ------------------------------------------------------------------------------------------------------------------
  let g:lsp_format_sync_timeout = 1000        " disable timeout in format sync. (default is -1(disabled))
  " autocmd! BufWritePre *.rs,*.go,*.yml call execute('LspDocumentFormatSync')
  autocmd! BufWritePre *.rs,*.go,*.yml call execute(['LspCodeActionSync source.organizeImports', 'LspDocumentFormatSync'])
  " MEMO: Buggy!! LspCodeActionSync source.organizeImports
  " autocmd! BufWritePre *.java call execute(['LspCodeActionSync source.organizeImports', 'LspDocumentFormatSync'])
  " autocmd! BufWritePre *.java call execute('LspDocumentFormatSync')
  " autocmd! BufEnter * call execute('LspDocumentDiagnostic')
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('$HOME/vim_lsp.log')
command! LspDebugAsyncComplete let g:asyncomplete_log_file = expand('$HOME/vim_asyncomplete.log')

" let g:lsp_signs_enabled = 1
" let g:lsp_signs_information = {'text': 'i'}
" let g:lsp_signs_error = {'text': '✗'}
" let g:lsp_signs_warning = {'text': '‼'}
" let g:lsp_signs_hint = {'text': 'H'}
" let g:lsp_signs_hint = {'text': 'h', 'icon': '/path/to/some/other/icon'}

" let g:lsp_diagnostics_virtual_text_enabled = 0 " 行末にエラー表示するかどうか

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

" pylsp: [vim-lsp の pyls が重いのをなんとかする - Qiita](https://qiita.com/CutBaum/items/f8b8582db5d64fae11c7)
" pycodestyle
"
" E501 line too long
let g:lsp_settings = {
  \  'yaml-language-server': {
  \     'workspace_config': {
  \       'yaml': {
  \         'customTags': [
  \           '!fn',
  \           '!And',
  \           '!If',
  \           '!Not',
  \           '!Equals',
  \           '!Or',
  \           '!FindInMap sequence',
  \           '!Base64',
  \           '!Cidr',
  \           '!Ref',
  \           '!Ref Scalar',
  \           '!Sub',
  \           '!GetAtt',
  \           '!GetAZs',
  \           '!ImportValue',
  \           '!Select',
  \           '!Split',
  \           '!Join sequence'
  \         ],
  \       },
  \     },
  \   },
  \   'pylsp-all': {
  \     'workspace_config': {
  \       'pylsp': {
  \         'configurationSources': ['flake8'],
  \         'plugins': {
  \           'flake8': {
  \             'enabled': v:true,
  \             'ignore': ["E501", "W503"],
  \           },
  \           'jedi_definition': {
  \             'enabled': v:true,
  \             'follow_imports': v:true,
  \             'follow_builtin_imports': v:true,
  \           },
  \           'pycodestyle': {
  \             'ignore': ["E501", "W503"],
  \           },
  \           'pylsp_mypy': {
  \             'enabled': v:true,
  \             'strict': v:true,
  \           }
  \         },
  \       }
  \     }
  \   },
  \   'sumneko-lua-language-server': {
  \     'workspace_config': {
  \       'Lua': {
  \         'diagnostics': {
  \           'globals': ["vim"]
  \         }
  \       }
  \     }
  \   },
\}

" 補完表示時のEnterで改行をしない
inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" imap <c-space> <Plug>(asyncomplete_force_refresh)


" " 動作が重くなるのを回避するのにファイルタイプを指定して、asyncompleteを有効にする場合
" " see https://qiita.com/hokorobi/items/b4be36253262373fbefc
" let g:asyncomplete_enable_for_all = 0
" autocmd vimrc FileType autohotkey,autoit,cfg,git,go,groovy,java,javascript,python,snippet,toml,vim,vb,xsl call asyncomplete#enable_for_buffer()


" Enable priority sort
function! s:sort_by_priority_preprocessor(options, matches) abort
  let l:items = []
  for [l:source_name, l:matches] in items(a:matches)
    for l:item in l:matches['items']
      if stridx(l:item['word'], a:options['base']) == 0
        let l:item['priority'] =
            \ get(asyncomplete#get_source_info(l:source_name),'priority',0)
        call add(l:items, l:item)
      endif
    endfor
  endfor
  let l:items = sort(l:items, {a, b -> b['priority'] - a['priority']})
  call asyncomplete#preprocess_complete(a:options, l:items)
endfunction

let g:asyncomplete_preprocessor = [function('s:sort_by_priority_preprocessor')]

" completor の登録
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
   \ 'name': 'neosnippet',
   \ 'allowlist': ['*'],
   \ 'priority': 99,
   \ 'completor': function('asyncomplete#sources#neosnippet#completor'),
   \ }))
" au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
"    \ 'name': 'buffer',
"    \ 'priority': 98,
"    \ 'allowlist': ['*'],
"    \ 'completor': function('asyncomplete#sources#buffer#completor'),
"    \ }))
let g:asyncomplete_around_range = 100
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#around#get_source_options({
    \ 'name': 'around',
    \ 'allowlist': ['*'],
    \ 'priority': 98,
    \ 'completor': function('asyncomplete#sources#around#completor'),
    \ }))
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
     \ 'name': 'file',
     \ 'allowlist': ['*'],
     \ 'priority': 97,
     \ 'completor': function('asyncomplete#sources#file#completor'),
     \ }))
" au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necosyntax#get_source_options({
"      \ 'name': 'necosyntax',
"      \ 'priority': 9,
"      \ 'allowlist': ['*'],
"      \ 'completor': function('asyncomplete#sources#necosyntax#completor'),
"      \ }))
" au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
"      \ 'name': 'necovim',
"      \ 'allowlist': ['vim'],
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
" \  'efm-langserver': {
" \    'disabled': v:false,
" \  },
"\}

" Color scheme settings
" set termguicolors

" hi LspErrorHighlight         guifg=White guibg=DarkRed
hi LspWarningHighlight       guifg=Black guibg=DarkOrange
hi LspInformationHighlight   guifg=White guibg=#87afd7
hi LspHintHighlight          guifg=White guibg=Green
" let g:lsp_document_highlight_enabled = 0
