if !g:plug.is_installed("CopilotChat.nvim")
  finish
endif

" 同名のLuaファイルを読み込む
"   <sfile> : 現在のスクリプトファイル
"   :p      : path フルパス取得         ex) /path/to/952_claude_code.vim
"   :t      : tail ファイル名のみ取得   ex) 951_copilot-chat.vim
"   :r      : root 拡張子を除く         ex) 951_copilot-chat
let s:lua_file = expand('<sfile>:p:r') . '.lua'
execute 'luafile' s:lua_file
" Luaファイルのsetup関数を呼び出す（グローバル関数を使用）
lua copilot_chat_setup()

nnoremap <C-l> :<C-u>CopilotChat<CR>
vnoremap <C-l> :<C-u>CopilotChat<CR>
" vnoremap <C-l> :<C-u>CopilotChatExplainJp<CR>
