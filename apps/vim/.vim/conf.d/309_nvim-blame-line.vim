if !g:plug.is_installed("nvim-blame-line")
  finish
endif

" nnoremap <silent> <leader>b :ToggleBlameLine<CR>
autocmd BufEnter * EnableBlameLine

" " Show blame info below the statusline instead of using virtual text
" let g:blameLineUseVirtualText = 0
"
" " Specify the highlight group used for the virtual text ('Comment' by default)
" let g:blameLineVirtualTextHighlight = 'Question'
"
" " Change format of virtual text ('%s' by default)
" let g:blameLineVirtualTextFormat = '/* %s */'
"
" " Customize format for git blame (Default format: '%an | %ar | %s')
" let g:blameLineGitFormat = '%an - %s'
" " Refer to 'git-show --format=' man pages for format options)
"
" " Change message when content is not committed
" let g:blameLineMessageWhenNotYetCommited = ''
