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

  -- シンプルファイラ (作者 fork)
  {
    "tro3373/vaffle.vim",
    -- BufEnter で netrw を乗っ取りディレクトリ buffer を vaffle 化するため、
    -- cmd 遅延ロードだと autocmd 未登録で「ディレクトリを開いても出ない」状態になる。
    -- eager ロードして起動時に plugin/vaffle.vim の BufEnter autocmd を登録する。
    lazy = false,
    config = function()
      _G.src("210_vaffle.vim")
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
