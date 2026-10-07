#!/usr/bin/env bash

# bin/chrome-profile のユニットテスト。HOME を差し替え、偽の Local State を引かせる。
#
#   test/chrome-profile.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target_bin=$(cd "${script_dir}/../bin" && pwd)/chrome-profile

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

# 未ログインのプロファイル (user_name が空・欠落) も混ぜる。
# 前方一致の対象から黙って外れることを見るため。
write_local_state() {
  mkdir -p "${tmproot}/.config/google-chrome"
  cat >"${tmproot}/.config/google-chrome/Local State" <<'EOS'
{"profile":{"info_cache":{
  "Default":{"user_name":""},
  "Profile 1":{},
  "Profile 2":{"user_name":"alice@example.com"},
  "Profile 3":{"user_name":"alice@example.org"},
  "Profile 4":{"user_name":"bob@example.com"}
}}}
EOS
}

run() {
  HOME=${tmproot} OSTYPE=linux-gnu "${target_bin}" "$@"
}

test_exact_match() {
  check "完全一致で 1 件" "Profile 4" "$(run bob@example.com)"
}

test_prefix_returns_all_matches() {
  check "前方一致は該当を全件返す" $'Profile 2\nProfile 3' "$(run alice@)"
}

test_no_match_exits_1() {
  local out rc
  out=$(run carol@)
  rc=$?
  check "該当なしは何も出さない" "" "${out}"
  check "該当なしは exit 1" "1" "${rc}"
}

test_missing_arg_exits_2() {
  run >/dev/null 2>&1
  check "引数なしは exit 2" "2" "$?"
}

main() {
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  pass=0
  fail=0
  write_local_state

  test_exact_match
  test_prefix_returns_all_matches
  test_no_match_exits_1
  test_missing_arg_exits_2

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
