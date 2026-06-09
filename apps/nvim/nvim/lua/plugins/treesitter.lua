-- luacheck: ignore 112 113
-- treesitter と、それに依存する hurl.nvim
return {
  -- nvim-treesitter (main は nvim 0.12 nightly 要求のため master へ pin)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      _G.src("206_nvim-treesitter.vim")
    end,
  },

  -- 共通依存
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  -- .hurl HTTP リクエスト実行
  {
    "jellydn/hurl.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    ft = "hurl",
    config = function()
      _G.src("800_hurl.vim")
    end,
  },
}
