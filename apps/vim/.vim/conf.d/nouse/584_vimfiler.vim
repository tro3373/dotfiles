if !g:plug.is_installed("vimfiler")
  finish
endif

" VimFiler
let g:vimfiler_as_default_explorer = 1
call vimfiler#custom#profile('default', 'context', {
\   'explorer' : 1,
\   'safe' : 0
\ })
" let g:vimfiler_safe_mode_by_default = 0
" let g:vimfiler_enable_auto_cd = 1
let g:vimfiler_ignore_pattern = ['^\.git$', '^\.DS_Store$']
function! s:MyVimFilerKeyMapping()
  nmap <silent><buffer> q <Plug>(vimfiler_close)
  nmap <silent><buffer> - <Plug>(vimfiler_smart_h)
endfunction
autocmd FileType vimfiler call s:MyVimFilerKeyMapping()
