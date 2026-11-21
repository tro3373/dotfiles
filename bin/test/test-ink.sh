#!/usr/bin/env bash

# bin/ink のユニットテスト。
#
# 担保したいのは:
#   * 色ごとに ESC [ <色> 本文 ESC [ 0 m を stderr へ 1 行で出す。
#     白と色未指定は ESC [ 0 m で始まる。
#   * 本文のバックスラッシュの並びを制御文字として解釈しない。
#
#   bin/test/test-ink.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && readonly script_dir
target_bin=$(cd "${script_dir}/.." && pwd)/ink && readonly target_bin
readonly esc=$'\033'

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

test_colors() {
  local name code
  while read -r name code; do
    check "${name} は ESC [ ${code}" "${esc}[${code}abc${esc}[0m" "$(echo abc | "${target_bin}" "${name}" 2>&1)"
  done <<'TABLE'
black 0;30m
red 1;31m
green 1;32m
yellow 1;33m
blue 1;34m
purple 1;35m
cyan 1;36m
gray 0;37m
white 0m
TABLE
  check "色未指定の頭は ESC [ 0 m" "${esc}[0mabc${esc}[0m" "$("${target_bin}" abc 2>&1 </dev/null)"
  check "空の第 1 引数は色未指定" "${esc}[0m${esc}[0m" "$("${target_bin}" "" 2>&1 </dev/null)"
  check "引数の本文" "${esc}[1;33ma b${esc}[0m" "$("${target_bin}" yellow a b 2>&1 </dev/null)"
  check "末尾に改行を 1 つ出す" "${esc}[1;31mabc${esc}[0m"$'\n'"." "$(
    echo abc | "${target_bin}" red 2>&1
    echo .
  )"
  check "stdout には出さない" "" "$(echo abc | "${target_bin}" red 2>/dev/null)"
}

test_backslash() {
  check '本文の \c で切れない' "${esc}[1;32ma\\cb${esc}[0m" "$(printf '%s\n' 'a\cb' | "${target_bin}" green 2>&1)"
  check '本文の \016 を制御文字にしない' "${esc}[1;32ma\\016b${esc}[0m" "$(printf '%s\n' 'a\016b' | "${target_bin}" green 2>&1)"
  check '本文の \n を改行にしない' "${esc}[1;32ma\\nb${esc}[0m" "$("${target_bin}" green 'a\nb' 2>&1 </dev/null)"
}

main() {
  set -uo pipefail
  local pass=0 fail=0
  test_colors
  test_backslash
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
