if !g:plug.is_installed("denops-translate.vim")
  finish
endif

let g:translate_border_chars=['+', '-', '+', '|', '+', '-', '+', '|']
let g:translate_source = "en"
let g:translate_target = "ja"
let g:translate_popup_window = 0 " if you want use popup window, set value 1
let g:translate_winsize = 10 " set buffer window height size if you doesn't use popup window
let g:translate_ui = ""  "popup / buffer

nmap <Leader>n :Translate <C-R><C-W><CR>
vmap <Leader>n :'<,'>Translate<CR>

