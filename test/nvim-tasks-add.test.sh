#!/usr/bin/env bash

# apps/nvim/nvim/lua/tasks.lua の :TasksAdd のテスト (実 nvim headless。tasks と tasks-add は fake)。
#
# 検証対象 (要件):
#   * 範囲を選んで :TasksAdd => 保存してから、選んだ行範囲を tasks-add --lines に渡し、終わったら index.md を読み直す
#   * 範囲なしの :TasksAdd => tasks-add を引数なしで端末 (stdin が tty) で開き、終わったら index.md を読み直す
#   * 範囲を選んだ buffer が tasks where の index.md でなければ tasks-add を呼ばない
#   * 範囲なしでも、編集中の index.md を保存してから tasks-add を呼ぶ
#   * 範囲ありで buffer がディスクと違えば (外で書き換えられた)、tasks-add を呼ばずに読み直す
#   * tasks-add が失敗したら端末のタブを残す (エラーを読めるように)
#   * エラーは stdpath("log")/tasks.log に、理由と cwd・buffer・index・範囲を追記する
#
# tasks.lua だけを --clean な nvim に読み込む (lazy.nvim / mason 等を起動しない)。
#
#   test/nvim-tasks-add.test.sh   # 全テスト実行

check() {
  local desc="$1" expected="$2" actual="$3"
  if [[ ${expected} != "${actual}" ]]; then
    fail=$((fail + 1))
    printf 'FAIL - %s\n  expected: %q\n  actual:   %q\n' "${desc}" "${expected}" "${actual}"
    return
  fi
  pass=$((pass + 1))
  printf 'ok   - %s\n' "${desc}"
}

setup() {
  local script_dir
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  conf=$(cd "${script_dir}/../apps/nvim/nvim" && pwd)
  tmproot=$(mktemp -d)
  fakebin="${tmproot}/bin"
  index="${tmproot}/store/repo/index.md"
  other="${tmproot}/other.md"
  probe="${tmproot}/probe.txt"
  t2a_args="${tmproot}/t2a.args"
  t2a_tty="${tmproot}/t2a.tty"
  t2a_seen="${tmproot}/t2a.seen"
  # XDG_STATE_HOME を tmproot に向けるので、stdpath("log") はここになる
  log="${tmproot}/state/nvim/tasks.log"
  mkdir -p "${fakebin}" "$(dirname "${index}")"
  # tasks の fake: where だけに答え、index.md のパスを JSON で出す
  cat >"${fakebin}/tasks" <<EOS
#!/usr/bin/env bash
[[ \$1 == where ]] || exit 2
printf '{"place":"main","index":"%s"}\n' "${index}"
EOS
  # tasks-add の fake: 引数・stdin が端末か・起動したときの index.md を残し、ブロックを消した体で 2 行目を消す
  cat >"${fakebin}/tasks-add" <<EOS
#!/usr/bin/env bash
echo "\$*" >"${t2a_args}"
[[ -t 0 ]] && echo tty >"${t2a_tty}" || echo notty >"${t2a_tty}"
cp "${index}" "${t2a_seen}"
sed -i 2d "${index}"
exit "\${FAKE_T2A_EXIT:-0}"
EOS
  chmod +x "${fakebin}/tasks" "${fakebin}/tasks-add"

  # 対象を開き、md_edit があれば 1 行目をその文字に書き換え (保存しない)、md_cmd を打つ。
  # 端末の job の終わりを待ち、「buffer の中身 (| 区切り)」「タブの数」を probe に書き出す
  driver="${tmproot}/driver.lua"
  cat >"${driver}" <<'LUA'
vim.opt.rtp:prepend(vim.env.md_conf)
-- headless の -l では ERROR の通知が例外になり、端末の job の on_exit から投げると driver が止まる
vim.notify = function() end
require("tasks")
vim.cmd.edit(vim.fn.fnameescape(vim.env.md_file))
local buf = vim.api.nvim_get_current_buf()
local edit = vim.env.md_edit
if edit and edit ~= "" then
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { edit })
end
-- md_shift=1: 開いた後に、他の tasks が一覧を作り直した体でディスクの先頭へ行を足す
if vim.env.md_shift == "1" then
  local disk = vim.fn.readfile(vim.env.md_file)
  table.insert(disk, 1, "- ⬜ [後から足されたタスク](x/task.md)")
  vim.fn.writefile(disk, vim.env.md_file)
end
pcall(vim.cmd, vim.env.md_cmd)
for _, b in ipairs(vim.api.nvim_list_bufs()) do
  local job = vim.b[b].terminal_job_id
  if job then
    vim.fn.jobwait({ job }, 5000)
  end
