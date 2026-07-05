-- luacheck: ignore 112 113
-- AI 補助 (Copilot / CopilotChat / Claude Code) と denops 翻訳
return {
  -- GitHub Copilot
  {
    "github/copilot.vim",
    -- InsertEnter だと初回 insert 時に language-server のコールドスタート
    -- (~1.5s) が走り最初の提案が遅れる。VeryLazy で起動後アイドル中にロードし、
    -- copilot#Init でサーバを先に温めておくことで初回の待ちを消す。
    event = "VeryLazy",
    config = function()
      _G.src("950_copilot.vim")
      vim.fn["copilot#Init"]()
    end,
  },

  -- Copilot Chat (設定は 951_copilot-chat.vim が luafile + setup + <C-l> マップを行う)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle" },
    keys = { { "<C-l>", mode = { "n", "v" } } },
    config = function()
      _G.src("951_copilot-chat.vim")
    end,
  },

  -- NES を使うには lsp.lua の copilot LSP(NES 用) も enable すること。
  -- Claude トグルは <C-'> に割当 (CopilotChat の <C-l> と分離)。
  -- sidekick.nvim: AI CLI 統合 (Claude Code を nvim terminal で起動) + Copilot NES。
  -- 注意: CLI の応答は claude の terminal ウィンドウに表示される (CopilotChat のような
  --       整形済みチャットバッファではなく素の CLI 画面)。sidekick は CLI のラッパー。
  {
    "folke/sidekick.nvim",
    -- NES の autocmd (TextChanged 等) を編集中に効かせるため VeryLazy でロードする。
    event = "VeryLazy",
    opts = {
      -- Copilot Next Edit Suggestions (複数行リファクタ提案を diff 表示)。
      -- 使用する copilot LSP client の enable は lsp.lua 側で行う。
      nes = { enabled = true },
      cli = {
        -- claude は nvim ネイティブの terminal ウィンドウ(既定=右split)で開く。
        -- mux.enabled=true にすると tmux 常駐へ切替 (nvim 再起動後もセッション維持できるが、
        -- terminal 内 tmux で操作しづらいため既定は buffer モード=false)。
        mux = {
          backend = "tmux",
          enabled = false,
        },
        -- tmux の全ペインを走査して外部 claude (別ターミナルの Claude Code 等) を
        -- external セッションとして拾う挙動を無効化。切らないと <C-'> 起動時に
        -- 「どの claude に繋ぐか」の session picker が出る (is_proc の消費は tmux backend のみ)。
        tools = {
          claude = { is_proc = false },
        },
        win = {
          keys = {
            -- claude ウィンドウから <C-h> でエディタへ戻る (隠さず blur)。無効化中。
            -- blur_ctrl_h = { "<C-h>", "blur", mode = "nt" },
          },
        },
      },
    },
    keys = {
      -- NES: normal で <Tab> = 次の提案へジャンプ / 適用。提案が無ければ通常の <Tab>。
      {
        "<Tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>"
          end
        end,
        expr = true,
        desc = "Sidekick: NES jump/apply",
      },
      -- <C-'> = Claude Code をトグル起動 (CopilotChat の <C-l> とは分離)。
      -- visual 選択中は選択をコンテキストとして貼って起動 (未送信)。
      {
        "<C-'>",
        function()
          local m = vim.fn.mode()
          if m == "v" or m == "V" or m == "\22" then -- \22 = <C-v> blockwise
            require("sidekick.cli").send({ name = "claude", msg = "{selection}", submit = false, focus = true })
            return
          end
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        mode = { "n", "x", "t" },
        desc = "Sidekick: toggle Claude (paste selection when visual)",
      },
      -- <C-.> = これなに (カーソル/選択箇所を Claude に説明させる)
      {
        "<C-.>",
        function()
          require("sidekick.cli").send({
            name = "claude",
            msg = "これは何か日本語で簡潔に説明して: {this}",
            submit = true,
          })
        end,
        mode = { "n", "x" },
        desc = "Sidekick: explain this",
      },
      -- <C-,> = この英語を訳す
      {
        "<C-,>",
        function()
          require("sidekick.cli").send({
            name = "claude",
            msg = "この英語を自然な日本語に訳して: {this}",
            submit = true,
          })
        end,
        mode = { "n", "x" },
        desc = "Sidekick: translate EN->JA",
      },
      -- <leader>a 系 (a = AI)
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        mode = { "n", "x" },
        desc = "Sidekick: toggle CLI",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").send({ name = "claude", msg = "{selection}", submit = true })
        end,
        mode = { "x" },
        desc = "Sidekick: send selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick: prompt picker",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").select()
        end,
        desc = "Sidekick: select CLI tool",
      },
    },
  },

  -- Claude Code は無効化 (コメントアウト)。
  -- 理由: <leader>cc が commentary の <leader>c の prefix になり timeoutlen 待ちで
  -- コメントトグルが遅くなる。vim 側も claude-code は無効のため挙動を揃える。
  -- 再有効化する場合は <leader>c と競合しないキーへ移すこと。
  -- {
  --   "greggh/claude-code.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
  --   keys = { { "<leader>cc", mode = { "n", "t" } } },
  --   config = function()
  --     _G.src("952_claude_code.vim")
  --   end,
  -- },

  -- denops + 翻訳 (deno 必須)
  {
    "vim-denops/denops.vim",
    cond = vim.fn.executable("deno") == 1,
    event = "VeryLazy",
    config = function()
      _G.src("224_denops.vim")
    end,
  },
  {
    "skanehira/denops-translate.vim",
    cond = vim.fn.executable("deno") == 1,
    dependencies = { "vim-denops/denops.vim" },
    -- 初回 <Leader>tr を速くするため keys ではなく VeryLazy で起動時にロードし、
    -- アイドル時に translate プラグインを登録しておく(キー押下時はネットワークのみ)。
    -- denops サーバは元々 VeryLazy で毎セッション起動するため追加コストは登録分のみ。
    event = "VeryLazy",
    config = function()
      _G.src("310_denops-translate.vim")
      -- denops 本体が先に起動し plugin discovery を終えていると、後からロードされる
      -- 本プラグインは discovery 対象外で登録されず :Translate(denops#request) が
      -- 永久に待つ。server 稼働中なら rtp を再 discover して translate を登録する。
      if vim.fn.exists("*denops#server#status") == 1 and vim.fn["denops#server#status"]() == "running" then
        vim.fn["denops#plugin#discover"]()
      end
    end,
  },
}
