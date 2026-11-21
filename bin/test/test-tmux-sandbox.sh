#!/usr/bin/env bash

# bin/tmux-sandbox のテスト (実 tmux 使用)。
# 普段使いの server の代わりに `tmux -S` で外側の server を立て、TMUX をそこへ向けて検証する。
# テスト中の tmux はすべて -S 付きか tmux-sandbox の中で、普段使いの server には触れない。

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

outer() {
  tmux -S "${outer_socket}" "$@"
}

outer_alive() {
  outer has-session -t '=outer' 2>/dev/null && echo 1 || echo 0
}

in_sandbox() {
  TMUX="${outer_socket},${outer_pid},0" TMUX_PANE='%0' "${sandbox_bin}" "$@"
}

test_requires_command() {
  local rc=0
  "${sandbox_bin}" >/dev/null 2>&1 || rc=$?
  check '引数なしは終了コード 2' '2' "${rc}"
}

test_exit_code_passthrough() {
  local rc=0
  in_sandbox bash -c 'exit 7' || rc=$?
  check 'command の終了コードを返す' '7' "${rc}"
}

test_env_inside() {
  local out
  # shellcheck disable=SC2016 # sandbox の中の bash で展開する
  out=$(in_sandbox bash -c 'printf "%s|%s|%s\n" "${TMUX:-unset}" "${TMUX_PANE:-unset}" "$([[ ${TMUX_SANDBOX} == "${TMUX_TMPDIR}" ]] && echo same)"')
  check '中では TMUX と TMUX_PANE が外れ、TMUX_SANDBOX が TMUX_TMPDIR と同じ' 'unset|unset|same' "${out}"
}

test_server_is_isolated() {
  local out
  # shellcheck disable=SC2016 # sandbox の中の bash で展開する
  out=$(in_sandbox bash -c 'tmux new-session -d -s inner "sleep 60"; [[ $(tmux display -p "#{socket_path}") == "${TMUX_SANDBOX}"/* ]] && echo inside')
  check '中の tmux は sandbox の socket に server を立てる' 'inside' "${out}"
  check '中で session を作っても外側の server に session が増えない' 'outer' "$(outer list-sessions -F '#{session_name}')"
}

test_kill_server_stays_inside() {
  in_sandbox bash -c 'tmux new-session -d -s inner "sleep 60"; tmux kill-server'
  check '中の kill-server は外側の server に届かない' '1' "$(outer_alive)"
}

test_cleanup() {
  local out dir pid
  # shellcheck disable=SC2016 # sandbox の中の bash で展開する
  out=$(in_sandbox bash -c 'tmux new-session -d -s inner "sleep 60"; printf "%s %s\n" "${TMUX_SANDBOX}" "$(tmux display -p "#{pid}")"')
  read -r dir pid <<<"${out}"
  check '終了後に sandbox の dir が消える' '0' "$([[ -e ${dir} ]] && echo 1 || echo 0)"
  check '終了後に sandbox の server が落ちる' '0' "$(process_alive_after_grace "${pid}")"
}

# kill-server は server の終了を待たずに返る。
process_alive_after_grace() {
  local pid="$1" _
  for _ in $(seq 20); do
    kill -0 "${pid}" 2>/dev/null || break
    sleep 0.1
  done
  kill -0 "${pid}" 2>/dev/null && echo 1 || echo 0
}

test_inside() {
  local rc=0
  in_sandbox "${sandbox_bin}" --inside || rc=$?
  check '--inside: 中では 0' '0' "${rc}"
  rc=0
  env -u TMUX -u TMUX_SANDBOX "${sandbox_bin}" --inside || rc=$?
  check '--inside: 外では 1' '1' "${rc}"
  rc=0
  TMUX="${outer_socket},${outer_pid},0" TMUX_SANDBOX=/tmp/x TMUX_TMPDIR=/tmp/x "${sandbox_bin}" --inside || rc=$?
  check '--inside: TMUX_SANDBOX が残っていても TMUX があれば 1' '1' "${rc}"
}

main() {
  set -uo pipefail
  local pass=0 fail=0 tmp sandbox_bin outer_socket outer_pid
  sandbox_bin="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/tmux-sandbox"
  tmp=$(mktemp -d /tmp/tmux-sandbox-test.XXXXXX)
  outer_socket="${tmp}/outer.sock"
  # shellcheck disable=SC2064 # local 変数なので定義時に展開する
  trap "tmux -S '${outer_socket}' kill-server 2>/dev/null; rm -rf '${tmp}'" EXIT
  outer new-session -d -s outer 'sleep 600'
  outer_pid=$(outer display -p '#{pid}')

  test_requires_command
  test_exit_code_passthrough
  test_env_inside
  test_server_is_isolated
  test_kill_server_stays_inside
  test_cleanup
  test_inside

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
