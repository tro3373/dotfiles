if !g:plug.is_installed("accelerated-jk")
  finish
endif

" accelerated-jk の大ジャンプを smear-cursor がアニメ描画すると、連打で
" アニメフレームが積み上がり nvim が CPU 飽和して激重になる(計測で確認: 120j が
" 40秒超 → smear停止で 0.9秒)。j/k スクロール中は smear を一時停止し、停止後
" 250ms で自動復帰させる。gg/G/検索等のジャンプでは smear は維持される。
if has('nvim') && g:plug.is_installed("smear-cursor.nvim")
  let s:smear_timer = -1
  function! s:SmearPauseJK() abort
    silent! lua require('smear_cursor').enabled = false
    if s:smear_timer != -1 | call timer_stop(s:smear_timer) | endif
    let s:smear_timer = timer_start(250, {-> execute('silent! lua require("smear_cursor").enabled = true')})
  endfunction
  nmap <silent> j <Cmd>call <SID>SmearPauseJK()<CR><Plug>(accelerated_jk_gj)
  nmap <silent> k <Cmd>call <SID>SmearPauseJK()<CR><Plug>(accelerated_jk_gk)
else
  nmap j <Plug>(accelerated_jk_gj)
  nmap k <Plug>(accelerated_jk_gk)
endif
