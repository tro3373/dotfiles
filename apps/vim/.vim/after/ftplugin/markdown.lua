-- Neovim 0.11+ の runtime ftplugin が vim.treesitter.start() を呼ぶため
-- vim-markdown の syntax / 自前 highlight が上書きされる。
-- nvim-treesitter の disable では runtime 側の start を止められないので
-- ここで明示的に stop して vim regex syntax にフォールバックさせる。
if vim.fn.has('nvim') == 1 then
  pcall(vim.treesitter.stop)
end
