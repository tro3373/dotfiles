if !g:plug.is_installed("vim-codefmt")
  finish
endif
if !executable('google-java-format')
  finish
endif
