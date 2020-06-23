if !g:plug.is_installed("vim-gitgutter")
  finish
endif

" let g:gitgutter_git_executable = "PATH=/usr/bin winpty git"
let g:gitgutter_map_keys = 0  " Not use gitgutter keymap
let g:gitgutter_realtime = 0  " Not realtime
let g:gitgutter_eager = 0     " Not realtime
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'
