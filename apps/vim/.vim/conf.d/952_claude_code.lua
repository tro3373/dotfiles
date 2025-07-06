-- Claude Code configuration for Neovim

-- グローバル変数として公開(Vimスクリプトから呼び出す)
_G.claude_code_setup = function()
  require("claude-code").setup({
    -- Terminal window settings
    window = {
      split_ratio = 0.5, -- Percentage of screen for the terminal window
      position = "botright", -- Position of the window
      enter_insert = true, -- Whether to enter insert mode when opening Claude Code
      hide_numbers = true, -- Hide line numbers in the terminal window
      hide_signcolumn = true, -- Hide the sign column in the terminal window
    },

    -- File refresh settings
    refresh = {
      enable = true, -- Enable file change detection
      updatetime = 100, -- updatetime when Claude Code is active (milliseconds)
      timer_interval = 1000, -- How often to check for file changes (milliseconds)
      show_notifications = true, -- Show notification when files are reloaded
    },

    -- Git project settings
    git = {
      use_git_root = true, -- Set CWD to git root when opening Claude Code (if in git project)
    },

    -- Shell-specific settings
    shell = {
      separator = "&&", -- Command separator used in shell commands
      pushd_cmd = "pushd", -- Command to push directory onto stack
      popd_cmd = "popd", -- Command to pop directory from stack
    },

    -- Command settings
    command = "claude", -- Command used to launch Claude Code

    -- Command variants
    command_variants = {
      -- Conversation management
      continue = "--continue", -- Resume the most recent conversation
      resume = "--resume", -- Display an interactive conversation picker

      -- Output options
      verbose = "--verbose", -- Enable verbose logging with full turn-by-turn output
    },

    -- Keymaps
    keymaps = {
      toggle = {
        normal = "<leader>cc", -- Normal mode keymap for toggling Claude Code
        terminal = "<leader>cc", -- Terminal mode keymap for toggling Claude Code
        variants = {
          continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
          verbose = "<leader>cV", -- Normal mode keymap for Claude Code with verbose flag
        },
      },
      window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
      scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
    },
  })
end
