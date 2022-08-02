if !has('nvim')
  finish
endif
if !executable('nvr')
  finish
endif

" neovim-remote
let nvrcmd      = "nvr --remote-wait"
let $VISUAL     = nvrcmd
let $GIT_EDITOR = nvrcmd

" nvr設定で起動したコミットメッセージが保存できない問題が解消される
" If you don't like using :w | bd and prefer the good old :wq (or :x), put the following in your vimrc:
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

" nnoremap <silent> <Leader>t :<C-u>silent call <SID>tig_status()<CR>
nnoremap <silent> <Leader>t :<C-u>silent call <SID>tig_start()<CR>
nnoremap <silent> <Leader>T :<C-u>silent call <SID>tig_start(expand('%'))<CR>

function! s:tig_start(...) abort
  let l:optf = ''
  if a:0 >= 1
    let l:optf = a:1
  endif
  call s:open_term('tig '.l:optf)
endfunction
function! s:tig_status() abort
  call s:open_term('tig status')
endfunction

function! s:open_term(cmd) abort
  " let split = s:split_type()
  let split = 'tabe'

  call execute(printf('%s term://%s', split, a:cmd))

  setlocal bufhidden=delete
  setlocal noswapfile
  setlocal nobuflisted
endfunction

" function! s:split_type() abort
"   " NOTE: my cell ratio: width:height == 1:2.1
"   let width = winwidth(win_getid())
"   let height = winheight(win_getid()) * 2.1
"
"   if height > width
"     return 'split'
"   else
"     return 'vsplit'
"   endif
" endfunction
