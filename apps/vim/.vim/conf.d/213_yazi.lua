-- luacheck: globals vim
-- yazi.nvim: 独立 TUI ファイラ yazi を floating window で起動 (sy)。
-- yazi 本体の設定は ~/.config/yazi (= apps/yazi/yazi) が SSoT。

require("yazi").setup({
  -- ディレクトリ buffer の hijack は oil.nvim に残す (sd = oil)
  open_for_directories = false,
})
