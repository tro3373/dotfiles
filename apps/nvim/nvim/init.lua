-- Neovim Lua エントリ (lua モード)。
-- vim モード時は bin/nvim_switch が ~/.vimrc を init.vim として symlink する。
--
-- 構成 (SSoT ハイブリッド方針):
--   - global/base/pm/LSP/補完/statusline は lua ネイティブ
--   - bespoke な utility コマンド(102_funcs)・汎用キーマップ(101_mapping)・
--     残す vim プラグイン設定は既存 ~/.vim/conf.d/*.vim を source して二重管理を避ける

require("global") -- ヘルパ関数 (_G.map/au/aug 等) + プラットフォーム判定
require("compat") -- vimscript 互換 shim (g:is_* / g:plug / _G.src / leader)
require("base") -- オプション・autocmd (100_base.vim の lua ネイティブ版)
require("pm") -- lazy.nvim ブートストラップ + プラグイン spec

-- 汎用 vimscript を SSoT で source (プラグイン非依存)
_G.src("101_mapping.vim") -- 汎用キーマップ
_G.src("102_funcs.vim") -- utility コマンド/関数群
_G.src("999_custom.vim") -- 追加ハイライト等

require("run") -- 現在バッファ実行 → 右 vsplit 表示 (vim-quickrun の nvim 代替)
