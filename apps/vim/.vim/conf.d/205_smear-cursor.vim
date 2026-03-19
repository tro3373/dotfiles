if !g:plug.is_installed("smear-cursor.nvim")
  finish
endif

lua require('smear_cursor').enabled = true
" 同名のLuaファイルを読み込む
"   <sfile> : 現在のスクリプトファイル
"   :p      : path フルパス取得         ex) /path/to/952_claude_code.vim
"   :t      : tail ファイル名のみ取得   ex) 952_claude_code.vim
"   :r      : root 拡張子を除く         ex) 952_claude_code
let s:lua_file = expand('<sfile>:p:r') . '.lua'
execute 'luafile' s:lua_file
