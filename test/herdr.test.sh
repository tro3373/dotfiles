#!/usr/bin/env bash

# bin/herdr のユニットテスト (本体 herdr と ghostty / setsid を fake に差し替え)。
#
# 担保したいのは 2 つ。
#
# tmux 上の UI 起動だけ ghostty へ逃がす: prefix C-a が tmux と被る為。
#   逃がす時は TMUX を外して渡す (残すと ghostty 内の zsh が tmux 内と誤認する)。
#
# それ以外は本体へ素通し: pane / api 等のサブコマンドは tmux 上の agent からも叩く。
#
#   test/herdr.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
herdr_bin=$(cd "${script_dir}/../bin" && pwd)/herdr

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
  tmproot=$(mktemp -d)
  fakebin="${tmproot}/bin"
  calls_log="${tmproot}/calls.log"
  export calls_log
  mkdir -p "${fakebin}"
  cat >"${fakebin}/herdr" <<'EOS'
#!/usr/bin/env bash
echo "herdr $*" >>"${calls_log}"
EOS
  cat >"${fakebin}/ghostty" <<'EOS'
#!/usr/bin/env bash
echo "ghostty TMUX=${TMUX:-} $*" >>"${calls_log}"
EOS
  # setsid -f は fork して即返るので、テストでは同期実行にする
  cat >"${fakebin}/setsid" <<'EOS'
#!/usr/bin/env bash
[[ $1 == -f ]] && shift
"$@"
EOS
  chmod +x "${fakebin}"/*
}

run() {
  : >"${calls_log}"
  PATH="$(dirname "${herdr_bin}"):${fakebin}:/usr/bin:/bin" "${herdr_bin}" "$@"
  sed "s|${fakebin}/||g" "${calls_log}"
}

main() {
  pass=0
  fail=0
  setup
  trap 'rm -rf "${tmproot}"' EXIT

  check "tmux 外: UI 起動は本体へ" "herdr " "$(TMUX='' run)"
  check "tmux 上: UI 起動は TMUX を外して ghostty へ" \
    "ghostty TMUX= -e herdr" "$(TMUX=/tmp/x run)"
  check "tmux 上: --session も ghostty へ" \
    "ghostty TMUX= -e herdr --session foo" "$(TMUX=/tmp/x run --session foo)"
  check "tmux 上: session attach も ghostty へ" \
    "ghostty TMUX= -e herdr session attach foo" "$(TMUX=/tmp/x run session attach foo)"
  check "tmux 上: サブコマンドは本体へ" "herdr pane list" "$(TMUX=/tmp/x run pane list)"
  check "tmux 上: --version は本体へ" "herdr --version" "$(TMUX=/tmp/x run --version)"

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
