-- luacheck: ignore 112 113
-- LSP / 補完 / スニペット / lint
--   vim-lsp(+vim-lsp-settings) → nvim-lspconfig(+mason+mason-lspconfig)
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

  -- LSP サーバ管理 (バイナリは :Mason / :LspInstall でインストール)
  -- cmd は :Mason 系を全て lazy トリガーに登録 (起動直後の :MasonInstall も効く)
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    opts = {},
  },

  -- mason 導入済みサーバを vim.lsp.enable で自動有効化 (vim-lsp-settings 相当)。
  -- setup は nvim-lspconfig の config 末尾で settings 登録後に呼ぶ。
  { "mason-org/mason-lspconfig.nvim", lazy = true },

  -- LSP 設定本体 (settings のみ定義。enable は mason-lspconfig 任せ)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
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
          -- <C-]> は定義を新規タブで開く (vim版 `:tab LspDefinition` 踏襲)。
          -- on_list は定義が見つかった時のみ呼ばれるので、空振り時はタブを作らない。
          vim.keymap.set("n", "<C-]>", function()
            vim.lsp.buf.definition({
              on_list = function(result)
                vim.cmd.tabnew()
                vim.fn.setqflist({}, " ", result)
                vim.cmd.cfirst()
              end,
            })
          end, opts)
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

      -- nvim 0.11+ ネイティブ API。nvim-lspconfig の lsp/<name>.lua
      -- (cmd/filetypes/root_markers) に下記設定をマージする。
      vim.lsp.config("*", { capabilities = capabilities })

      -- サーバ固有 settings のみ定義 (g:lsp_settings 相当)。
      -- cmd/filetypes は lspconfig プリセット、enable は mason-lspconfig が担当。
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })
      vim.lsp.config("pylsp", {
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
      })
      vim.lsp.config("yamlls", {
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
      })

      -- mason 導入済みサーバを自動 enable (settings 登録後に実行する)
      require("mason-lspconfig").setup({ automatic_enable = true })

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

  -- kakehashi: Tree-sitter ベースの汎用 LS。markdown のコードブロック内を
  -- 既存 LSP へブリッジする (md内 Lua/Python 等で definition/hover/補完)。
  -- attach は filetypes=markdown に限定 (host ハイライトは nvim-treesitter 任せ)。
  -- VeryLazy で起動直後に一度だけロードし vim.lsp.enable する (ft/event の遅延
  -- ロードは `nvim file.md` 起動引数だと発火しないため)。enable 済みサーバが
  -- 揃った後に config が走るので bridge も正しく生成。バイナリ未導入なら no-op。
  {
    "atusy/kakehashi.nvim",
    event = "VeryLazy",
    config = function()
      if vim.fn.executable("kakehashi") ~= 1 then
        return
      end
      -- バンドルされた commentstring/endwise クエリ用にプラグイン dir を searchPaths へ
      local src = vim.api.nvim_get_runtime_file("lua/kakehashi.lua", false)[1]
      local plugin_dir = src and vim.fn.fnamemodify(src, ":h:h") or nil

      -- md コードブロックのブリッジ対象 (言語名)。サーバが無い言語を有効化しても
      -- 無害なため、よく使う言語を静的に列挙する。実際の転送先 LS は LspAttach の
      -- inherit_nvim_lsp_config が enable 済みサーバから動的に解決する。
      local bridge = {}
      local langs = "go lua python yaml json typescript javascript rust bash c cpp html css sql"
      for _, lang in ipairs(vim.split(langs, " ")) do
        bridge[lang] = { enabled = true }
      end

      vim.lsp.config("kakehashi", {
        cmd = { "kakehashi" },
        filetypes = { "markdown" },
        init_options = {
          searchPaths = plugin_dir and { plugin_dir } or nil,
          languages = { markdown = { bridge = bridge } },
        },
        on_init = function(client)
          -- semanticTokens/full/delta を使う (range 要求は無効化)
          local stp = client.server_capabilities.semanticTokensProvider
          if stp then
            stp.range = false
          end
        end,
      })
      vim.lsp.enable("kakehashi")

      -- kakehashi.nvim の inherit_nvim_lsp_config は effectiveConfiguration 応答の
      -- languageServers が JSON null (vim.NIL) で返ると configured_servers を index して
      -- 落ちる (kakehashi.lua:37 attempt to index 'configured_servers')。複数 md を
      -- 同時に開くと発火しやすい。プラグイン本体は lazy 管理で編集が上書きされるため、
      -- nil/vim.NIL を握る安全版へ差し替える (上流修正されたら撤去可)。
      local function denil(v)
        if v == nil or v == vim.NIL then
          return nil
        end
        return v
      end
      local kh = require("kakehashi")
      kh.inherit_nvim_lsp_config = function(client, servers, behavior)
        behavior = behavior or "keep"
        client:request("kakehashi/internal/effectiveConfiguration", vim.empty_dict(), function(err, result)
          if err then
            return
          end
          result = denil(result) or {}
          local settings = denil(result.settings) or {}
          local configured_servers = denil(settings.languageServers) or {}
          local ignored_servers = { copilot = true, kakehashi = true, denols = true }
          for _, name in pairs(servers) do
            local ok, config = pcall(function()
              return vim.lsp._enabled_configs[name].resolved_config
            end)
            if not ok then
              config = (vim.lsp.config and vim.lsp.config[name]) or (vim.lsp.configs and vim.lsp.configs[name])
            end
            if config and not ignored_servers[name] then
              local new_config = vim.tbl_extend(behavior, configured_servers[name] or {}, {
                cmd = type(config.cmd) == "table" and config.cmd or nil,
                languages = config.filetypes,
              })
              if new_config.cmd then
                configured_servers[name] = new_config
              end
            end
          end
          client:notify("workspace/didChangeConfiguration", {
            settings = { languageServers = configured_servers },
          })
        end)
      end

      -- 既存 vim.lsp.config 定義を継承してブリッジ先 LS に流用 (二重設定回避)。
      -- inherit は client へ didChangeConfiguration を送るだけなので 1 クライアント 1 回で十分。
      local inherited = {}
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my-kakehashi-attach", {}),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "kakehashi" and not inherited[client.id] then
            inherited[client.id] = true
            kh.inherit_nvim_lsp_config(client, vim.tbl_keys(vim.lsp._enabled_configs), "keep")
          end
        end,
      })

      -- extra 機能トグル (conceal: backtick 等を隠す / context: sticky header)
      vim.api.nvim_create_user_command("KakehashiConceal", function()
        require("kakehashi.extra.conceal").toggle()
      end, {})
      vim.api.nvim_create_user_command("KakehashiContext", function()
        require("kakehashi.extra.context").toggle()
      end, {})
    end,
  },
}
