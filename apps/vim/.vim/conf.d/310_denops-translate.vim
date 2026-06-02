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
nmap <Leader>tr :Translate <C-R><C-W><CR>
nmap <Leader>n :Translate <C-R><C-W><CR>
" 選択部分を翻訳
" NOTE: ':'<,'>Translate' は ex の行範囲となり、選択文字ではなく行全体が翻訳される。
"       選択文字列を引数として渡す関数経由にすることで選択部分のみを翻訳する。
function! s:TranslateVisual(bang) abort
  let l:save = getreginfo('"')
  normal! gvy
  let l:text = substitute(@", '\n', ' ', 'g')
  call setreg('"', l:save)
  execute 'Translate' . a:bang . ' "' . escape(l:text, '"') . '"'
endfunction
xnoremap <silent> <Leader>tr :<C-u>call <SID>TranslateVisual('')<CR>
xnoremap <silent> <Leader>n :<C-u>call <SID>TranslateVisual('')<CR>

" カーソル下の単語を逆翻訳
nmap <Leader>Tr :Translate! <C-R><C-W><CR>
nmap <Leader>N :Translate! <C-R><C-W><CR>
" 選択部分を逆翻訳
xnoremap <silent> <Leader>Tr :<C-u>call <SID>TranslateVisual('!')<CR>
xnoremap <silent> <Leader>N :<C-u>call <SID>TranslateVisual('!')<CR>
