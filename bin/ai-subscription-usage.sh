#!/usr/bin/env bash
#
# ai-subscription-usage.sh
#   Claude Code と OpenAI Codex の公式 CLI 表示から、
#   使用量とリセット時刻の画面をそのまま標準出力へ出す。
#
#   - Claude: work_dir で `claude -p "/usage"` を実行し、出力をそのまま返す
#   - Codex : 専用 socket の使い捨て tmux セッションで codex を起動し、
#             /status を送って `capture-pane -p -J` の画面を返す
#
#   どちらかが読めなければ、値を作らずに stderr へエラーを出し、終了コード 1 を返す。
#
# 使い方:
#   ai-subscription-usage.sh

readonly work_dir="${HOME}"/.dot
readonly claude_bin="${HOME}"/.local/bin/claude
readonly codex_bin="${HOME}"/.npm-global/bin/codex
readonly pane_width=160
readonly pane_height=50
readonly ready_timeout_sec=30
readonly status_timeout_sec=30
# codex の入力欄の行頭記号。表示が変わると起動待ちが timeout する。
readonly codex_prompt_pattern='^› '
# /status 画面の rate limit 行。表示が変わると取得失敗として扱う。
readonly codex_status_pattern='^ *(5h|Weekly) limit:'

err() { echo "ai-subscription-usage: $*" >&2; }

run_claude() {
  echo "===== Claude Code (/usage) ====="
  local out
  out=$(cd "${work_dir}" && DISABLE_AUTOUPDATER=1 "${claude_bin}" -p "/usage") || {
    err "claude -p /usage が失敗した (exit $?)"
    return 1
  }
  if [[ -z ${out//[[:space:]]/} ]]; then
    err "claude -p /usage の出力が空"
    return 1
  fi
  printf '%s\n' "${out}"
}

# 自分専用の server だけを相手にする。利用者の tmux server・設定には触れない。
t() { command tmux -S "${tmux_sock}" -f /dev/null "$@"; }

capture() { t capture-pane -p -J -t "${session}" 2>/dev/null; }

# $1: 正規表現, $2: 秒。画面に一致する行が出るまで待つ。
wait_screen() {
  local pattern=$1 limit=$2 i
  for ((i = 0; i < limit * 2; i++)); do
    capture | grep -Eq "${pattern}" && return 0
    sleep 0.5
  done
  return 1
}

cleanup_tmux() {
  t kill-server >/dev/null 2>&1
  # kill-server 後も socket ファイルが残ることがある。自分で作った一時 dir だけを消す。
  rm -f "${tmux_sock}"
  rmdir "${tmux_dir}" 2>/dev/null
  return 0
}

run_codex() {
  echo "===== OpenAI Codex (/status) ====="
  tmux_dir=$(mktemp -d -t ai-usage-tmux.XXXXXX) || {
    err "tmux 用の一時 dir を作れない"
    return 1
  }
  tmux_sock="${tmux_dir}/sock"
  session="ai-usage-$$-$(date +%s)"
  trap cleanup_tmux EXIT

  # command を 2 引数以上で渡すと tmux は shell を介さず直接 exec する (対話 zsh を起動しない)。
  t new-session -d -s "${session}" -x "${pane_width}" -y "${pane_height}" \
    -c "${work_dir}" /usr/bin/env "${codex_bin}" -c check_for_update_on_startup=false \; \
    set-option -t "${session}" remain-on-exit on || {
    err "tmux セッションを起動できない"
    return 1
  }

  wait_screen "${codex_prompt_pattern}" "${ready_timeout_sec}" || {
    err "codex の入力欄が ${ready_timeout_sec} 秒以内に出ない。最後の画面:"
    capture >&2
    return 1
  }

  t send-keys -t "${session}" -l "/status"
  sleep 0.5
  t send-keys -t "${session}" Enter

  wait_screen "${codex_status_pattern}" "${status_timeout_sec}" || {
    err "codex /status の rate limit 行が ${status_timeout_sec} 秒以内に出ない。最後の画面:"
    capture >&2
    return 1
  }
  # 行が出た直後は描画途中のことがあるため、少し待ってから確定の画面を取る。
  sleep 1
  capture
}

main() {
  set -uo pipefail
  local rc=0
  run_claude || rc=1
  echo
  run_codex || rc=1
  return "${rc}"
}
main "$@"
