if !g:plug.is_installed("nvim-colorizer.lua")
  finish
endif

lua require'colorizer'.setup()
