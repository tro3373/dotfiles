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
  " getregion で選択範囲を取得 (yank しないので "N lines yanked" ログもクリップボード
  " 上書きも発生しない)。execute を使わず translate#translate 直接呼びなので改行も保持できる。
  let l:lines = getregion(getpos("'<"), getpos("'>"), {'type': visualmode()})
  " buildOption は " でトークン境界を切り替えるため、選択内に " が複数あると語が
  " source/target 言語コード扱いになり翻訳が失敗する。" を ' に置換して回避する。
  let l:text = substitute(join(l:lines, "\n"), '"', "'", 'g')
  " buildOption の語句グループ化用に "..." で包む (内側の " は除去済み)。
  call translate#translate(a:bang, line('.'), line('.'), '"' . l:text . '"')
endfunction
xnoremap <silent> <Leader>tr :<C-u>call <SID>TranslateVisual('')<CR>
xnoremap <silent> <Leader>n :<C-u>call <SID>TranslateVisual('')<CR>

" カーソル下の単語を逆翻訳
nmap <Leader>Tr :Translate! <C-R><C-W><CR>
nmap <Leader>N :Translate! <C-R><C-W><CR>
" 選択部分を逆翻訳
xnoremap <silent> <Leader>Tr :<C-u>call <SID>TranslateVisual('!')<CR>
xnoremap <silent> <Leader>N :<C-u>call <SID>TranslateVisual('!')<CR>
