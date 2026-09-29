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
  -- 閲覧用に csvlens (セル内折り返し可) も新規タブで自動起動する。:CsvLensAutoToggle で ON/OFF、:CsvLens で再表示
  {
    "hat0uma/csvview.nvim",
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    init = function()
      vim.g.csvlens_auto = true

      local function open_csvlens(buf)
        local file = vim.api.nvim_buf_get_name(buf)
        -- 選択は row のまま起動する (column/cell 選択だと検索・フィルタが選択列だけになる)
        local cmd = { "csvlens", "-W", "-i", file }
        if vim.bo[buf].filetype == "tsv" then
          table.insert(cmd, 2, "-t")
        end
        vim.cmd.tabnew()
        local term = vim.api.nvim_get_current_buf()
        vim.bo[term].bufhidden = "wipe"
        vim.fn.jobstart(cmd, {
          term = true,
          on_exit = function()
            if vim.api.nvim_buf_is_valid(term) then
              vim.api.nvim_buf_delete(term, { force = true })
            end
          end,
        })
        vim.cmd.startinsert()
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("CsvViewAuto", {}),
        pattern = { "csv", "tsv" },
        callback = function(ev)
          require("csvview").enable(ev.buf)
          -- ディスク上の実ファイルだけ (プレビュー・diff 等の特殊バッファでは開かない)
          local file = vim.api.nvim_buf_get_name(ev.buf)
          if not vim.g.csvlens_auto or vim.bo[ev.buf].buftype ~= "" or vim.fn.filereadable(file) == 0 then
            return
          end
          if vim.fn.executable("csvlens") == 0 then
            return
          end
          vim.schedule(function()
            if vim.api.nvim_get_current_buf() == ev.buf and not vim.wo.diff then
              open_csvlens(ev.buf)
            end
          end)
        end,
      })
      vim.api.nvim_create_user_command("CsvLens", function()
        open_csvlens(0)
      end, { desc = "Open current csv/tsv in csvlens" })
      vim.api.nvim_create_user_command("CsvLensAutoToggle", function()
        vim.g.csvlens_auto = not vim.g.csvlens_auto
        vim.notify("csvlens auto open: " .. (vim.g.csvlens_auto and "ON" or "OFF"))
      end, { desc = "Toggle auto opening csvlens for csv/tsv" })
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
