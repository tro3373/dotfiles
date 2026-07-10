-- luacheck: ignore 112 113
if vim.loader then
  vim.loader.enable()
end

_G.is_windows = vim.fn.has("win16") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
_G.is_cygmsys2 = vim.fn.has("win32unix") == 1
_G.is_mac = not is_windows
  and not is_cygmsys2
  and (
    vim.fn.has("mac") == 1
    or vim.fn.has("macunix") == 1
    or vim.fn.has("gui_macvim") == 1
    or (vim.fn.executable("xdg-open") == 0 and vim.fn.system("uname"):match("^darwin"))
  )
_G.is_linux = not is_windows and not is_cygmsys2 and not is_mac and vim.fn.has("unix") == 1
-- vim.fn.* は 0/1 数値を返す。Lua では 0 も truthy なので必ず明示比較する。
_G.is_wsl = vim.fn.empty(vim.fn.getenv("WSL_DISTRO_NAME")) == 0
_G.is_orb = vim.fn.system("uname -r"):lower():match("orbstack") ~= nil
_G.is_ubuntu = is_linux
  and vim.fn.filereadable("/etc/debian_version") == 0
  and vim.fn.filereadable("/etc/lsb-release") == 0
if is_windows then
  vim.opt.shellslash = true
end

_G.dd = function(...)
  require("util.debug").dump(...)
end
vim.print = _G.dd

-- map functions
_G["map"] = function(mode, lhs, rhs, opt)
  vim.keymap.set(mode, lhs, rhs, opt or { silent = true })
end

for _, mode in pairs({ "n", "v", "i", "o", "c", "t", "x", "t" }) do
  _G[mode .. "map"] = function(lhs, rhs, opt)
    map(mode, lhs, rhs, opt)
  end
end

_G.getenv = function(name, def)
  local v = vim.fn.getenv(name)
  if v == vim.NIL then
    return def
  end
  return v
end

local function get_au_group_name(events, group, make_group)
  local res = group
  if res == nil or #res == 0 then
    -- グループ未指定: aug(既存グループ追加)では無名、aumg(新規作成)のみ event 名から導出
    if not make_group then
      return nil
    end
    res = events
    if type(events) == "table" then
      -- events is table
      res = "au_"
      for _, v in ipairs(events) do
        res = res .. "_" .. v
      end
    end
  end
  -- make_group のときのみ augroup を生成する。
  -- aumg が event 名(FileType/BufRead 等)で augroup を作ると、後続の sourced vimscript の
  -- `autocmd FileType ...` が group 名と誤認され E216 になるため、必ず指定 group 名を使う。
  if make_group then
    vim.api.nvim_create_augroup(res, {})
  end
  return res
end

-- Lua で名前付き関数パラメータ #Lua - Qiita
-- https://qiita.com/zetamatta/items/f0ed210e9eccfd918280
--    > Luaでは「関数のパラメータがテーブルコンストラクター１個の時、
--    > 関数コールの丸括弧を省略できる」
-- local function _create_au(events, group, make_group, cb, pat)
local function _create_au(args)
  local opt = {}
  local g = get_au_group_name(args.events, args.group, args.make_group)
  if g then
    opt.group = g
  end
  if args.pat then
    opt.pattern = args.pat
  end
  local cmd = type(args.cb) == "string" and "command" or "callback"
  opt[cmd] = args.cb
  vim.api.nvim_create_autocmd(args.events, opt)
end
-- _G.au = function(events, cb, pat)
_G.au = function(args)
  _create_au({ events = args.events, group = nil, make_group = false, cb = args.cb, pat = args.pat })
end
-- _G.aumg = function(events, group, cb, pat)
_G.aumg = function(args)
  -- _create_au(events, group, true, cb, pat)
  _create_au({ events = args.events, group = args.group, make_group = true, cb = args.cb, pat = args.pat })
end
-- _G.aug = function(events, group, cb, pat)
_G.aug = function(args)
  -- _create_au(events, group, false, cb, pat)
  _create_au({ events = args.events, group = args.group, make_group = false, cb = args.cb, pat = args.pat })
end
_G.au_ft_map = function(pat, ft)
  local function cb()
    vim.opt_local.ft = ft
  end
  -- _create_au({ "BufNewFile", "BufRead" }, nil, false, cb, pat)
  _create_au({ events = { "BufNewFile", "BufRead" }, group = nil, make_group = false, cb = cb, pat = pat })
end

-- Call Script
-- alias to vim's objects
-- g = vim.g
-- o = vim.o
-- opt = vim.opt
-- cmd = vim.cmd
-- fn = vim.fn
-- api = vim.api
