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
