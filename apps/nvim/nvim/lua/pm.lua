-- luacheck: ignore 112 113
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  spec = {
    -- add LazyVim and import its plugins
    --     { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    --     -- import any extras modules here
    --     -- { import = "lazyvim.plugins.extras.lang.typescript" },
    --     -- { import = "lazyvim.plugins.extras.lang.json" },
    --     -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    --     -- import/override with your plugins
    { import = "plugins" },
    -- {import = "plugins.ui" },
    -- {import = "plugins.git" },
    -- {import = "plugins.move" },
    -- {import = "plugins.lsp" },
    -- {import = "plugins.cmp" }
  },
}

local option = {
  -- ui = {
  --   icons = {
  --     cmd = "⌘",
  --     config = "🛠",
  --     event = "📅",
  --     ft = "📂",
  --     init = "⚙",
  --     keys = "🗝",
  --     plugin = "🔌",
  --     runtime = "💻",
  --     require = "🌙",
  --     source = "📄",
  --     start = "🚀",
  --     task = "📌",
  --     lazy = "💤 ",
  --   },
  -- },
  -- checker = {
  --   enabled = true, -- プラグインのアップデートを自動的にチェック
  -- },
  -- diff = {
  --   cmd = "delta",
  -- },
  -- rtp = {
  --   disabled_plugins = {
  --     "gzip",
  --     "matchit",
  --     "matchparen",
  --     "netrwPlugin",
  --     "tarPlugin",
  --     "tohtml",
  --     "tutor",
  --     "zipPlugin",
  --   },
  -- },
}

require("lazy").setup(plugins, option)
