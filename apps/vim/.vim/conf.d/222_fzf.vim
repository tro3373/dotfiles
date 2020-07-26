if !executable('fzf')
  finish
endif

if !g:plug.is_installed("fzf.vim")
  finish
endif

" option に関しては、以下が詳しい
"   https://github.com/junegunn/fzf/wiki
"   http://koturn.hatenablog.com/entry/2015/11/26/000000
" nnoremap ,l :FZF .<CR>
" vnoremap ,l y:FZF -q <C-R>"<CR>
" nnoremap ,j :FZF -q <C-R><C-W>
" vnoremap ,j y:FZF -q <C-R>"
function! MyFZFQ() abort
  let l:d = GetGitRoot()
  echo l:d
  exe(":FZF " . l:d)
endfunction
nnoremap <Leader>l <ESC>:call MyFZFQ()<ENTER>
