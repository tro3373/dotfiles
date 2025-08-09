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


let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:50%' --layout reverse --preview 'bat --color=always --style=header,grid --line-range :500 {}'"

" ウィンドウサイズ変更したい場合
let g:fzf_layout = { 'window': { 'width': 1.0, 'height': 1.0, 'yoffset': 0.5, 'xoffset': 0.5, 'border': 'sharp' } }

" 【解説】開発ライブ実況 #1 (Vim / Go) 編 by メルペイ Architect チーム Backend エンジニア #mercari_codecast | メルカリエンジニアリング
" https://engineering.mercari.com/blog/entry/mercari_codecast_1/
function! s:find_rip_grep(q, d) abort
  let l:target_dir = a:d
  if a:d == ''
    let l:target_dir = GetGitRoot()
  endif
  " fzf#vim#with_preview で ctrl+h/l で左右するようにできないか？
  call fzf#vim#grep(
      \   'rg --ignore-file ~/.vim/.rgignore --glob "!.git/" --column --line-number --no-heading --hidden --smart-case "'.a:q.'" '.l:target_dir,
      \   1,
      \   fzf#vim#with_preview({'options': '--query="' . a:q . '" --delimiter : --nth 4..'}, 'down:50%', '?'),
      \   0,
      \)
endfunction
nnoremap <silent> <Leader>g :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), '')<CR>
" nnoremap <silent> <Leader>G :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>G :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), getcwd())<CR>
vnoremap <silent> <Leader>g "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), '')<CR>
" vnoremap <silent> <Leader>G "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), expand('%:p:h'))<CR>
vnoremap <silent> <Leader>G "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), getcwd())<CR>

function! s:find_rip_grep_fuzzy(q, d) abort
  let l:target_dir = a:d
  if a:d == ''
    let l:target_dir = GetGitRoot()
  endif
  call fzf#vim#grep(
      \   'rg --ignore-file ~/.vim/.rgignore --glob "!.git/" --column --line-number --no-heading --hidden --smart-case .+ ' . l:target_dir,
      \   1,
      \   fzf#vim#with_preview({'options': '--query="' . a:q . '" --delimiter : --nth 4..'}, 'down:50%', '?'),
      \   0,
      \)
endfunction
nnoremap <silent> <Leader>f :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), '')<CR>
" nnoremap <silent> <Leader>F :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>F :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), getcwd())<CR>
vnoremap <silent> <Leader>f "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), '')<CR>
" vnoremap <silent> <Leader>F "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), expand('%:p:h'))<CR>
vnoremap <silent> <Leader>F "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), getcwd())<CR>

function! s:find_rip_grep_files(q, d) abort
  let l:target_dir = a:d
  if a:d == ''
    let l:target_dir = GetGitRoot()
  endif
  :call fzf#vim#files(l:target_dir, {'options': ['--query=' . a:q, '--layout=reverse', '--info=inline', '--preview', 'cat {}']})
endfunction
nnoremap <silent> <Leader>l :<C-u>silent call <SID>find_rip_grep_files(expand('<cword>'), '')<CR>
nnoremap <silent> <Leader>L :<C-u>silent call <SID>find_rip_grep_files(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>; :<C-u>silent call <SID>find_rip_grep_files('', '')<CR>
nnoremap <silent> <Leader>: :<C-u>silent call <SID>find_rip_grep_files('', expand('%:p:h'))<CR>
