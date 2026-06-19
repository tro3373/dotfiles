#!/usr/bin/env bash

# bin/tmuxs のイベントエントリ (`tmuxs waiting|running|idle|remove`) のユニットテスト。
# PATH 先頭の偽 tmux が mutating 呼び出しをログ + 一時ファイルに記録し、query
# (show -gv / list-panes) を一時ファイル・env で答えるので実 tmux を触らない。
# run_hook は兄弟 tmuxs のイベントエントリを偽 tmux 経由で別プロセス起動して検証する。
#
#   bin/tmuxs_test.sh   # 全テスト実行 (実 tmux 不要)

# tmpdir 配下に偽 tmux を生成し、$PATH 先頭に差し込む。
# 偽 tmux の状態 (@tmuxs_waiting option 等) は FAKE_STATE_DIR 配下に永続化し、
# hook の複数回起動 (別プロセス) 間でも tmux server のように状態を共有する。
setup_fake_tmux() {
  fakebin="${tmpdir}/bin"
  mkdir -p "${fakebin}"
  export FAKE_TMUX_LOG="${tmpdir}/calls.log"
  export FAKE_STATE_DIR="${tmpdir}/tmuxstate"
  mkdir -p "${FAKE_STATE_DIR}"
  write_fake_tmux
  chmod +x "${fakebin}/tmux"
}

write_fake_tmux() {
  cat >"${fakebin}/tmux" <<'FAKE'
#!/usr/bin/env bash
log=${FAKE_TMUX_LOG:?}
state=${FAKE_STATE_DIR:?}
case "$1" in
  list-panes) printf '%s\n' "${FAKE_PANES:-}" | grep -v '^$' || true ;;
  show)
    cat "${state}/${3#@}" 2>/dev/null || true
    ;;
  set)
    if [[ $2 == -gu ]]; then
      rm -f "${state}/${3#@}"
      printf 'set %s %s\n' "$2" "$3" >>"${log}"
    else
      printf '%s' "$4" >"${state}/${3#@}"
      printf 'set %s %s %s\n' "$2" "$3" "$4" >>"${log}"
    fi
    ;;
  *) printf 'UNHANDLED %s\n' "$*" >>"${log}" ;;
esac
FAKE
}

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

# イベントエントリ (`tmuxs <state>`) を fakebin 経由で別プロセス起動する。
run_hook() {
  PATH="${fakebin}:${PATH}" "${self}" "$@"
}

