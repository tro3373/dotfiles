" Indent Guide Settings
if !g:plug.is_installed("vim-yazi")
  finish
endif

" Path to yazi executable (default: 'yazi')
let g:yazi_executable = 'yazi'
" Enable opening multiple files (default: 1)
let g:yazi_open_multiple = 0
" Replace netrw with yazi (default: 0)
let g:yazi_replace_netrw = 1
" Disable default key mappings (default: 0)
let g:yazi_no_mappings = 1
" nnoremap <silent> <F2> :Yazi<CR>
