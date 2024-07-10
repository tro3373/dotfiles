if !g:plug.is_installed("lightline-lsp")
  finish
endif

let g:lsp_diagnostics_signs_warning = "lsp:\uf071"
let g:lsp_diagnostics_signs_error = "lsp:\uf05e"
let g:lightline_lsp_signs_ok = "lsp:\uf00c"
