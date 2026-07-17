-- luacheck: globals vim
-- image.nvim: nvim 自身が Kitty graphics protocol で画像を描画する。
-- yazi の :terminal 内プレビューと違い nvim 直描画なので Ghostty へ素通しできる。
-- 用途: oil で画像ファイルを開く (hijack_file_patterns)。
-- 依存: ImageMagick CLI (magick/convert/identify) のみ。magick luarock は不要。
require("image").setup({
  backend = "kitty", -- Ghostty は kitty graphics protocol 対応
  processor = "magick_cli", -- magick luarock 不要。ImageMagick CLI を使う
  -- 開いた時に描画する拡張子。デフォルト6種 + ico/svg を追加。
  -- ({ ... } は index マージのため既定分も明記が必要。svg は rsvg-convert delegate 依存)
  hijack_file_patterns = {
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.gif",
    "*.webp",
    "*.avif",
    "*.ico",
    "*.svg",
  },
  -- markdown の自動インライン描画は OFF (oil でファイルを開いた時だけ描画する)
  integrations = {
    markdown = { enabled = false },
  },
  window_overlap_clear_enabled = true, -- 補完 popup 等と重なったら画像を一時退避
  tmux_show_only_in_active_window = true, -- 非アクティブ tmux 窓には画像を残さない
})
