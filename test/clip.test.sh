#!/usr/bin/env bash

# bin/clip のユニットテスト (tmux / pbcopy / wl-copy / xclip を fake に差し替え)。
#
# 担保したいのは、どの経路で clipboard に書くかの選び方。
#
# tmux 内は ssh 先でも tmux load-buffer -w: copy-pipe から呼ばれると /dev/tty が無い為。
# tmux 外の ssh 先は /dev/tty へ OSC52: ssh 先の pbcopy / xclip では手元に届かない為。
# tmux 外の local は pbcopy => wl-copy (Wayland のみ) => xclip の順。
#
#   test/clip.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
clip_bin=$(cd "${script_dir}/../bin" && pwd)/clip

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

make_fake() {
  local name="$1"
  cat >"${fakebin}/${name}" <<EOS
#!/usr/bin/env bash
echo "${name} \$* <\$(cat)" >>"\${calls_log}"
EOS
  chmod +x "${fakebin}/${name}"
}

setup() {
  tmproot=$(mktemp -d)
  fakebin="${tmproot}/bin"
  calls_log="${tmproot}/calls.log"
  tty_file="${tmproot}/tty"
  export calls_log
  sysbin="${tmproot}/sys"
  mkdir -p "${fakebin}" "${sysbin}"
  local name
  # mac の /usr/bin には pbcopy があるので、PATH には clip が使う道具だけを置く
  for name in bash env basename base64 tr cat; do ln -s "$(command -v "${name}")" "${sysbin}/${name}"; done
  for name in tmux pbcopy wl-copy xclip; do make_fake "${name}"; done
}

# 引数で fake を消して (無い環境の再現)、clip に hello を流す
run() {
  local name
  : >"${calls_log}"
  : >"${tty_file}"
  for name in "$@"; do rm -f "${fakebin}/${name}"; done
  printf hello | env -u TMUX -u SSH_CONNECTION -u SSH_TTY -u WAYLAND_DISPLAY \
    "${run_env[@]}" CLIP_TTY="${tty_file}" PATH="${fakebin}:${sysbin}" "${clip_bin}" 2>&1
  cat "${calls_log}" "${tty_file}"
  for name in "$@"; do make_fake "${name}"; done
}

main() {
  pass=0
  fail=0
  setup
  trap 'rm -rf "${tmproot}"' EXIT
  local run_env osc52
  osc52=$(printf '\033]52;c;aGVsbG8=\a')

  run_env=(TMUX=/tmp/x)
  check "tmux 内の local: tmux load-buffer -w" "tmux load-buffer -w - <hello" "$(run)"
  run_env=(TMUX=/tmp/x SSH_CONNECTION=x)
  check "tmux 内の ssh 先: tmux load-buffer -w" "tmux load-buffer -w - <hello" "$(run)"
  run_env=(SSH_CONNECTION=x)
  check "tmux 外の ssh 先: /dev/tty へ OSC52" "${osc52}" "$(run)"
  run_env=(SSH_TTY=/dev/pts/0)
  check "SSH_TTY だけでも ssh 先とみなす" "${osc52}" "$(run)"
  run_env=()
  check "local: pbcopy" "pbcopy  <hello" "$(run)"
  run_env=(WAYLAND_DISPLAY=wayland-0)
  check "local Wayland: wl-copy" "wl-copy  <hello" "$(run pbcopy)"
  run_env=()
  check "local X11: Wayland でなければ wl-copy を使わず xclip" \
    "xclip -selection clipboard <hello" "$(run pbcopy)"
  check "local: コピー手段が無ければエラー" \
    "==> Error: No clipboard command (pbcopy / wl-copy / xclip)." "$(run pbcopy wl-copy xclip)"

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
