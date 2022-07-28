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

" [【解説】開発ライブ実況 #1 (Vim / Go) 編 by メルペイ Architect チーム Backend エンジニア #mercari_codecast | メルカリエンジニアリング](https://engineering.mercari.com/blog/entry/mercari_codecast_1/)
function! s:find_rip_grep() abort
  call fzf#vim#grep(
      \   'rg --ignore-file ~/.ignore --column --line-number --no-heading --hidden --smart-case .+',
      \   1,
      \   fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%', '?'),
      \   0,
      \)
endfunction
nnoremap <silent> <Leader>g :<C-u>silent call <SID>find_rip_grep()<CR>

function! MyFZFQ(q) abort
  let l:d = GetGitRoot()
  " echo l:d
  " exe(":FZF " . l:d)
  :call fzf#vim#files(l:d, {'options': ['--query=' . a:q, '--layout=reverse', '--info=inline', '--preview', 'cat {}']})
endfunction
nnoremap <Leader>k <ESC>:call MyFZFQ('')<ENTER>
nnoremap <Leader>l <ESC>:call MyFZFQ(expand('<cword>'))<ENTER>
