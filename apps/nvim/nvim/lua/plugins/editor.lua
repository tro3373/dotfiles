-- luacheck: ignore 112 113
-- 編集・モーション系。設定を持つものは既存 conf.d/*.vim を source 再利用する。
return {
  -- 囲み文字操作 + ドットリピート対応
  { "tpope/vim-surround", event = "VeryLazy", dependencies = { "tpope/vim-repeat" } },
  { "tpope/vim-repeat", lazy = true },

  -- コメントアウト
  -- VeryLazy だと 302 内の `autocmd FileType markdown setlocal commentstring=> %s` が
  -- バッファの FileType より後に登録され、組み込み ftplugin の `<!-- %s -->` が残る。
  -- 起動時ロード(lazy=false)で commentstring autocmd を FileType より前に張る。
  -- (vim-commentary は軽量で起動コストは無視できる)
  {
    "tpope/vim-commentary",
    lazy = false,
    config = function()
      _G.src("302_commentary.vim")
    end,
  },

  -- () 等の入力補完
  {
    "kana/vim-smartinput",
    dependencies = { "Shougo/context_filetype.vim", "cohama/vim-smartinput-endwise" },
    event = "InsertEnter",
    config = function()
      _G.src("301_vim-smartinput.vim")
    end,
  },
  { "Shougo/context_filetype.vim", lazy = true },
  -- end 補完 (vim-smartinput の dependency としてロード)
  { "cohama/vim-smartinput-endwise", lazy = true },

  -- ウィンドウサイズ変更等のサブモード
  {
    "kana/vim-submode",
    event = "VeryLazy",
    config = function()
      _G.src("223_vim-submode.vim")
    end,
  },

  -- j/k 連打の加速移動
  {
    "rhysd/accelerated-jk",
    event = "VeryLazy",
    config = function()
      _G.src("203_accelerated-jk.vim")
    end,
  },

  -- v で選択範囲を段階拡張
  {
    "terryma/vim-expand-region",
    event = "VeryLazy",
    config = function()
      _G.src("305_vim-expand-region.vim")
    end,
  },

  -- f 検索強化
  { "rhysd/clever-f.vim", event = "VeryLazy" },

  -- カーソル下へのジャンプ
  {
    "skanehira/jumpcursor.vim",
    event = "VeryLazy",
    config = function()
      _G.src("305_jumpcursor.vim")
    end,
  },

  -- クイックハイライト
  {
    "t9md/vim-quickhl",
    event = "VeryLazy",
    config = function()
      _G.src("306_vim-quickhl.vim")
    end,
  },

  -- 整形 (Align / easy-align)
  { "vim-scripts/Align", cmd = "Align" },
  {
    "junegunn/vim-easy-align",
    event = "VeryLazy",
    config = function()
      _G.src("307_vim-easy-align.vim")
    end,
  },

  -- 現在ファイルを実行して quickfix 表示
  {
    "thinca/vim-quickrun",
    dependencies = { "osyo-manga/shabadou.vim" },
    cmd = "QuickRun",
    config = function()
      _G.src("308_vim-quickrun.vim")
    end,
  },
  { "osyo-manga/shabadou.vim", lazy = true },

  -- 長いコマンド名の自動展開
  { "thinca/vim-ambicmd", event = "CmdlineEnter" },

  -- ブラウザで開く
  { "tyru/open-browser.vim", cmd = { "OpenBrowser", "OpenBrowserSearch", "OpenBrowserSmartSearch" }, keys = "<Plug>(openbrowser-smart-search)" },

  -- sudo 編集
  { "vim-scripts/sudo.vim", cmd = { "SudoRead", "SudoWrite" } },
}
