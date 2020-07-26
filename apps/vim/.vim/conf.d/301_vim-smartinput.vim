if !g:plug.is_installed("vim-smartinput")
  finish
endif

" cana/vim-smartinput, cohama/vim-smartinput-endwise
" http://cohama.hateblo.jp/entry/2013/11/08/013136
call smartinput_endwise#define_default_rules()
