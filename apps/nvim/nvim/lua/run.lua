-- luacheck: ignore 112 113
-- 現在バッファ(または選択範囲)を非同期実行し、結果を右 vsplit の scratch バッファに表示する。
-- vim 側は vim-quickrun のまま(~/.vim/conf.d/308)。nvim だけ vimproc/QuickRun に依存せず
-- vim.system(nvim ネイティブ非同期)で軽量再実装する。

local M = {}

-- filetype → 実行コマンド + 一時ファイル拡張子。
-- 無名/非ファイルバッファや選択範囲は、バッファ内容を <tempname>.<ext> に書き出して実行する。
local specs = {
  go = { cmd = { "go", "run" }, ext = "go" },
  javascript = { cmd = { "node" }, ext = "js" },
  python = { cmd = { "python3" }, ext = "py" },
  sh = { cmd = { "bash" }, ext = "sh" },
  lua = { cmd = { "lua" }, ext = "lua" },
}

local out_bufname = "[Run]"

-- 出力用 scratch バッファを取得/生成し、非表示なら右 vsplit で開く。
-- フォーカスは呼び出し元(元バッファ)に戻す。戻り値は出力バッファ番号。
local function ensure_output()
  local buf = M.buf
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    buf = vim.api.nvim_create_buf(false, true) -- listed=false, scratch(buftype=nofile)
    vim.bo[buf].bufhidden = "hide"
    pcall(vim.api.nvim_buf_set_name, buf, out_bufname)
    M.buf = buf
  end
  if vim.fn.bufwinid(buf) == -1 then
    local cur = vim.api.nvim_get_current_win()
    vim.cmd("botright vsplit") -- 右端に全高で開く
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_set_current_win(cur)
  end
  return buf
end

local function set_lines(buf, lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

-- CR/CRLF を除去して行配列へ分割し dst に追加する。
local function append_text(dst, s)
  if not s or s == "" then
    return
  end
  vim.list_extend(dst, vim.split((s:gsub("\r", "")), "\n"))
end

-- 実行対象の argv とヘッダ、一時ファイルパス(あれば)を決める。
--   range=nil かつ 名前付き実ファイル → 保存してディスク上のファイルを直接実行(tmp=nil)
--   それ以外(選択範囲 / 無名 / 非ファイル) → バッファ内容を一時ファイルに書いて実行
local function build(spec, range)
  local base = table.concat(spec.cmd, " ")
  local file = vim.api.nvim_buf_get_name(0)
  if not range and file ~= "" and vim.bo.buftype == "" then
    vim.cmd("silent update") -- 変更があれば保存
    local argv = vim.list_extend(vim.deepcopy(spec.cmd), { file })
    return argv, "$ " .. base .. " " .. vim.fn.fnamemodify(file, ":~:."), nil
  end
  local lines = range and vim.api.nvim_buf_get_lines(0, range.line1 - 1, range.line2, false)
    or vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local tmp = vim.fn.tempname() .. "." .. spec.ext
  vim.fn.writefile(lines, tmp)
  local what = range and (range.line1 .. "-" .. range.line2 .. " 行") or "buffer"
  local argv = vim.list_extend(vim.deepcopy(spec.cmd), { tmp })
  return argv, "$ " .. base .. " [" .. what .. "]", tmp
end

-- range = nil(バッファ全体) | { line1, line2 }(選択範囲)
function M.run(range)
  local ft = vim.bo.filetype
  local spec = specs[ft ~= "" and ft or "sh"] -- ft 未設定は bash 扱い
  if not spec then
    vim.notify("[Run] 未対応の filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local argv, header, tmp = build(spec, range)
  local buf = ensure_output()
  set_lines(buf, { header, "", "running..." })

  local start = vim.uv.hrtime()
  vim.system(argv, { text = true }, function(obj)
    local ms = (vim.uv.hrtime() - start) / 1e6
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        local lines = { header, "" }
        append_text(lines, obj.stdout)
        if obj.stderr and obj.stderr ~= "" then
          table.insert(lines, "--- stderr ---")
          append_text(lines, obj.stderr)
        end
        table.insert(lines, ("--- exit %d (%.0f ms) ---"):format(obj.code, ms))
        set_lines(buf, lines)
      end
      if tmp then
        pcall(vim.fn.delete, tmp)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("Run", function(o)
  M.run(o.range ~= 0 and { line1 = o.line1, line2 = o.line2 } or nil)
end, { range = true, desc = "現在バッファ/選択範囲を実行して右 vsplit に表示" })

vim.keymap.set("n", "<Leader>r", "<Cmd>Run<CR>", { silent = true, desc = "Run: 現在バッファを実行" })
vim.keymap.set("x", "<Leader>r", ":Run<CR>", { silent = true, desc = "Run: 選択範囲を実行" })

return M
