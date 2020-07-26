if !g:plug.is_installed("unite-outline")
  finish
endif

let g:unite_split_rule = 'botright'
noremap ,u <ESC>:Unite -vertical -winwidth=40 outline<Return>
