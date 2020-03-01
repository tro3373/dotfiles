if 0      " カラーテーマ設定
elseif g:plug.is_installed("Apprentice") " cool
  colorscheme apprentice
elseif g:plug.is_installed("vim-hybrid") " cool
  " ==> hybrid
  set background=dark
  " let g:hybrid_custom_term_colors = 1
  " let g:hybrid_reduced_contrast = 1 " Remove this line if using the default palette.
  colorscheme hybrid
elseif g:plug.is_installed("jellybeans.vim") " so black
  colorscheme jellybeans
elseif g:plug.is_installed("vim-colors-solarized") " cool
  " ==> Solarized
  " let g:solarized_termcolors=256
  let g:solarized_termtrans=1
  set background=dark
  colorscheme solarized
elseif g:plug.is_installed("Alduin") " cool but..
  colorscheme alduin
elseif g:plug.is_installed("gruvbox") " cooll
  set background=dark
  colorscheme gruvbox
elseif g:plug.is_installed("vim-tomorrow-theme") " cool
  " ==> TomorrowNight
  " colorscheme Tomorrow
  " colorscheme Tomorrow-Night-Bright
  " colorscheme Tomorrow-Night-Eighties
  colorscheme Tomorrow-Night
elseif g:plug.is_installed("vim-nefertiti") " ng
  colorscheme nefertiti
elseif g:plug.is_installed("onedark.vim") " ng pink
  colorscheme onedark
elseif g:plug.is_installed("Sierra") " ng
  colorscheme sierra
elseif g:plug.is_installed("twilight") " ng orenge line
  colorscheme twilight
elseif g:plug.is_installed("molokai") " ng
  " ==> Molokai
  colorscheme molokai
endif
