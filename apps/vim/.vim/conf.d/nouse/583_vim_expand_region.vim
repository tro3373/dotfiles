if !g:plug.is_installed("vim-expand-region")
  finish
endif

"=============================================
" Expand Region
" visually select increasingly larger regions of text
"=============================================
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

