-- luacheck: ignore 112 113
-- 外観: colorscheme / statusline / git / カーソル効果など
return {
  -- colorscheme (vim 版と同じ commit pin。最優先で読み込む)
  {
    "romainl/Apprentice",
    commit = "cb051ec",
    lazy = false,
    priority = 1000,
    config = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("my-colors", {}),
        pattern = "*",
        callback = function()
          -- term ansi colors 設定による nocolor バグ回避 (200_colorscheme.vim 由来)
          vim.cmd("unlet! g:terminal_ansi_colors")
          vim.cmd("hi Search ctermfg=238 ctermbg=109 guifg=#646D75 guibg=#87afaf")
          vim.cmd("hi SpecialKey cterm=NONE ctermfg=cyan guifg=cyan")
        end,
      })
      vim.cmd("colorscheme apprentice")
    end,
  },

  -- statusline (lightline.vim → lualine.nvim へ置換)
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- 空バッファ([No Name])起動でも statusline/tabline を確実に出すため起動時ロード
    lazy = false,
    config = function()
      -- Apprentice カラースキームの syntax 配色に揃えた自前テーマ。
      -- normal を markdown 見出し相当の light-blue(#87afd7=Statement) にし、
      -- insert=green/visual=orange/replace=red/command=teal を syntax アクセントから採る。
      local p = {
        bg = "#262626",
        bg_dark = "#1c1c1c",
        surface = "#303030",
        surface2 = "#444444",
        fg = "#bcbcbc",
        dim = "#6c6c6c",
        blue = "#87afd7", -- Statement (markdown 見出し)
        green = "#87af87",
        orange = "#ff8700", -- Constant
        red = "#af5f5f",
        teal = "#5f8787", -- PreProc
        purple = "#8787af", -- Type
      }
      local function mode(accent)
        return {
          a = { fg = p.bg_dark, bg = accent, gui = "bold" },
          b = { fg = p.fg, bg = p.surface2 },
          c = { fg = p.fg, bg = p.surface },
        }
      end
      local apprentice = {
        normal = mode(p.blue),
        insert = mode(p.green),
        visual = mode(p.orange),
        replace = mode(p.red),
        command = mode(p.teal),
        terminal = mode(p.purple),
        inactive = {
          a = { fg = p.dim, bg = p.surface },
          b = { fg = p.dim, bg = p.surface },
          c = { fg = p.dim, bg = p.bg },
        },
      }
      require("lualine").setup({
        options = {
          theme = apprentice,
          icons_enabled = true,
          globalstatus = true,
        },
        sections = {
          -- 既定の branch アイコン U+E0A0() はセル高さをはみ出すため
          -- セルに収まる nf-dev-git_branch () へ変更
          -- lualine_b = { { "branch", icon = "" }, "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
        },
        -- tab 行も同テーマで描画 (旧 lightline の tabline 相当)
        tabline = {
          lualine_a = { { "tabs", mode = 2, max_length = vim.o.columns } },
        },
      })
    end,
  },

  -- カラーコードのインライン着色。
  -- norcalli 版は unmaintained で vim.tbl_flatten deprecation を出すため、
  -- メンテ継続中の catgoose fork (API 互換) へ置換。
  {
    "catgoose/nvim-colorizer.lua",
    name = "nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      _G.src("204_nvim-colorizer.vim")
    end,
  },

  -- インデントガイド (vim-indent-guides: 既存設定を source)
  {
    "nathanaelkane/vim-indent-guides",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      _G.src("304_vim-indent-guides.vim")
    end,
  },

  -- git 差分表示 (vim-gitgutter)
  {
    "airblade/vim-gitgutter",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      _G.src("303_vim-gitgutter.vim")
    end,
  },
  -- インライン git blame
  {
    "tveskag/nvim-blame-line",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      _G.src("309_nvim-blame-line.vim")
    end,
  },
  -- Git ラッパ
  { "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit", "Gblame", "Gwrite", "Gread" } },

  -- 集中執筆モード
  { "junegunn/goyo.vim", cmd = "Goyo" },

  -- カーソル移動アニメ (smear-cursor.nvim, neovim 専用)
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    config = function()
      _G.src("205_smear-cursor.vim")
    end,
  },

  -- LSP 進捗等の通知 UI
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
}
