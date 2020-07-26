if !g:plug.is_installed("unite")
  finish
endif

"=============================================
" Unite 設定
"=============================================
" 入力モードで開始する
let g:unite_enable_start_insert = 1
"ヒストリー/ヤンク機能を有効化
let g:unite_source_history_yank_enable =1

function! s:unite_my_settings()
  " 単語単位からパス単位で削除するように変更
  imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

  " ESCキーを2回押すと終了する
  nmap <silent><buffer> <ESC><ESC> q
  imap <silent><buffer> <ESC><ESC> <ESC>q

  " Ctrl j, k mapping for sleect next/previous
  imap <buffer> <C-j>   <Plug>(unite_select_next_line)
  nmap <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
  nmap <buffer> <C-k>   <Plug>(unite_select_previous_line)
endfunction
" unite.vim上でのキーマッピング
autocmd FileType unite call s:unite_my_settings()
