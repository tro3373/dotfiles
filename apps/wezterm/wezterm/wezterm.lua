-- >
-- > [最高のターミナル環境を手に入れろ！WezTermに入門してみた。 | DevelopersIO](https://dev.classmethod.jp/articles/wezterm-get-started/)
-- > 下記は私の環境の代表的なものを取り出してきたものです。
-- > 設定ファイルを編集して保存すると、 WezTermを再起動することなく設定が読み込まれます。
-- > （設定にエラーがあるとエラー情報が表示されて、直近の状態が維持されるようです） これめちゃくちゃ大事です。
-- >
-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

local mac = wezterm.target_triple:find("darwin")

-- ここまでは定型文
-- この先でconfigに各種設定を書いていく

-- Color Scheme
-- config.color_scheme = 'Batman'
config.color_scheme = "Railscasts (base16)"
-- config.color_scheme = 'Apprentice (base16)'
-- config.color_scheme = 'Apprentice (Gogh)'

-- フォント
config.font = wezterm.font("Osaka-Mono", { weight = "Bold", italic = false })
-- フォントサイズ
config.font_size = mac and 18.0 or 16.0
-- 背景の非透過率（1なら完全に透過させない）
config.window_background_opacity = 1 -- 0.90

-- キーバインド
config.keys = {
  -- ¥ではなく、バックスラッシュを入力する。おそらくMac固有
  {
    key = "¥",
    action = wezterm.action.SendKey({ key = "\\" }),
  },
  -- Altを押した場合はバックスラッシュではなく¥を入力する。おそらくMac固有
  {
    key = "¥",
    mods = "ALT",
    action = wezterm.action.SendKey({ key = "¥" }),
  },
  -- ⌘ + でフォントサイズを大きくする
  {
    key = "+",
    mods = "CMD|SHIFT",
    action = wezterm.action.IncreaseFontSize,
  },
  -- ⌘ w でペインを閉じる（デフォルトではタブが閉じる）
  {
    key = "w",
    mods = "CMD",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  -- Alt v でペースト
  {
    key = "v",
    mods = "ALT",
    action = wezterm.action.PasteFrom("Clipboard"),
  },
  -- -- ⌘ Ctrl ,で下方向にペイン分割
  -- {
  --     key = ",",
  --     mods = "CMD|CTRL",
  --     action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } },
  -- },
  -- -- ⌘ Ctrl .で右方向にペイン分割
  -- {
  --     key = ".",
  --     mods = "CMD|CTRL",
  --     action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } },
  -- },
  -- -- ⌘ Ctrl oでペインの中身を入れ替える
  -- {
  --     key = "o",
  --     mods = "CMD|CTRL",
  --     action = wezterm.action.RotatePanes 'Clockwise'
  -- },
  -- -- ⌘ Ctrl hjklでペインの移動
  -- {
  --     key = 'h',
  --     mods = 'CMD|CTRL',
  --     action = wezterm.action.ActivatePaneDirection 'Left',
  -- },
  -- {
  --     key = 'j',
  --     mods = 'CMD|CTRL',
  --     action = wezterm.action.ActivatePaneDirection 'Down',
  -- },
  -- {
  --     key = 'k',
  --     mods = 'CMD|CTRL',
  --     action = wezterm.action.ActivatePaneDirection 'Up',
  -- },
  -- {
  --     key = 'l',
  --     mods = 'CMD|CTRL',
  --     action = wezterm.action.ActivatePaneDirection 'Right',
  -- },
  -- -- ⌘ Ctrl Shift hjklでペイン境界の調整
  -- {
  --     key = 'h',
  --     mods = 'CMD|CTRL|SHIFT',
  --     action = wezterm.action.AdjustPaneSize { 'Left', 2 },
  -- },
  -- {
  --     key = 'j',
  --     mods = 'CMD|CTRL|SHIFT',
  --     action = wezterm.action.AdjustPaneSize { 'Down', 2 },
  -- },
  -- {
  --     key = 'k',
  --     mods = 'CMD|CTRL|SHIFT',
  --     action = wezterm.action.AdjustPaneSize { 'Up', 2 },
  -- },
  -- {
  --     key = 'l',
  --     mods = 'CMD|CTRL|SHIFT',
  --     action = wezterm.action.AdjustPaneSize { 'Right', 2 },
  -- },
}

-- マウス操作の挙動設定
config.mouse_bindings = {
  -- 右クリックでクリップボードから貼り付け
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action.PasteFrom("Clipboard"),
  },
}

-- タブを下に表示（デフォルトでは上にある）
config.tab_bar_at_bottom = true
-- タブが1つだけの場合は非表示
config.hide_tab_bar_if_only_one_tab = true
-- Explicitly set the name of the IME server to which wezterm will connect via the XIM protocol
-- config.use_ime = true
-- config.xim_im_name = "fcitx"

return config
