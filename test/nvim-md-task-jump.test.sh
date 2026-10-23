#!/usr/bin/env bash

# apps/nvim/nvim/lua/base.lua の <C-n>/<C-p> の markdown 分岐のテスト (実 nvim headless)。
#
# 検証対象 (要件):
#   * markdown で quickfix 窓が無いとき <C-n>/<C-p> は次/前のタスク先頭 (行頭の `- [`) へ移る
#   * サブタスク (字下げ)・チェック無しの `- ` 行・`- [text](url)` のリンク行・見出しは飛ばす
#   * 末尾/先頭では反対端へ回る
#   * 検索レジスタを変えない
#   * quickfix 窓が開いていれば markdown でも quickfix 候補を移動する
#   * markdown 以外ではタスク先頭へ移らない
#
# global.lua + base.lua だけを --clean な nvim に読み込む (lazy.nvim / mason 等を起動しない)。
#
#   test/nvim-md-task-jump.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
conf=$(cd "${script_dir}/../apps/nvim/nvim" && pwd)

tmproot=$(mktemp -d)
trap 'rm -rf "${tmproot}"' EXIT
probe="${tmproot}/probe.txt"

pass=0
fail=0

# desc / expected / actual を比較し、pass・fail カウンタを更新する。
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

# 設定を読み込んで対象ファイルを開き、カーソルを置いてキーを送る (md_col は開始列。既定 0)。
# 移動後の行番号と検索レジスタを probe に書き出す。
# md_qf=1 なら quickfix に 2 件 (2 行目 / 5 行目) を積んで窓を開いておく。
# md_diag=1 なら 6 行目に診断を 1 件置く。
driver="${tmproot}/driver.lua"
cat >"${driver}" <<'LUA'
vim.opt.rtp:prepend(vim.env.md_conf)
require("global")
require("base")
vim.o.wrapscan = false -- 端の回り込みが 'wrapscan' でなく実装で効くことを見る
vim.cmd.edit(vim.fn.fnameescape(vim.env.md_file))
local buf = vim.api.nvim_get_current_buf()
if vim.env.md_qf == "1" then
  vim.fn.setqflist({ { bufnr = buf, lnum = 2 }, { bufnr = buf, lnum = 5 } })
  vim.cmd("copen")
  vim.cmd("wincmd p")
end
if vim.env.md_diag == "1" then
  local ns = vim.api.nvim_create_namespace("md_task_jump_test")
  vim.diagnostic.set(ns, buf, { { lnum = 5, col = 0, message = "x", severity = vim.diagnostic.severity.WARN } })
end
vim.fn.setreg("/", "keep")
vim.api.nvim_win_set_cursor(0, { tonumber(vim.env.md_start), tonumber(vim.env.md_col) })
vim.api.nvim_feedkeys(vim.keycode(vim.env.md_keys), "x", false)
vim.fn.writefile({ tostring(vim.fn.line(".")), vim.fn.getreg("/") }, vim.env.md_out)
vim.cmd("qa!")
LUA

# $1=対象ファイル, $2=開始行, $3=送るキー, $4=quickfix を開くか (1/空), $5=診断を置くか (1/空)。
# 「行番号 検索レジスタ」を返す。nvim 自体が落ちた場合は NVIM_ERROR を返す。
jump() {
  : >"${probe}"
  if ! md_conf="${conf}" md_file="$1" md_start="$2" md_keys="$3" md_qf="${4:-}" md_diag="${5:-}" md_col="${MD_COL:-0}" md_out="${probe}" \
    nvim --headless --clean -l "${driver}" >/dev/null 2>&1; then
    printf 'NVIM_ERROR'
    return
  fi
  paste -sd' ' "${probe}"
}

main() {
  set -euo pipefail

  local md="${tmproot}/tasks.md"
  cat >"${md}" <<'MD'
# title

- [ ] a
  - [ ] sub
  - note
- plain
- [x] b
- [link](https://example.com)
## sec
- [ ] c
MD

  check 'md: <C-n> で次のタスク先頭へ' \
    '3 keep' "$(jump "${md}" 1 '<C-n>')"
  check 'md: <C-n> はサブタスク・チェック無し行を飛ばす' \
    '7 keep' "$(jump "${md}" 3 '<C-n>')"
  check 'md: <C-n> はリンク行・見出しを飛ばす' \
    '10 keep' "$(jump "${md}" 7 '<C-n>')"
  check 'md: <C-p> で前のタスク先頭へ' \
    '3 keep' "$(jump "${md}" 7 '<C-p>')"
  check 'md: 末尾のタスクで <C-n> は先頭のタスクへ回る' \
    '3 keep' "$(jump "${md}" 10 '<C-n>')"
  check 'md: 先頭のタスクで <C-p> は末尾のタスクへ回る' \
    '10 keep' "$(jump "${md}" 3 '<C-p>')"
  check 'md: タスク行の途中から <C-p> で前のタスク先頭へ' \
    '3 keep' "$(MD_COL=4 jump "${md}" 7 '<C-p>')"
  check 'md: 先頭タスクの途中から <C-p> は末尾のタスクへ回る' \
    '10 keep' "$(MD_COL=4 jump "${md}" 3 '<C-p>')"
  check 'md: 末尾タスクの途中から <C-n> は先頭のタスクへ回る' \
    '3 keep' "$(MD_COL=4 jump "${md}" 10 '<C-n>')"
  check 'md: quickfix 窓が開いていれば <C-n> は次の quickfix 候補へ' \
    '5 keep' "$(jump "${md}" 1 '<C-n>' 1)"
  check 'md: 診断があっても <C-n> は診断へ飛ばずタスク先頭へ' \
    '3 keep' "$(jump "${md}" 1 '<C-n>' '' 1)"

  local txt="${tmproot}/tasks.txt"
  cp "${md}" "${txt}"
  check 'md 以外: <C-n> はタスク先頭へ移らない' \
    '1 keep' "$(jump "${txt}" 1 '<C-n>')"
  check 'md 以外: 診断があれば <C-n> は診断へ飛ぶ' \
    '6 keep' "$(jump "${txt}" 1 '<C-n>' '' 1)"

  echo
  echo "pass=${pass} fail=${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
