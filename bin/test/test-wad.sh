#!/usr/bin/env bash

# bin/wad のユニットテスト (sudo/systemctl/iptables/waydroid を fake に差し替え)。
#
# 検証対象は 2 つ。
#
# allow_forward: Docker が filter FORWARD を policy DROP にすると waydroid 側の
# nft (inet lxc) が accept しても後段で落ちて Android が無通信になる。DOCKER-USER
# へ accept を挿すのがその回避で、ここで担保したいのは:
#   * container が既に active でも挿す: unit は enabled で再起動後は自動起動済み。
#     一方 iptables の rule は再起動で消えるので、起動処理を skip した経路でも
#     通らないと「再起動したら無通信」が直らない (回帰テスト)。
#   * 冪等: 既に rule があれば挿さない。wad は毎回呼ばれるので重複が積み上がる。
#   * Docker 未使用なら何もしない: DOCKER-USER chain が無い環境で失敗しない。
#
# size: waydroid の prop get/set は session 停止中でもエラーを表示するだけで
# exit 0 を返す。設定できていないのに成功したように見えるのが一番まずいので、
# session 停止中は prop を触らず落ちることを担保する。

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
wad_bin=$(cd "${script_dir}/.." && pwd)/wad

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

# sudo / systemctl / iptables / waydroid の偽物を用意する。挙動は fake_* env で
# 切り替え、呼ばれた引数は ${log} へ追記して検証する。
new_fakebin() {
  fakebin="${tmproot}/bin"
  log="${tmproot}/calls.log"
  mkdir -p "${fakebin}"

  # sudo は iptables のみ PATH 上の偽物へ委譲する。他 (systemctl start,
  # show_cert の waydroid 呼び出し) は記録だけして成功で返す。
  cat >"${fakebin}/sudo" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == iptables ]]; then
  shift
  exec iptables "$@"
fi
echo "sudo $*" >>"${log}"
EOS

  cat >"${fakebin}/systemctl" <<'EOS'
#!/usr/bin/env bash
echo "systemctl $*" >>"${log}"
[[ $1 != is-active ]] && exit 0
[[ ${fake_unit_active} == 1 ]]
EOS

  # -S: chain の存在確認 (Docker 有無)。-C: rule の存在確認 (冪等性)。
  cat >"${fakebin}/iptables" <<'EOS'
#!/usr/bin/env bash
echo "iptables $*" >>"${log}"
case $1 in
  -S) [[ ${fake_has_docker_user} == 1 ]] ;;
  -C) [[ ${fake_rule_exists} == 1 ]] ;;
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
with open(os.environ["log"], "a") as f:
    f.write("|".join(args) + "\n")

if args[:1] == ["status"]:
    print("Session:\t" + os.environ.get("fake_session", "RUNNING"))
    print("Container:\tRUNNING")
elif args[:2] == ["prop", "get"]:
    value = os.environ.get("fake_" + args[2].split(".")[-1].lower(), "")
    if value:
        print(value)
EOS

  chmod +x "${fakebin}"/sudo "${fakebin}"/systemctl "${fakebin}"/iptables "${fake_waydroid}"
  export log
}

# fakebin 経由で wad を実行し、終了コードを返す。
run_wad() {
  : >"${log}"
  PATH="${fakebin}:${PATH}" WAD_WAYDROID_BIN="${fake_waydroid}" \
    "${wad_bin}" "$@" >"${tmproot}/wad.out" 2>&1
}

# ${log} から $1 に一致した行数を数える。$1 は BRE なので `|` は区切り文字の
# ままリテラル扱いになり、末尾の値が空であることを `|$` で表現できる。
count_log() {
  grep -c -- "$1" "${log}" || true
}

# --- allow_forward ---------------------------------------------------------

# 1. 既に active でも DOCKER-USER へ挿す (再起動後に効かせる為の回帰テスト)。
#    cert は container_up を通る最短経路。
test_inserts_when_container_already_active() {
  export fake_unit_active=1 fake_has_docker_user=1 fake_rule_exists=0
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
  export fake_unit_active=1 fake_has_docker_user=1 fake_rule_exists=1
  run_wad cert

  check '既存 rule があれば -I しない' '0' "$(count_log 'iptables -I')"
  check '存在確認の -C は 2 方向分だけ走る' '2' "$(count_log 'iptables -C')"
}

