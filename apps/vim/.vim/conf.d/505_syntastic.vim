if !g:plug.is_installed('syntastic')
  finish
endif

"=============================================
" syntastic
"=============================================
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_javascript_checkers = ['eslint']

let g:syntastic_mode_map = { 'mode': 'passive',
          \ 'active_filetypes': ['ruby', 'javascript','sh','vim', 'yaml'],
          \ 'passive_filetypes': [] }
" ここから下は Syntastic のおすすめの設定
" ref. https://github.com/scrooloose/syntastic#settings

" location list を常に更新するかどうか
let g:syntastic_always_populate_loc_list = 1
" location list を常に表示するかどうか
let g:syntastic_auto_loc_list = 1
" エラー行に sign を表示するかどうか
let g:syntastic_enable_signs = 1
" ファイルを開いた時にチェックを実行するかどうか
let g:syntastic_check_on_open = 1
" :wq で終了する時もチェックするかどうか
let g:syntastic_check_on_wq = 0
