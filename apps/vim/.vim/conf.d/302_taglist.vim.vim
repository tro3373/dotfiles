if !g:plug.is_installed("taglist.vim")
  finish
endif

" Tlistを表示
map tl :Tlist<Enter>
