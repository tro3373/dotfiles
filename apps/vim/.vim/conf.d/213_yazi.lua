-- luacheck: globals vim
-- yazi.nvim: 独立 TUI ファイラ yazi を floating window で起動 (sy)。
-- yazi 本体の設定は ~/.config/yazi (= apps/yazi/yazi) が SSoT。

require("yazi").setup({
  -- ディレクトリ buffer の hijack は oil.nvim に残す (sd = oil)
  open_for_directories = false,
})

-- sY: yazi を tmux の新規ウィンドウで起動する。
-- nvim のビルトイン :terminal は画像プロトコル(kitty graphics/sixel)を外側端末へ
-- 通さないため floating(sy) では画像プレビューが出ない。画像を見たい時は :terminal を
-- 挟まない tmux 窓側で yazi を開き、端末(Ghostty)へ直接描画させる。
-- yazi 終了で窓は自動で閉じる。キー割当は plugins/finder.lua の keys 側。
-- 現在バッファから yazi に渡すパスを決める (Guard Clause: 該当したら即 return)。
local function yazi_target()
  local name = vim.api.nvim_buf_get_name(0)
  if name:match("^oil://") then
    return (name:gsub("^oil://", "")) -- oil:///abs/path -> /abs/path (ディレクトリ)
  end
  if name ~= "" and vim.uv.fs_stat(name) then
    return name -- 実在するファイル/ディレクトリ: yazi は親を開き当該を hover
  end
  return vim.fn.getcwd() -- 無名/仮想バッファ(term://, fugitive:// 等) は cwd へ
end

function _G.yazi_open_in_tmux()
  if vim.env.TMUX == nil or vim.env.TMUX == "" then
    vim.notify("sY: tmux の外では使えない (nvim 内は sy)", vim.log.levels.WARN)
    return
  end
  -- 単一シェルコマンド文字列で渡す (tmux が sh -c 経由で実行、shellescape で空白対応)
  vim.fn.jobstart({ "tmux", "new-window", "yazi " .. vim.fn.shellescape(yazi_target()) })
end
