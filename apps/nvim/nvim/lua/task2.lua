-- luacheck: ignore 112 113
-- :Task2Add - index.md に書いたブロック (`- [ ]` の行と、その下の字下げした行) を task2-add で task2 のタスクにする。
--   範囲あり (:'<,'>Task2Add): 保存してから、選んだ行範囲にかかるブロックを add する
--   範囲なし (:Task2Add): task2-add の fzf でブロックを選ぶ
-- task2-add は新しいタブの端末で動かす。fzf と LLM の待ちとエラーを見せるため。
-- 終わったら index.md を読み直す (task2-add が add したブロックを消し、task2 が一覧を作り直す)。
-- エラーは通知に加えて stdpath("log")/task2.log に、cwd・buffer・index・範囲と一緒に追記する。

local M = {}

-- cwd の repo の index.md のパス。引けなければ nil と理由
local function where_index()
  local r = vim.system({ "task2", "where" }, { text = true }):wait()
  if r.code ~= 0 then
    return nil, vim.trim(r.stderr or "")
  end
  local ok, where = pcall(vim.json.decode, r.stdout)
  if not ok or type(where) ~= "table" or type(where.index) ~= "string" then
    return nil, "task2 where の JSON に index が無い"
  end
  return where.index
end

local function real_path(path)
  return vim.fn.resolve(vim.fn.fnamemodify(path, ":p"))
end

-- path を開いている読み込み済みの buffer ごとに fn(buf) を呼ぶ
local function each_buf_of(path, fn)
  local want = real_path(path)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.api.nvim_buf_is_loaded(buf) and name ~= "" and real_path(name) == want then
      fn(buf)
    end
  end
end

-- path を開いている buffer を読み直す。編集中の buffer は checktime が確かめる
local function reload(path)
  each_buf_of(path, function(buf)
    vim.cmd.checktime(buf)
  end)
end

-- task2-add はディスクの index.md を読むので、編集中の中身を先に書き出す。
-- 書き出さないと、取り込んで消したブロックが buffer の保存で戻る
local function save(path)
  each_buf_of(path, function(buf)
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent update")
    end)
  end)
end

local log_path = vim.fs.joinpath(vim.fn.stdpath("log"), "task2.log")

-- 赤文字の通知は消えるので、原因を後から追えるよう同じ内容と ctx をログにも残す
local function notify_error(msg, ctx)
  local entry = { os.date("%Y-%m-%d %H:%M:%S") .. " [Task2Add] " .. msg }
  for _, k in ipairs({ "cwd", "buffer", "buffer_real", "index", "range", "argv", "stale" }) do
    if ctx[k] then
      table.insert(entry, "  " .. k .. ": " .. ctx[k])
    end
  end
  vim.fn.mkdir(vim.fs.dirname(log_path), "p")
  vim.fn.writefile(entry, log_path, "a")
  vim.notify("[Task2Add] " .. msg .. " (詳細: " .. log_path .. ")", vim.log.levels.ERROR)
end

-- buffer とディスクの食い違いの要約。行数と、最初に違う行
local function stale_summary(buf_lines, disk_lines)
  local first = 0
  for i = 1, math.max(#buf_lines, #disk_lines) do
    if buf_lines[i] ~= disk_lines[i] then
      first = i
      break
    end
  end
  return ("buffer %d 行 / disk %d 行 / 最初に違う行 %d"):format(#buf_lines, #disk_lines, first)
end

-- range = nil (fzf で選ぶ) | { line1, line2 } (今の buffer の行範囲。buffer は index.md)
function M.add(range)
  local name = vim.api.nvim_buf_get_name(0)
  local ctx = {
    cwd = vim.fn.getcwd(),
    buffer = name,
    buffer_real = name ~= "" and real_path(name) or nil,
    range = range and (range.line1 .. "," .. range.line2) or "(なし)",
  }
  local index, err = where_index()
  if not index then
    notify_error(err, ctx)
    return
  end
  ctx.index = index
  -- task2-add はディスク上の index.md の行番号で読むので、別のファイルの行を渡さない
  if range and ctx.buffer_real ~= real_path(index) then
    notify_error("index.md の行を選んで打つ: " .. index, ctx)
    return
  end
  save(index)
  local argv = { "task2-add" }
  if range then
    -- 他の task2 が一覧を作り直したのに読み直していない buffer の行番号は、ディスクでは別の行を指す
    local buf_lines, disk_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false), vim.fn.readfile(index)
    if not vim.deep_equal(buf_lines, disk_lines) then
      ctx.stale = stale_summary(buf_lines, disk_lines)
      vim.cmd.checktime(vim.api.nvim_get_current_buf())
      notify_error("index.md が外で書き換えられていた。読み直したので選び直す", ctx)
      return
    end
    vim.list_extend(argv, { "--lines", ctx.range })
  end
  ctx.argv = table.concat(argv, " ")
  vim.cmd.tabnew()
  local term = vim.api.nvim_get_current_buf()
  vim.bo[term].bufhidden = "wipe"
  vim.fn.jobstart(argv, {
    term = true,
    on_exit = function(_, code)
      reload(index)
      -- 失敗したらエラーを読めるようにタブを残す
      if code ~= 0 then
        notify_error(
          "task2-add が終了コード " .. code .. " で終わった。端末のタブに出力が残る",
          ctx
        )
        return
      end
      if vim.api.nvim_buf_is_valid(term) then
        vim.api.nvim_buf_delete(term, { force = true })
      end
    end,
  })
  vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Task2Add", function(o)
  M.add(o.range ~= 0 and { line1 = o.line1, line2 = o.line2 } or nil)
end, { range = true, desc = "index.md のブロックを task2 のタスクにする (範囲なしは fzf で選ぶ)" })

return M
