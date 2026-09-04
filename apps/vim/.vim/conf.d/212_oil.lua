-- luacheck: globals vim
-- oil.nvim: バッファ編集でファイル操作するファイラ (vaffle の後継)

-- 自前 trash (bin/trash → gomi)。エントリのあるディレクトリを cwd にして
-- gomi の git-root 判定をそのエントリ基準にする (cwd 外 browse でも正しい .trash へ)。
local function trash_external(path, cb)
  local dir = vim.fn.fnamemodify(path, ":h")
  vim.system({ "trash", path }, { cwd = dir, text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        cb(("trash failed (%d): %s"):format(obj.code, vim.trim(obj.stderr or "")))
        return
      end
      cb(nil)
    end)
  end)
end

-- oil の native 削除 (dd + :w) を自前 trash に差し替え (内部 adapter の monkeypatch)。
-- ※ oil 更新で delete_to_trash(path, cb) のシグネチャが変わったら要追従。
require("oil.adapters.trash").delete_to_trash = trash_external

-- T: カーソル下を即 trash (dd+:w 不要の vaffle 流ショートカット)
local function trash_cursor_entry()
  local oil = require("oil")
  local entry, dir = oil.get_cursor_entry(), oil.get_current_dir()
  if not entry or not dir then
    return
  end
  trash_external(dir .. entry.name, function(err)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end
    require("oil.actions").refresh.callback() -- 削除を buffer に反映 (未保存編集があれば確認)
  end)
end

-- winbar に現在ディレクトリを表示 (ssh 等で取得不可なら buffer 名にフォールバック)。
-- winbar の %!v:lua... から呼ぶためグローバル関数にする。
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if not dir then
    return vim.api.nvim_buf_get_name(0)
  end
  return vim.fn.fnamemodify(dir, ":~")
end

-- <CR>: nvim では読めない形式 (PDF/Office/動画/音声) は bin/open へ委譲する。
-- 画像は image.nvim が nvim 内に直描画するので対象外 (214_image.lua)。
-- md/html も nvim で編集したいので対象外。単発で外部に出したいときは既定の gx を使う。
local open_external_ext = {
  pdf = true,
  xlsx = true,
  xls = true,
  docx = true,
  doc = true,
  pptx = true,
  ppt = true,
  mp4 = true,
  mov = true,
  mkv = true,
  avi = true,
  webm = true,
  mp3 = true,
  m4a = true,
  flac = true,
  wav = true,
}

local function select_or_open_external()
  local oil = require("oil")
  local entry, dir = oil.get_cursor_entry(), oil.get_current_dir()
  local ext = entry and entry.type ~= "directory" and entry.name:match("%.([^.]+)$")
  if not (dir and ext and open_external_ext[ext:lower()]) then
    require("oil.actions").select.callback()
    return
  end
  -- bin/open が拡張子ごとの起動先を持つ (SSoT)。nvim 側は投げるだけ。
  vim.system({ "open", dir .. entry.name }, { detach = true })
end

require("oil").setup({
  delete_to_trash = true, -- native 削除も上記 monkeypatch 経由で gomi へ
  view_options = { show_hidden = true },
  win_options = { winbar = "%!v:lua.get_oil_winbar()" },
  keymaps = {
    ["<CR>"] = { desc = "Open (PDF/Office/動画は bin/open)", callback = select_or_open_external, mode = "n" },
    ["T"] = { desc = "Trash (自前 trash)", callback = trash_cursor_entry, mode = "n" },
  },
})

require("oil-git").setup({})

-- 保存確認ダイアログ (oil_preview は確認専用 filetype) で <CR> も [Y]es 扱いに。
-- confirm はローカルクロージャで直接呼べないため、プラグインが張る y→confirm へ
-- <CR> を remap で乗せる (y に加えて Enter で確定)。
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil_preview",
  callback = function(args)
    vim.keymap.set("n", "<CR>", "y", { buffer = args.buf, remap = true, nowait = true })
  end,
})

-- sd: 共有 101_mapping.vim の `:e {dir}` は oil の directory-buffer hijack +
-- async rename で稀に "Invalid buffer id" クラッシュを起こすため、oil 環境では
-- oil.open() で上書きする。101_mapping.vim は pm(本 config)より後に source
-- されるため、VimEnter で遅延登録して上書きを勝たせる。
-- ※ :Oil は count=true 付き定義なので `:Oil 20260805-102817_foo` の先頭数字列が
--   count として食われる (=空一覧)。ex コマンドを経由せず API を直接呼ぶこと。
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.keymap.set("n", "sd", function()
      local dir = vim.fn.expand("%") == "" and vim.fn.getcwd() or vim.fn.expand("%:p:h")
      require("oil").open(dir)
    end, { desc = "Open parent dir in oil" })
  end,
})