# 各テスト前の共通リセット。マーカー・偽 tmux 状態・ログ・pane env を初期化する。
reset() {
  rm -f "${TMUXS_MARKER_DIR}"/* 2>/dev/null || true
  rm -f "${FAKE_STATE_DIR}"/* 2>/dev/null || true
  # tmux.conf 相当: 通常 status-style を seed (band_on がこれを退避し band_off で復元)。
  printf 'bg=colour234,fg=blue,default' >"${FAKE_STATE_DIR}/status-style"
  : >"${FAKE_TMUX_LOG}"
  export TMUX_PANE='%5' TMUX='fake' FAKE_PANES='%5'
}

marker_content() {
  cat "${TMUXS_MARKER_DIR}/$1" 2>/dev/null || printf '__NONE__'
}

# tmux user option (@tmuxs_*) の現在値。未設定は __NONE__。
opt() {
  cat "${FAKE_STATE_DIR}/${1#@}" 2>/dev/null || printf '__NONE__'
}

# 1. tmux 外 (TMUX_PANE 未設定) では何もしない (no-op)。
test_no_op_outside_tmux() {
  reset
  unset TMUX_PANE
  run_hook waiting
  check 'tmux 外: マーカーを書かない' '__NONE__' "$(marker_content '%5')"
}

# 2. 各状態でマーカー内容が正しく書かれる。
test_marker_states() {
  reset
  run_hook running
  check 'running: マーカー内容 running' 'running' "$(marker_content '%5')"
  run_hook idle
  check 'idle: マーカー内容 idle' 'idle' "$(marker_content '%5')"
  run_hook waiting
  check 'waiting: マーカー内容 waiting' 'waiting' "$(marker_content '%5')"
}

# 3. remove はマーカーを削除する。
test_remove_deletes_marker() {
  reset
  run_hook idle
  run_hook remove
  check 'remove: マーカー削除' '__NONE__' "$(marker_content '%5')"
}

# 4. waiting -> running の遷移で待ち表示枠を点灯後に消灯する。
test_indicator_set_then_cleared() {
  reset

  run_hook waiting
  check 'waiting: @tmuxs_waiting に ⏳1 を点灯' yes \
    "$(opt @tmuxs_waiting | grep -q '⏳1' && echo yes || echo no)"

  run_hook running
  check 'running(waiting 解消): @tmuxs_waiting を消灯 (unset)' \
    '__NONE__' "$(opt @tmuxs_waiting)"
}

# 5. waiting 非関与の遷移 (running) では待ち表示枠に触れない (tmux IPC 抑制)。
test_indicator_untouched_without_waiting() {
  reset
  run_hook running
  check 'running(waiting 非関与): @tmuxs_waiting への set を発行しない' \
    '' "$(grep '@tmuxs_waiting' "${FAKE_TMUX_LOG}" || true)"
}

# 6. 複数 pane が waiting なら件数 N を点灯する。
test_indicator_counts_multiple() {
  reset
  export FAKE_PANES=$'%5\n%6'
  printf 'waiting' >"${TMUXS_MARKER_DIR}/%6" # 別 pane が既に waiting
  run_hook waiting                           # 自分 %5 も waiting => 計 2
  check '複数 waiting: @tmuxs_waiting に ⏳2' yes \
    "$(opt @tmuxs_waiting | grep -q '⏳2' && echo yes || echo no)"
}

# 7. 黄色帯モード ON (band_enabled=1): waiting で @tmuxs_band=1 + status-style を黄色帯へ
#    直接上書きし、解消で @tmuxs_band unset + 通常 status-style へ復元する。
test_band_set_then_cleared() {
  reset

  run_hook waiting
  check 'waiting(band ON): @tmuxs_band=1 を設定' '1' "$(opt @tmuxs_band)"
  check 'waiting(band ON): status-style を黄色帯へ直接上書き' \
    'bg=#4B607F,fg=#000000' "$(opt status-style)"

  run_hook running
  check 'running(waiting 解消): @tmuxs_band を unset' \
    '__NONE__' "$(opt @tmuxs_band)"
  check 'running(waiting 解消): status-style を通常へ復元' \
    'bg=colour234,fg=blue,default' "$(opt status-style)"
}

# 8. 退避元 status-style が空文字でも band ON->OFF で黄色が残らない (番兵で判定)。
test_band_empty_style_restore() {
  reset
  : >"${FAKE_STATE_DIR}/status-style" # 空 style 環境を再現

  run_hook waiting
  check 'band/empty: status-style を黄色帯へ' \
    'bg=#4B607F,fg=#000000' "$(opt status-style)"

  run_hook running
  check 'band/empty 解消: 空 style へ復元 (黄色が残らない)' \
    '' "$(opt status-style)"
}

run_tests() {
  set -uo pipefail

  local self tmpdir
  self=$(realpath "$(dirname "${BASH_SOURCE[0]}")/tmuxs")
  [[ -x $self ]] || {
    printf 'error: tmuxs が見つからない: %s\n' "$self" >&2
    exit 1
  }
  tmpdir=$(mktemp -d)
  # shellcheck disable=SC2064 # local 変数を EXIT 時に確実に消すため定義時に展開する
  trap "rm -rf '${tmpdir}'" EXIT

  export TMUXS_MARKER_DIR="${tmpdir}/markers"
  mkdir -p "${TMUXS_MARKER_DIR}"

  local fakebin
  setup_fake_tmux

  local pass=0 fail=0

  test_no_op_outside_tmux
  test_marker_states
  test_remove_deletes_marker
  test_indicator_set_then_cleared
  test_indicator_untouched_without_waiting
  test_indicator_counts_multiple
  test_band_set_then_cleared
  test_band_empty_style_restore

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  run_tests
fi
