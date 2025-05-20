if !g:plug.is_installed("denops-translate.vim")
  finish
endif

let g:translate_border_chars=['+', '-', '+', '|', '+', '-', '+', '|']
let g:translate_source = "en"
let g:translate_target = "ja"
let g:translate_popup_window = 0 " if you want use popup window, set value 1
let g:translate_winsize = 10 " set buffer window height size if you doesn't use popup window
let g:translate_ui = ""  "popup / buffer

" カーソル下の単語を翻訳
nmap <Leader>n :Translate <C-R><C-W><CR>
" 選択行を翻訳
vmap <Leader>n :'<,'>Translate<CR>
" 選択部分を翻訳(Not work)
" vmap <Leader>n y:Translate <C-r>"

" カーソル下の単語を逆翻訳
nmap <Leader>N :Translate! <C-R><C-W><CR>
" 選択行を逆翻訳
vmap <Leader>N :'<,'>Translate!<CR>
