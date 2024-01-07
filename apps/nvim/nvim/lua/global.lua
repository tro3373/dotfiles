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
_G.is_wsl = vim.fn.getenv("WSL_DISTRO_NAME") ~= ""
_G.is_ubuntu = is_linux
  and not vim.fn.filereadable("/etc/debian_version")
  and not vim.fn.filereadable("/etc/lsb-release")
if is_windows then
  vim.opt.shellslash = true
end

_G.dd = function(...)
  require("util.debug").dump(...)
end
vim.print = _G.dd

-- map functions
-- local map = vim.api.nvim_set_keymap
-- local opts = { noremap = true, silent = true }
-- map('i', 'jj', '<ESC>', opts)
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
  if not make_group then
    return nil
  end
  local res = group
  if res == nil or #res == 0 then
    res = events
    if type(events) == "table" then
      -- events is table
      res = "au_"
      for _, v in ipairs(events) do
        res = res .. "_" .. v
      end
    end
  end
  vim.api.nvim_create_augroup(res, {})
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
  _create_au({ events = args.events, groups = nil, make_group = false, cb = args.cb, pat = args.pat })
end
-- _G.aumg = function(events, group, cb, pat)
_G.aumg = function(args)
  -- _create_au(events, group, true, cb, pat)
  _create_au({ events = args.events, groups = args.group, make_group = true, cb = args.cb, pat = args.pat })
end
-- _G.aug = function(events, group, cb, pat)
_G.aug = function(args)
  -- _create_au(events, group, false, cb, pat)
  _create_au({ events = args.events, groups = args.group, make_group = false, cb = args.cb, pat = args.pat })
end
_G.au_ft_map = function(pat, ft)
  local function cb()
    vim.opt_local.ft = ft
  end
  -- _create_au({ "BufNewFile", "BufRead" }, nil, false, cb, pat)
  _create_au({ events = { "BufNewFile", "BufRead" }, groups = nil, make_group = false, cb = cb, pat = pat })
end

-- Call Script
-- alias to vim's objects
-- g = vim.g
-- o = vim.o
-- opt = vim.opt
-- cmd = vim.cmd
-- fn = vim.fn
-- api = vim.api