end
vim.wait(200)
local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
vim.fn.writefile({ table.concat(lines, "|"), tostring(#vim.api.nvim_list_tabpages()) }, vim.env.md_out)
vim.cmd("qa!")
LUA
}

reset() {
  printf '%s\n' '- [ ] a' '  - a の詳細' '- [ ] b' >"${index}"
  printf '%s\n' '- [ ] x' '  - y' >"${other}"
  rm -f "${probe}" "${t2a_args}" "${t2a_tty}" "${t2a_seen}" "${log}"
}

# $1=開くファイル, $2=打つ Ex コマンド, $3=保存せずに 1 行目へ書く文字 (空なら書かない)。
# probe の 1 行目 (buffer の中身) を buffer に、2 行目 (タブの数) を tabs に入れる
run() {
  reset
  PATH="${fakebin}:${PATH}" md_conf="${conf}" md_file="$1" md_cmd="$2" md_edit="${3:-}" md_out="${probe}" \
    md_shift="${MD_SHIFT:-}" XDG_STATE_HOME="${tmproot}/state" nvim --headless --clean -l "${driver}" >/dev/null 2>&1
  buffer=$(sed -n 1p "${probe}" 2>/dev/null)
  tabs=$(sed -n 2p "${probe}" 2>/dev/null)
}

read_or_none() {
  cat "$1" 2>/dev/null || echo none
}

test_range_passes_lines() {
  run "${index}" '2,3TasksAdd'
  check 'range: 選んだ行範囲を tasks-add --lines に渡す' '--lines 2,3' "$(read_or_none "${t2a_args}")"
  check 'range: 終わったら index.md を読み直す' '- [ ] a|- [ ] b' "${buffer}"
  check 'range: 成功したら端末のタブを閉じる' '1' "${tabs}"
}

test_range_saves_buffer_first() {
  run "${index}" '1,1TasksAdd' '- [ ] 書き換えた a'
  check 'range-save: tasks-add を呼ぶ前に、編集中の buffer を保存する' \
    $'- [ ] 書き換えた a\n  - a の詳細\n- [ ] b' "$(read_or_none "${t2a_seen}")"
}

test_no_range_opens_fzf() {
  run "${index}" 'TasksAdd'
  check 'no-range: tasks-add を引数なしで呼ぶ' '' "$(read_or_none "${t2a_args}")"
  check 'no-range: tasks-add の stdin を端末にする (fzf を開く)' 'tty' "$(read_or_none "${t2a_tty}")"
  check 'no-range: 終わったら index.md を読み直す' '- [ ] a|- [ ] b' "${buffer}"
}

test_no_range_saves_buffer_first() {
  run "${index}" 'TasksAdd' '- [ ] 書き換えた a'
  check 'no-range-save: 範囲なしでも、tasks-add を呼ぶ前に編集中の index.md を保存する' \
    $'- [ ] 書き換えた a\n  - a の詳細\n- [ ] b' "$(read_or_none "${t2a_seen}")"
}

test_range_on_stale_buffer() {
  MD_SHIFT=1 run "${index}" '2,3TasksAdd'
  check 'stale: buffer がディスクと違えば tasks-add を呼ばない' 'none' "$(read_or_none "${t2a_args}")"
  check 'stale: ログに buffer とディスクの食い違いを書く' 'stale: buffer 3 行 / disk 4 行 / 最初に違う行 1' \
    "$(grep -o 'stale: .*' "${log}" 2>/dev/null)"
  check 'stale: ディスクの中身を読み直す' '- ⬜ [後から足されたタスク](x/task.md)|- [ ] a|  - a の詳細|- [ ] b' "${buffer}"
}

test_range_on_other_file() {
  run "${other}" '1,2TasksAdd'
  check 'other: 範囲を選んだ buffer が index.md でなければ tasks-add を呼ばない' 'none' "$(read_or_none "${t2a_args}")"
  check 'other: buffer を変えない' '- [ ] x|  - y' "${buffer}"
  check 'other: ログに理由・buffer・index・範囲を書く' \
    $'[TasksAdd] index.md の行を選んで打つ: '"${index}"$'\n  buffer: '"${other}"$'\n  index: '"${index}"$'\n  range: 1,2' \
    "$(sed -E '1s/^[0-9: -]+ //' "${log}" 2>/dev/null | grep -v -e '^  cwd: ' -e '^  buffer_real: ')"
}

test_failure_keeps_terminal() {
  FAKE_T2A_EXIT=1 run "${index}" '2,3TasksAdd'
  check 'failed: tasks-add が失敗したら端末のタブを残す' '2' "${tabs}"
  check 'failed: ログに終了コードと argv を書く' $'終了コード 1\n  argv: tasks-add --lines 2,3' \
    "$(grep -o -e '終了コード [0-9]*' -e '  argv: .*' "${log}" 2>/dev/null)"
}

test_success_writes_no_log() {
  run "${index}" '2,3TasksAdd'
  check 'success: 成功したらログを書かない' 'none' "$(read_or_none "${log}")"
}

main() {
  set -uo pipefail
  setup
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0

  test_range_passes_lines
  test_range_saves_buffer_first
  test_no_range_opens_fzf
  test_no_range_saves_buffer_first
  test_range_on_stale_buffer
  test_range_on_other_file
  test_failure_keeps_terminal
  test_success_writes_no_log

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
