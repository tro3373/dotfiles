#!/usr/bin/env bash

# apps/vim/.vim/conf.d/102_funcs.vim の OpenUrlOrFilePathOnCursor が
# `path:行` 形式の参照を解決して開き、指定行へカーソルを置く挙動のテスト
# (実 nvim headless)。
#
# nvim は本体 (g:is_* / g:plug) 依存を持つため、最小スタブ harness.vim を先に
# source してから 102_funcs.vim を source する。隔離 git repo と note ファイルを
# 用意し、driver.vim が関数を呼んで「開かれた対象 + カーソル行」を probe に書く。
#
# 検証対象 (要件):
#   * 行番号なし : path                          => 1 行目
#   * 単一行     : path:42 / path:+42 / path#L42 => 42 行目
#   * 範囲       : path:42-99 / path#L42-L99     => 開始行 42 (終了行は無視)
#   * 存在しない : 解決できないパスは開かない (ERROR)
#
#   test/nvim-path-open.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
funcs=$(cd "${script_dir}/../apps/vim/.vim/conf.d" && pwd)/102_funcs.vim

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

# g:is_* / g:plug を最小スタブする harness と、関数を駆動する driver を書き出す。
harness="${tmproot}/harness.vim"
cat >"${harness}" <<'VIM'
let g:is_wsl = 0
let g:is_orb = 0
let g:is_windows = 0
let g:is_mac = 0
let g:is_linux = 1
let g:winclip = ''
let g:plug = {}
function! g:plug.is_installed(name) abort
  return 0
endfunction
VIM

driver="${tmproot}/driver.vim"
cat >"${driver}" <<'VIM'
execute 'source ' . $po_harness
execute 'source ' . $po_funcs
execute 'edit ' . fnameescape($po_note)
let g:before = tabpagenr('$')
silent! call OpenUrlOrFilePathOnCursor()
" 1 行目: 開かれたファイルの basename (無ければ ERROR) / 2 行目: カーソル行
if tabpagenr('$') > g:before
  call writefile([fnamemodify(bufname(winbufnr(0)), ':t'), string(line('.'))], $po_out)
else
  call writefile(['ERROR', '0'], $po_out)
endif
qa!
VIM

# 隔離 git repo と、200 行の target.go を用意する。$1=repo 名。
new_repo() {
  local repo="${tmproot}/$1"
  mkdir -p "${repo}/pkg"
  git -C "${repo}" init -q
  seq 200 >"${repo}/pkg/target.go"
  printf '%s' "${repo}"
}

# repo 内 note.md に参照行を置いて関数を駆動し、probe に結果を残す。
_drive() {
  local repo="$1" line="$2"
  printf '%s\n' "${line}" >"${repo}/note.md"
  : >"${probe}"
  po_harness="${harness}" po_funcs="${funcs}" \
    po_note="${repo}/note.md" po_out="${probe}" \
    nvim --headless --clean -S "${driver}" >/dev/null 2>&1
}

# "basename:カーソル行" を返す。
run_case() {
  local repo
  repo=$(new_repo "$1")
  _drive "${repo}" "$2"
  printf '%s:%s' "$(sed -n 1p "${probe}" 2>/dev/null)" "$(sed -n 2p "${probe}" 2>/dev/null)"
}

main() {
  set -euo pipefail

  check '行番号なしは 1 行目' \
    'target.go:1' "$(run_case plain '- pkg/target.go')"

  check ':128 で 128 行目' \
    'target.go:128' "$(run_case colon '- pkg/target.go:128')"

  check ':+128 で 128 行目' \
    'target.go:128' "$(run_case colon_plus '- pkg/target.go:+128')"

  check '#L128 で 128 行目' \
    'target.go:128' "$(run_case hash_l '- pkg/target.go#L128')"

  check ':128-150 で開始行 128' \
    'target.go:128' "$(run_case range_colon '- pkg/target.go:128-150')"

  check '#L128-L150 で開始行 128' \
    'target.go:128' "$(run_case range_hash '- pkg/target.go#L128-L150')"

  check 'Markdownリンク内の :128-150 でも開始行 128' \
    'target.go:128' "$(run_case range_md '- [requests](pkg/target.go:128-150) を参照')"

  check '解決できないパスは開かない' \
    'ERROR:0' "$(run_case missing '- pkg/nope.go:128-150')"

  echo
  echo "pass=${pass} fail=${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
