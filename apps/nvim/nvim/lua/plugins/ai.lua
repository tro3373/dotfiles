-- luacheck: ignore 112 113
-- AI 補助 (Copilot / CopilotChat / Claude Code) と denops 翻訳
return {
  -- GitHub Copilot
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      _G.src("950_copilot.vim")
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

  -- Claude Code (vim 側ではコメントアウトされていたが、ユーザ要望で lazy spec へ取り込み有効化)
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
    keys = { { "<leader>cc", mode = { "n", "t" } } },
    config = function()
      _G.src("952_claude_code.vim")
    end,
  },

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
    keys = {
      { "<Leader>tr", mode = { "n", "x" } },
      { "<Leader>Tr", mode = { "n", "x" } },
      { "<Leader>n", mode = { "n", "x" } },
      { "<Leader>N", mode = { "n", "x" } },
    },
    config = function()
      _G.src("310_denops-translate.vim")
    end,
  },
}
