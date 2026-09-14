#!/usr/bin/env bash

# bin/clean-ssh-sockets のユニットテスト (ssh を fake に差し替え、HOME を tmp へ)。
#
# 担保したいのは:
#   * 生きている master は `ssh -O exit` で止める: ソケットだけ消すと master が
#     ControlPersist の間残り続ける。
#   * pattern で対象を絞れる / 省略時は全件。
#   * dry-run は何も消さない。
#
#   test/clean-ssh-sockets.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target_bin=$(cd "${script_dir}/../bin" && pwd)/clean-ssh-sockets

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

# ssh の偽物。呼ばれた引数を ${LOG} へ記録し、master の終了を模してソケットを消す。
new_fakebin() {
  fakebin="${tmproot}/bin"
  # lint-ignore: uppercase fake ssh が env 経由で参照する
  LOG="${tmproot}/calls.log"
  mkdir -p "${fakebin}"
  cat >"${fakebin}/ssh" <<'EOS'
#!/usr/bin/env bash
echo "ssh $*" >>"${LOG}"
rm -f "$2"
EOS
  chmod +x "${fakebin}/ssh"
  export LOG
}

# HOME/.ssh/socks にダミーのソケットを作り直す。
setup_socks() {
  rm -rf "${tmproot:?}/home"
  socks="${tmproot}/home/.ssh/socks"
  mkdir -p "${socks}"
  touch "${socks}/mux-user@alpha:22" "${socks}/mux-user@beta:22" "${socks}/mux-root@alpha2:2222"
  : >"${LOG}"
}

run_target() {
  HOME="${tmproot}/home" PATH="${fakebin}:${PATH}" "${target_bin}" "$@" >/dev/null 2>&1
}

remaining() {
  find "${socks}" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort | paste -sd,
}

# 1. 引数なしは全件を ssh -O exit した上で消す。
test_all() {
  setup_socks
  run_target
  check '引数なしは全件消す' '' "$(remaining)"
  check '全件に ssh -O exit を投げる' '3' "$(grep -c -- '-O exit' "${LOG}")"
}

# 2. pattern に部分一致したものだけ消す。
test_pattern() {
  setup_socks
  run_target alpha
  check 'pattern 一致のみ消す' 'mux-user@beta:22' "$(remaining)"
}

# 3. dry-run は消さないし ssh も呼ばない。
test_dry_run() {
  setup_socks
  run_target -n
  check 'dry-run は消さない' 'mux-root@alpha2:2222,mux-user@alpha:22,mux-user@beta:22' "$(remaining)"
  check 'dry-run は ssh を呼ばない' '0' "$(grep -c . "${LOG}")"
}

# 4. master が死んでいて ssh が失敗しても残ったソケットを消す。
test_stale_socket() {
  setup_socks
  printf '#!/usr/bin/env bash\nexit 255\n' >"${fakebin}/ssh"
  run_target beta
  check 'stale ソケットも消す' 'mux-root@alpha2:2222,mux-user@alpha:22' "$(remaining)"
  new_fakebin
}

# 5. ソケットディレクトリが無くても正常終了する。
test_no_dir() {
  rm -rf "${tmproot:?}/home"
  run_target
  check 'ディレクトリ無しは exit 0' '0' "$?"
}

main() {
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  pass=0
  fail=0
  new_fakebin

  test_all
  test_pattern
  test_dry_run
  test_stale_socket
  test_no_dir

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
