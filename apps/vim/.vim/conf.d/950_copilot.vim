if !g:plug.is_installed("copilot.vim")
  finish
endif

" see: .vim/plugged/copilot.vim/autoload/copilot.vim
" let s:filetype_defaults = {
"       \ 'gitcommit': 0,
"       \ 'gitrebase': 0,
"       \ 'hgcommit': 0,
"       \ 'svn': 0,
"       \ 'cvs': 0,
"       \ '.': 0}
let g:copilot_filetypes = {
  \ 'markdown': 0,
  \ 'gitcommit': 0,
  \ 'gitrebase': 0,
  \ 'hgcommit': 0,
  \ 'svn': 0,
  \ 'cvs': 0,
  \ '.': 0}
