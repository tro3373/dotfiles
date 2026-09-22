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

  -- csv/tsv を表形式で表示 (開いたら自動有効、:CsvViewToggle で切替)。keymaps は有効化したバッファのみ
  {
    "hat0uma/csvview.nvim",
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("CsvViewAuto", {}),
        pattern = { "csv", "tsv" },
        callback = function(ev)
          require("csvview").enable(ev.buf)
        end,
      })
    end,
    opts = {
      parser = { comments = { "#", "//" } },
      view = { display_mode = "border", header_lnum = 1 },
      keymaps = {
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
  },
}
