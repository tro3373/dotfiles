-- luacheck: ignore 112 113
-- ファイル検索 (fzf) / ファイラ (vaffle) / git (tig-explorer)
-- 旧 unite.vim / ctrlp.vim はレガシーのため移行対象外 (fzf へ集約)。
return {
  -- fuzzy finder 本体 + vim 統合 (fzf バイナリはシステム PATH のものを利用するため build 不要)
  { "junegunn/fzf" },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    event = "VeryLazy",
    config = function()
      _G.src("222_fzf.vim")
    end,
  },

  -- シンプルファイラ (作者 fork) -- oil.nvim へ移行のため無効化 (戻す場合はコメント解除)
  -- {
  --   "tro3373/vaffle.vim",
  --   -- BufEnter で netrw を乗っ取りディレクトリ buffer を vaffle 化するため、
  --   -- cmd 遅延ロードだと autocmd 未登録で「ディレクトリを開いても出ない」状態になる。
  --   -- eager ロードして起動時に plugin/vaffle.vim の BufEnter autocmd を登録する。
  --   lazy = false,
  --   config = function()
  --     _G.src("210_vaffle.vim")
  --   end,
  -- },

  -- ファイラ (oil.nvim) + git 装飾 (oil-git.nvim)。vaffle の後継。
  -- 設定本体は conf.d/212_oil.vim → 212_oil.lua (SSoT)。
  {
    "stevearc/oil.nvim",
    -- oil は netrw を乗っ取りディレクトリ buffer を oil 化する。vaffle と同様に
    -- 起動時 autocmd 登録が要るため eager ロードする。
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "malewicz1337/oil-git.nvim",
    },
    config = function()
      _G.src("212_oil.vim")
    end,
  },

  -- ファイラ (yazi.nvim)。oil と併用: バッファ編集は oil (sd) / プレビュー・探索は yazi (sy)。
  -- setup 設定は conf.d/213_yazi.vim → 213_yazi.lua。キーは lazy 遅延読み込みの
  -- トリガを兼ねるため spec 側 (keys) に置く。
  {
    "mikavilpas/yazi.nvim",
    keys = {
      { "sy", "<cmd>Yazi<cr>", desc = "Open yazi at current file" },
      -- sY: nvim 外 (tmux 新規窓) で yazi を開く。:terminal を挟まないため
      -- 画像プレビューが Ghostty へ素通しで表示される (関数は 213_yazi.lua)。
      {
        "sY",
        function()
          _G.yazi_open_in_tmux()
        end,
        desc = "Open yazi in a new tmux window (画像プレビュー可)",
      },
    },
    config = function()
      _G.src("213_yazi.vim")
    end,
  },

  -- vim から tig
  {
    "iberianpig/tig-explorer.vim",
    event = "VeryLazy",
    config = function()
      _G.src("301_tig-001-explorer.vim")
      _G.src("301_tig-002-nvr.vim")
    end,
  },
}
