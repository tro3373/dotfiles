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

-- false: Prevent the configuration error window from being displayed
config.warn_about_missing_glyphs = false

-- Color Scheme
-- config.color_scheme = 'Batman'
config.color_scheme = "Railscasts (base16)"
-- config.color_scheme = 'Apprentice (base16)'
-- config.color_scheme = 'Apprentice (Gogh)'

-- フォント
config.font = wezterm.font("Osaka-Mono", { weight = "Bold", italic = false })
-- フォントサイズ
config.font_size = mac and 18.0 or 15.0
-- 背景の非透過率（1なら完全に透過させない）
config.window_background_opacity = 1 -- 0.90

--------------------------------------------------------------------------------
-- HyperLink(Open with Click Not work..)
-- https://example.com
--------------------------------------------------------------------------------
-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- make task numbers clickable
-- the first matched regex group is captured in $1.
table.insert(config.hyperlink_rules, {
  regex = [[\b[tt](\d+)\b]],
  format = "https://example.com/tasks/?t=$1",
})
-- make username/project paths clickable. this implies paths like the following are for github.
-- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
-- as long as a full url hyperlink regex exists above this it should not match a full url to
-- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = "https://www.github.com/$1/$3",
})
-- -- If the current mouse cursor position is over a cell that contains a hyperlink,
-- -- this action causes that link to be opened.
-- config.mouse_bindings = {
-- 	-- Ctrl-click will open the link under the mouse cursor
-- 	{
-- 		event = { Up = { streak = 1, button = "Left" } },
-- 		mods = "CTRL",
-- 		action = wezterm.action.OpenLinkAtMouseCursor,
-- 	},
-- }

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
  -- Ctrl+Shift n で 全画面トグル
  {
    key = "n",
    mods = "SHIFT|CTRL",
    action = wezterm.action.ToggleFullScreen,
    -- action = wezterm.window:maximize(),
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
