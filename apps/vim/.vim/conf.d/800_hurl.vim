if !g:plug.is_installed('hurl.nvim')
  finish
endif

" 同名のLuaファイルを読み込む
"   <sfile> : 現在のスクリプトファイル
"   :p      : path フルパス取得
"   :t      : tail ファイル名のみ取得
"   :r      : root 拡張子を除く
let s:lua_file = expand('<sfile>:p:r') . '.lua'
execute 'luafile' s:lua_file

" .hurl バッファローカルキーマップ (global の <Leader>a/h/t などと衝突しないよう buffer-local)
augroup hurl_mappings
  autocmd!
  autocmd FileType hurl nnoremap <buffer> <silent> <LocalLeader>A  :HurlRunner<CR>
  autocmd FileType hurl nnoremap <buffer> <silent> <LocalLeader>a  :HurlRunnerAt<CR>
  autocmd FileType hurl nnoremap <buffer> <silent> <LocalLeader>te :HurlRunnerToEntry<CR>
  autocmd FileType hurl nnoremap <buffer> <silent> <LocalLeader>tE :HurlRunnerToEnd<CR>
  autocmd FileType hurl nnoremap <buffer> <silent> <LocalLeader>tm :HurlToggleMode<CR>
  autocmd FileType hurl nnoremap <buffer> <silent> <LocalLeader>tv :HurlVerbose<CR>
  autocmd FileType hurl nnoremap <buffer> <silent> <LocalLeader>tV :HurlVeryVerbose<CR>
  autocmd FileType hurl vnoremap <buffer> <silent> <LocalLeader>h  :HurlRunner<CR>
augroup END
