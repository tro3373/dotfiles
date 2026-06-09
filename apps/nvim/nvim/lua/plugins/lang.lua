-- luacheck: ignore 112 113
-- 言語別 syntax / ファイルタイププラグイン。多くは ft 遅延ロード。
-- 設定を持つものは既存 conf.d/*.vim を SSoT で source する。
return {
  -- syntax のみ (設定不要)
  { "ekalinin/Dockerfile.vim", ft = "dockerfile" },
  { "cespare/vim-toml", branch = "main", ft = "toml" },
  { "posva/vim-vue", ft = "vue" },
  { "leafgarland/typescript-vim", ft = "typescript" },
  { "jidn/vim-dbml", ft = "dbml" },
  { "digitaltoad/vim-pug", ft = "pug" },
  { "udalov/kotlin-vim", ft = "kotlin" },
  { "mattn/vim-sqlfmt", ft = "sql" },

  -- 設定あり (source)
  {
    "hashivim/vim-terraform",
    ft = "terraform",
    config = function()
      _G.src("800_vim-terraform.vim")
    end,
  },
  {
    "mindriot101/vim-yapf",
    ft = "python",
    config = function()
      _G.src("800_vim-yapf.vim")
    end,
  },
  {
    "dart-lang/dart-vim-plugin",
    ft = "dart",
    config = function()
      _G.src("800-dart-vim-plugin.vim")
    end,
  },
  {
    "preservim/vim-markdown",
    ft = "markdown",
    config = function()
      _G.src("800_vim-markdown.vim")
    end,
  },
  {
    "sqls-server/sqls.vim",
    ft = "sql",
    config = function()
      _G.src("800_sqls.vim")
    end,
  },
  {
    "mattn/sonictemplate-vim",
    cmd = { "Template", "SonicTemplate" },
    config = function()
      _G.src("900_sonictemplate-vim.vim")
    end,
  },

  -- markdown preview (作者 fork) + live-server
  {
    "tro3373/markdown-preview.nvim",
    ft = "markdown",
    config = function()
      _G.src("800_markdown-preview.vim")
    end,
  },
  { "selimacerbas/live-server.nvim", cmd = { "LiveServerStart", "LiveServerStop" } },
}
