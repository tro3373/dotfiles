if !g:plug.is_installed("tig-explorer.vim")
  finish
endif

" Following commands are available on tig launched from tig-explorer
" ```
" e, <Ctrl-o>: edit on existing tab
" <Ctrl-t>   : edit on new tab
" <Ctrl-v>   : edit with vsplit window
" <Ctrl-s>   : edit with split window
" ```
" Following keymap is defined as defaut
" ```
" let g:tig_explorer_keymap_edit    = '<C-o>'
" let g:tig_explorer_keymap_tabedit = '<C-t>'
" let g:tig_explorer_keymap_split   = '<C-s>'
" let g:tig_explorer_keymap_vsplit  = '<C-v>'
" ```

" nnoremap sv :<C-u>vs<CR>
nnoremap <Leader>s :TigStatus<CR>
nnoremap <Leader>t :TigOpenCurrentFile<CR>


