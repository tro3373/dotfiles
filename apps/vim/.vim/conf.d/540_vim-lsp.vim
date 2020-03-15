if !g:plug.is_installed("vim-lsp")
  finish
endif

" if empty(globpath(&rtp, 'autoload/lsp.vim'))
"   finish
" endif

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <f2> <plug>(lsp-rename)
  inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')

let g:lsp_diagnostics_enabled = 1           " ファイルの変更に伴いリアルタイムにエラー表示
let g:lsp_diagnostics_echo_cursor = 1       " enable echo under cursor when in normal mode
let g:lsp_signs_enabled = 1
let g:lsp_signs_error = {'text': '✗'}
let g:lsp_signs_warning = {'text': '‼', 'icon': '/path/to/some/icon'}
let g:lsp_signs_hint = {'text': 'h', 'icon': '/path/to/some/other/icon'}
let g:asyncomplete_auto_popup = 1           " 自動で入力補完ポップアップを表示
let g:asyncomplete_auto_completeopt = 0     " 自動で入力補完ポップアップを表示
let g:asyncomplete_popup_delay = 200        " ポップアップ表示ディレイ
let g:lsp_text_edit_enabled = 1             " textEdit を有効(LSP の仕様)
" menuone:対象が1件しかなくても常に補完ウィンドウを表示
" noinsert:補完ウィンドウを表示時に挿入しない
set completeopt=menuone,noinsert
" set completeopt+=preview

" language server を指定
" let g:lsp_settings_filetype_javascript = ['eslint-language-server']


inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" 補完表示時のEnterで改行をしない
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

imap <c-space> <Plug>(asyncomplete_force_refresh)
