if !g:plug.is_installed('nvim-treesitter')
  finish
endif

" 同名のLuaファイルを読み込む
"   <sfile> : 現在のスクリプトファイル
"   :p      : path フルパス取得
"   :r      : root 拡張子を除く
let s:lua_file = expand('<sfile>:p:r') . '.lua'
execute 'luafile' s:lua_file
