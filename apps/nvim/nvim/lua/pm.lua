-- luacheck: ignore 112 113
-- lazy.nvim ブートストラップ + プラグイン spec 読み込み (vim-plug からの移行先)
local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  -- 起動時の自動更新チェックは無効 (手動 :Lazy で管理)
  checker = { enabled = false },
  change_detection = { notify = false },
  -- nvim 組み込みプラグインの無効化 (.vimrc の loaded_* 相当)
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "tutor",
      },
    },
  },
})
