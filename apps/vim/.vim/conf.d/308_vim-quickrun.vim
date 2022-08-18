if !g:plug.is_installed('vim-quickrun')
  finish
endif

"=============================================
" vim-quickrun
"=============================================
" -args "a b c" で引数指定
"\       "outputter/buffer/split" : ":botright 8",
"\       "outputter" : "multi:buffer:quickfix",
" terminal not supported in Neovim
"\       "runner" : "terminal",
let g:quickrun_config = {
\   "*" : {
\       "hook/time/enable": "1",
\   },
\   "_" : {
\       "hook/close_buffer/enable_empty_data" : 1,
\       "hook/shabadoubi_touch_henshin/enable" : 1,
\       "hook/shabadoubi_touch_henshin/wait" : 20,
\       "runner" : "vimproc",
\       "runner/vimproc/updatetime" : 40,
\   },
\   "make": {
\       "exec" : ["make"],
\   },
\   "do": {
\       "exec" : ["make do"],
\   },
\   "run": {
\       "exec" : ["make run"],
\   },
\   "node": {
\       "exec" : ["node " . expand('%:p')],
\   }
\}

function! QuickRunAuto() abort
  let _ft = &ft
  if _ft == "go"
    :QuickRun run
  else
    :QuickRun
  endif
endfunction
command! QuickRunAuto call QuickRunAuto()
" nmap <Leader>r :QuickRun<CR>
nmap <Leader>r :QuickRunAuto<CR>
