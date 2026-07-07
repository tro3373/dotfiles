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
          -- apprentice は NormalFloat 未定義で nvim 既定 (ほぼ黒 NvimDarkGrey1 #07080d) になる。
          -- Normal (#262626) に揃えてフロート/CLI ウィンドウ(sidekick claude 等)の真っ黒を解消。
          vim.cmd("hi! link NormalFloat Normal")
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

      -- Read-Only (swap RO / nomodifiable) 表示: 鍵アイコンを淡い赤で示す
      local ro_icon = "\239\128\163" -- U+F023 (nf-fa-lock)
      local ro_color = "#C94E44"
      -- 通常ファイル (buftype=="") のみ RO 対象。vaffle(buftype=nowrite)や
      -- help/terminal/quickfix 等の特殊バッファは nomodifiable でも赤くしない
      local function buf_is_ro(buf)
        buf = buf or 0
        return vim.bo[buf].buftype == "" and (vim.bo[buf].readonly or vim.bo[buf].modifiable == false)
      end
      local function tab_is_ro(tab)
        local buflist = vim.fn.tabpagebuflist(tab.tabnr)
        local buf = buflist[vim.fn.tabpagewinnr(tab.tabnr)]
        return buf ~= nil and vim.bo[buf].buftype == "" and (vim.bo[buf].readonly or vim.bo[buf].modifiable == false)
      end
      -- tabline は fmt 内で hl を埋め込むため名前付き hl を用意 (colorscheme で消えるので再適用)
      -- RO タブは番号ごと赤背景にする (前景は白で可読性確保)
      local function set_ro_hl()
        vim.api.nvim_set_hl(0, "LualineTabRO", { fg = "#ffffff", bg = ro_color, bold = true })
      end
      set_ro_hl()
      aumg({ events = "ColorScheme", group = "lualine-ro-hl", cb = set_ro_hl })

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
          lualine_c = {
            -- 既定の readonly シンボル [-] は出さず、下の鍵アイコンで示す
            { "filename", path = 1, symbols = { readonly = "" } },
            {
              function()
                return buf_is_ro() and ro_icon or ""
              end,
              color = { fg = ro_color },
            },
          },
        },
        -- tab 行も同テーマで描画 (旧 lightline の tabline 相当)
        tabline = {
          lualine_a = {
            {
              "tabs",
              -- mode=1(名前のみ)にして番号も fmt 側で付与する。mode=2 だと番号が fmt の
              -- 外で前置され着色できないため、RO タブを番号ごと赤背景にできない
              mode = 1,
              max_length = vim.o.columns,
              -- RO タブは「番号 + 鍵 + 名前」をまとめて赤背景にする
              fmt = function(name, tab)
                if tab_is_ro(tab) then
                  return string.format("%%#LualineTabRO# %d %s %s %%*", tab.tabnr, ro_icon, name)
                end
                return string.format("%d %s", tab.tabnr, name)
              end,
            },
          },
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
    -- event 遅延は nvim 起動引数 (`nvim file`) で発火漏れし初期 gutter が出ない
    -- (MIGRATION.md 4.4/4.7 参照)。起動時ロードで旧 vim-plug 挙動に戻す
    lazy = false,
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

  -- -- カーソル移動アニメ (smear-cursor.nvim, neovim 専用)
  -- {
  --   "sphamba/smear-cursor.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     _G.src("205_smear-cursor.vim")
  --   end,
  -- },

  -- LSP 進捗等の通知 UI
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
}
