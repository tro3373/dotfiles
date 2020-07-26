" Indent Guide Settings
if !g:plug.is_installed("vaffle.vim")
  finish
endif

let g:vaffle_show_hidden_files=1

function! s:customize_vaffle_mappings() abort
  " Customize key mappings here
  " nmap <buffer> <Bslash> <Plug>(vaffle-open-root)
  " nmap <buffer> K        <Plug>(vaffle-mkdir)
  " nmap <buffer> N        <Plug>(vaffle-new-file)
  nmap <buffer> - <Plug>(vaffle-open-parent)
endfunction

augroup vimrc_vaffle
  autocmd!
  autocmd FileType vaffle call s:customize_vaffle_mappings()
augroup END
