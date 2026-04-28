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
" let g:copilot_filetypes = {
"   \ 'markdown': 0,
"   \ 'gitcommit': 0,
"   \ 'gitrebase': 0,
"   \ 'hgcommit': 0,
"   \ 'svn': 0,
"   \ 'cvs': 0,
"   \ '.': 0}
" .env という名前のファイル、または .secret で終わるファイルで Copilot を無効化
autocmd BufRead,BufNewFile .env,.env.*,*.secret,.works.zsh let b:copilot_enabled = v:false