# 3. Docker 未使用なら DOCKER-USER chain が無い。触らず正常終了する。
test_noop_without_docker() {
  export fake_unit_active=1 fake_has_docker_user=0 fake_rule_exists=0
  run_wad cert

  check 'chain が無ければ -C しない' '0' "$(count_log 'iptables -C')"
  check 'chain が無ければ -I しない' '0' "$(count_log 'iptables -I')"
}

# 4. inactive なら container を起こした上で挿す。
test_starts_container_then_inserts() {
  export fake_unit_active=0 fake_has_docker_user=1 fake_rule_exists=0
  run_wad cert

  check 'inactive なら container を起動する' '1' \
    "$(count_log 'sudo systemctl start waydroid-container.service')"
  check '起動後も accept を 2 方向挿す' '2' "$(count_log 'iptables -I')"
}

# --- size ------------------------------------------------------------------

# 5. phone preset は Pixel 10 Pro の縦横比 (484x1080) を prop に書く。
test_size_phone_preset() {
  export fake_session=RUNNING
  run_wad size phone

  check 'phone は width=484' '1' "$(count_log 'prop|set|persist.waydroid.width|484')"
  check 'phone は height=1080' '1' "$(count_log 'prop|set|persist.waydroid.height|1080')"
}

# 6. tablet preset は両辺を空にする。空 = 既定 (ディスプレイ依存) 復帰。
#    空文字を渡せていないと既定に戻らないので、値が空であることまで見る。
test_size_tablet_clears_props() {
  export fake_session=RUNNING
  run_wad size tablet

  check 'tablet は width を空にする' '1' "$(count_log 'prop|set|persist.waydroid.width|$')"
  check 'tablet は height を空にする' '1' "$(count_log 'prop|set|persist.waydroid.height|$')"
}

# 7. preset 名でなく <w>x<h> を直接渡せる。
test_size_accepts_explicit_geometry() {
  export fake_session=RUNNING
  run_wad size 720x1606

  check '任意指定の width' '1' "$(count_log 'prop|set|persist.waydroid.width|720')"
  check '任意指定の height' '1' "$(count_log 'prop|set|persist.waydroid.height|1606')"
}

# 8. 不正な指定は prop を触らずエラー終了する。
test_size_rejects_invalid_spec() {
  export fake_session=RUNNING
  run_wad size 480
  local rc=$?

  check '不正指定は非ゼロ終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check '不正指定では prop set しない' '0' "$(count_log 'prop|set')"
}

# 9. session 停止中は prop を触らず落ちる。waydroid の prop set は停止中でも
#    exit 0 を返す為、ここを通すと「設定したのに反映されない」を警告なしに作る。
test_size_fails_loud_when_session_stopped() {
  export fake_session=STOPPED
  run_wad size phone
  local rc=$?

  check 'session 停止中は非ゼロ終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check 'session 停止中は prop set しない' '0' "$(count_log 'prop|set')"
}

# 10. 引数なしは現在値を読むだけで書き換えない。
test_size_without_arg_only_reads() {
  export fake_session=RUNNING fake_width=484 fake_height=1080
  run_wad size

  check '現在値は prop get で読む' '2' "$(count_log 'prop|get')"
  check '読むだけで prop set しない' '0' "$(count_log 'prop|set')"
  check '読んだ現在値を表示する' '1' "$(grep -c -- 'size: 484x1080' "${tmproot}/wad.out")"
  unset fake_width fake_height
}

# 11. book preset は紙の判型 (1:√2) を prop に書く。値そのものより比が本質で、
#     ここが崩れると kshot の PDF が紙と違う縦横比のページになる。
test_size_book_preset() {
  export fake_session=RUNNING
  run_wad size book

  check 'book は width=764' '1' "$(count_log 'prop|set|persist.waydroid.width|764')"
  check 'book は height=1080' '1' "$(count_log 'prop|set|persist.waydroid.height|1080')"
  check 'book の縦横比は 1:√2 (誤差 1% 未満)' '1' \
    "$(awk 'BEGIN { print (((1080 / 764) / sqrt(2)) - 1 < 0.01) ? 1 : 0 }')"
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
  test_size_phone_preset
  test_size_tablet_clears_props
  test_size_accepts_explicit_geometry
  test_size_rejects_invalid_spec
  test_size_fails_loud_when_session_stopped
  test_size_without_arg_only_reads
  test_size_book_preset

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
