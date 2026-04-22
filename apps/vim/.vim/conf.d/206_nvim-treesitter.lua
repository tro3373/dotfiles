-- luacheck: globals vim
-- treesitter 対応ファイルタイプのホワイトリスト
-- 他ファイルは従来の vim syntax / colorscheme (Apprentice) を維持する
local ts_enabled_filetypes = { hurl = true }

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'hurl' },
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, _)
      return not ts_enabled_filetypes[lang]
    end,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = function(lang, _)
      return not ts_enabled_filetypes[lang]
    end,
  },
})
