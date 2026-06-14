-- luacheck: ignore 112 113
-- vimscript 互換レイヤ
-- 既存 ~/.vim/conf.d/*.vim を SSoT として source 再利用するための shim を提供する。
--   - g:is_* / g:winclip 等のプラグイン非依存 vimscript が参照する vim グローバル変数
--   - g:plug.is_installed() ... 各 conf.d 設定の finish ガードを lazy.nvim 基準で解決する
--   - _G.src() ... conf.d 設定ファイルを source するヘルパ

-- プラットフォーム判定は global.lua の _G.is_* を唯一の正とし、
-- sourced vimscript 用の g:is_* (0/1 数値) はそこから派生させる (SSoT)。
for _, name in ipairs({ "is_windows", "is_cygmsys2", "is_mac", "is_linux", "is_wsl", "is_orb", "is_ubuntu" }) do
  vim.g[name] = _G[name] and 1 or 0
end

-- 100_base.vim の g:winclip (WSL クリップボード経路)
vim.g.winclip = "/mnt/c/Windows/System32/clip.exe"

-- leader は lazy.setup より前に確定させる必要がある (101_mapping.vim と同値)
vim.g.mapleader = " "

-- ~/.vim を runtimepath に載せて ftplugin/after/snippets/conf.d を解決可能にする。
-- 実際の rtp 登録は pm.lua の lazy performance.rtp.paths で行う。lazy.setup は
-- performance.rtp.reset で runtimepath を初期化するため、ここで append しても消える。
_G.vimdir = vim.fn.expand("~/.vim")
local vimdir = _G.vimdir

-- g:plug.is_installed() shim
-- 各 conf.d 設定は `if !g:plug.is_installed("name") | finish | endif` で自己ゲートする。
-- lazy.nvim の spec に存在すれば「インストール済み」とみなす。
vim.cmd([[
  let g:plug = { 'plugs': {} }
  function! g:plug.is_installed(name) abort
    return luaeval('require("lazy.core.config").spec.plugins[_A] ~= nil and 1 or 0', a:name)
  endfunction
]])

-- conf.d 設定ファイルを source するヘルパ (lazy spec の config から使う)
_G.src = function(name)
  vim.cmd("source " .. vimdir .. "/conf.d/" .. name)
end
