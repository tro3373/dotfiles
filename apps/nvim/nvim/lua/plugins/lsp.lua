-- luacheck: ignore 112 113
-- LSP / 補完 / スニペット / lint
--   vim-lsp(+vim-lsp-settings) → nvim-lspconfig(+mason)
--   asyncomplete → nvim-cmp
--   neosnippet/vsnip → LuaSnip(+friendly-snippets)
--   ALE は linting/fixing 専用として残し、設定は 251_ale.vim を SSoT で source
return {
  -- 補完エンジン
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        build = "make install_jsregexp",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert,noselect" },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-Space>"] = cmp.mapping.complete(),
          -- 改行は補完確定せず素直に改行 (asyncomplete の挙動踏襲)
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- LSP サーバ管理 (バイナリのインストールは :Mason で手動)
  -- lspconfig の dependency にして mason/bin の PATH 追加を server enable より前に走らせる。
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },

  -- LSP 設定本体 (vim.lsp.config/enable で有効化。lsp/<name>.lua を提供)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp", "williamboman/mason.nvim" },
    config = function()
      -- 診断表示 (vim-lsp 設定踏襲: virtual_text 無効 / sign 有効 / cursor float)
      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LspAttach 時のバッファローカルキーマップ (250_vim-lsp.vim 踏襲)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my-lsp-attach", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<F1>", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })

      -- nvim 0.11+ ネイティブ API (vim.lsp.config/enable)。
      -- nvim-lspconfig の lsp/<name>.lua (cmd/filetypes/root_markers) に設定をマージする。
      -- 旧 require('lspconfig').xxx.setup() は deprecated のため使わない。
      vim.lsp.config("*", { capabilities = capabilities })

      -- 各サーバの実行バイナリ。未インストールなら enable せず spawn 失敗を出さない。
      local servers = {
        lua_ls = {
          bin = "lua-language-server",
          settings = { Lua = { diagnostics = { globals = { "vim" } } } },
        },
        pylsp = {
          bin = "pylsp",
          settings = {
            pylsp = {
              configurationSources = { "flake8" },
              plugins = {
                flake8 = { enabled = true, ignore = { "W503", "E501", "E203" } },
                pycodestyle = { ignore = { "W503", "E501", "E203" } },
                jedi_definition = { follow_imports = true, follow_builtin_imports = true },
                pylsp_mypy = { enabled = true, strict = true },
              },
            },
          },
        },
        yamlls = {
          bin = "yaml-language-server",
          settings = {
            yaml = {
              schemaStore = { enable = true },
              schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
              },
              customTags = {
                "!Ref", "!Sub", "!GetAtt", "!GetAZs", "!ImportValue", "!Select",
                "!Split", "!Join sequence", "!And", "!If", "!Not", "!Equals", "!Or",
                "!FindInMap sequence", "!Base64", "!Cidr",
              },
            },
          },
        },
      }
      for name, cfg in pairs(servers) do
        local bin = cfg.bin
        cfg.bin = nil
        if vim.fn.executable(bin) == 1 then
          vim.lsp.config(name, cfg)
          vim.lsp.enable(name)
        end
      end

      -- 保存時フォーマット (rs/go/yml: organizeImports + format)
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("my-lsp-format", {}),
        pattern = { "*.rs", "*.go", "*.yml" },
        callback = function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" }, diagnostics = {} },
            apply = true,
          })
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,
  },

  -- linting / fixing (ALE)。設定は 251_ale.vim を SSoT で source し、
  -- nvim-lspconfig との重複を避けるため ALE 自身の LSP/補完機能のみ無効化する。
  {
    "dense-analysis/ale",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      _G.src("251_ale.vim")
      vim.g.ale_disable_lsp = 1
      vim.g.ale_completion_enabled = 0
    end,
  },
}
