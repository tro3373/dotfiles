if !g:plug.is_installed("markdown-preview.nvim")
  finish
endif

nmap <Space>s <cmd>MarkdownPreview<CR>
