#!/usr/bin/env bash

# bin/wad のユニットテスト (sudo/systemctl/iptables/waydroid を fake に差し替え)。
#
# 検証対象は allow_forward。Docker が filter FORWARD を policy DROP にすると
# waydroid 側の nft (inet lxc) が accept しても後段で落ちて Android が無通信になる。
# DOCKER-USER へ accept を挿すのがその回避で、ここで担保したいのは:
#   * container が既に active でも挿す: unit は enabled で再起動後は自動起動済み。
#     一方 iptables の rule は再起動で消えるので、起動処理を skip した経路でも
#     通らないと「再起動したら無通信」が直らない (回帰テスト)。
#   * 冪等: 既に rule があれば挿さない。wad は毎回呼ばれるので重複が積み上がる。
#   * Docker 未使用なら何もしない: DOCKER-USER chain が無い環境で失敗しない。
#
#   test/wad.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
wad_bin=$(cd "${script_dir}/../bin" && pwd)/wad

# desc / expected / actual を比較し、main の pass・fail カウンタを更新する。
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

# sudo / systemctl / iptables / waydroid の偽物を用意する。挙動は FAKE_* env で
# 切り替え、呼ばれた引数は ${LOG} へ追記して検証する。
new_fakebin() {
  fakebin="${tmproot}/bin"
  LOG="${tmproot}/calls.log"
  mkdir -p "${fakebin}"

  # sudo は iptables のみ PATH 上の偽物へ委譲する。他 (systemctl start,
  # show_cert の waydroid 呼び出し) は記録だけして成功で返す。
  cat >"${fakebin}/sudo" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == iptables ]]; then
  shift
  exec iptables "$@"
fi
echo "sudo $*" >>"${LOG}"
EOS

  cat >"${fakebin}/systemctl" <<'EOS'
#!/usr/bin/env bash
echo "systemctl $*" >>"${LOG}"
[[ $1 == is-active ]] || exit 0
[[ ${FAKE_UNIT_ACTIVE} == 1 ]]
EOS

  # -S: chain の存在確認 (Docker 有無)。-C: rule の存在確認 (冪等性)。
  cat >"${fakebin}/iptables" <<'EOS'
#!/usr/bin/env bash
echo "iptables $*" >>"${LOG}"
case $1 in
  -S) [[ ${FAKE_HAS_DOCKER_USER} == 1 ]] ;;
  -C) [[ ${FAKE_RULE_EXISTS} == 1 ]] ;;
  *) exit 0 ;;
esac
EOS

  # wad は `/usr/bin/python3 $waydroid_bin` で呼ぶ (asdf shim 回避) 為、偽物も
  # python で書く。空文字の引数を潰さないよう記録は | 区切りにする。
  fake_waydroid="${tmproot}/waydroid.py"
  cat >"${fake_waydroid}" <<'EOS'
#!/usr/bin/env python3
import os
import sys

args = sys.argv[1:]
with open(os.environ["LOG"], "a") as f:
    f.write("|".join(args) + "\n")
EOS

  chmod +x "${fakebin}"/sudo "${fakebin}"/systemctl "${fakebin}"/iptables "${fake_waydroid}"
  export LOG
}

# fakebin 経由で wad を実行し、終了コードを返す。
run_wad() {
  : >"${LOG}"
  PATH="${fakebin}:${PATH}" WAD_WAYDROID_BIN="${fake_waydroid}" \
    "${wad_bin}" "$@" >/dev/null 2>&1
}

# ${LOG} から $1 に一致した行数を数える。$1 は BRE なので `|` は区切り文字の
# ままリテラル扱いになる。
count_log() {
  grep -c -- "$1" "${LOG}" || true
}

# 1. 既に active でも DOCKER-USER へ挿す (再起動後に効かせる為の回帰テスト)。
#    cert は container_up を通る最短経路。
test_inserts_when_container_already_active() {
  export FAKE_UNIT_ACTIVE=1 FAKE_HAS_DOCKER_USER=1 FAKE_RULE_EXISTS=0
  run_wad cert

  check 'active でも -i の accept を挿す' '1' \
    "$(count_log 'iptables -I DOCKER-USER -i waydroid0 -j ACCEPT')"
  check 'active でも -o の accept を挿す' '1' \
    "$(count_log 'iptables -I DOCKER-USER -o waydroid0 -j ACCEPT')"
  check 'active なら container は起動しない' '0' \
    "$(count_log 'sudo systemctl start')"
}

# 2. rule が既にあれば挿さない (毎回呼ばれるので重複が積み上がる)。
test_idempotent_when_rule_exists() {
  export FAKE_UNIT_ACTIVE=1 FAKE_HAS_DOCKER_USER=1 FAKE_RULE_EXISTS=1
  run_wad cert

  check '既存 rule があれば -I しない' '0' "$(count_log 'iptables -I')"
  check '存在確認の -C は 2 方向分だけ走る' '2' "$(count_log 'iptables -C')"
}

# 3. Docker 未使用なら DOCKER-USER chain が無い。触らず正常終了する。
test_noop_without_docker() {
  export FAKE_UNIT_ACTIVE=1 FAKE_HAS_DOCKER_USER=0 FAKE_RULE_EXISTS=0
  run_wad cert

  check 'chain が無ければ -C しない' '0' "$(count_log 'iptables -C')"
  check 'chain が無ければ -I しない' '0' "$(count_log 'iptables -I')"
}

# 4. inactive なら container を起こした上で挿す。
test_starts_container_then_inserts() {
  export FAKE_UNIT_ACTIVE=0 FAKE_HAS_DOCKER_USER=1 FAKE_RULE_EXISTS=0
  run_wad cert

  check 'inactive なら container を起動する' '1' \
    "$(count_log 'sudo systemctl start waydroid-container.service')"
  check '起動後も accept を 2 方向挿す' '2' "$(count_log 'iptables -I')"
}

main() {
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  pass=0
  fail=0
  new_fakebin

  test_inserts_when_container_already_active
  test_idempotent_when_rule_exists
  test_noop_without_docker
  test_starts_container_then_inserts

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
