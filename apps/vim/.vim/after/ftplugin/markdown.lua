-- luacheck: ignore 112 113
-- Neovim 0.11+ の runtime ftplugin が vim.treesitter.start() を呼ぶため
-- vim-markdown の syntax / 自前 highlight が上書きされる。
-- nvim-treesitter の disable では runtime 側の start を止められないので
-- ここで明示的に stop して vim regex syntax にフォールバックさせる。
if vim.fn.has('nvim') == 1 then
  pcall(vim.treesitter.stop)
end

-- Neovim 組み込み ftplugin/markdown.vim が tabstop/shiftwidth=4 を強制するため、
-- 既定の 2 スペース (100_base.vim と同値) に戻す。
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
