if !g:plug.is_installed("claude-code.nvim")
  finish
endif

" 同名のLuaファイルを読み込む
"   <sfile> : 現在のスクリプトファイル
"   :p      : path フルパス取得         ex) /path/to/952_claude_code.vim
"   :t      : tail ファイル名のみ取得   ex) 952_claude_code.vim
"   :r      : root 拡張子を除く         ex) 952_claude_code
let s:lua_file = expand('<sfile>:p:r') . '.lua'
execute 'luafile' s:lua_file
" Luaファイルのsetup関数を呼び出す（グローバル関数を使用）
lua claude_code_setup()
