#!/usr/bin/env bash

# bin/lazy-tmux-wake-all のユニットテスト (実 tmux / 実 lazy-tmux 不要)。
#
# PATH 先頭に偽 lazy-tmux と偽 tmux を差し込む。
#   偽 lazy-tmux: `config show` は tmpdir 配下の data_dir を返し、`list` は
#                 FAKE_LIST の内容を返す。wakeup / forget / bootstrap は
#                 呼び出しを FAKE_CALLS へ追記。
#   偽 tmux     : FAKE_SESSIONS (name/attached/panes/cmd の TSV) を
#                 セッション表として has-session / list-sessions /
#                 display-message / kill-session に答える。kill-session は表から
#                 行を消して FAKE_CALLS へ追記する。attach 中のクライアントは
#                 FAKE_CLIENTS。
# snapshot JSON・git リポジトリ・git 管理外ディレクトリは tmpdir 配下に本物を作る
# (git 管理下かの判定が実物の git な為)。開発者の git 環境に影響されないよう
# 探索の上限とグローバル設定の無効化を先に済ませてある。
#
# 検証対象 (要件):
#   復元/forget
#     * git 管理下のパス            => wakeup、forget しない
#     * pane が複数で 1 つ git 管理 => wakeup
#     * git 管理外のパス            => forget (ディレクトリは存在していても捨てる)
#     * パスが消えている            => forget
#     * 名前が数字だけ              => git 管理下でも forget
#     * 既に起きている              => wakeup も forget もしない
#     * snapshot が壊れている/無い  => forget (復元できない為 index に残さない)
#     * --dry-run                   => lazy-tmux を一切呼ばない
#   --bootstrap
#     * 素のセッションが残る        => bootstrap + kill + forget
#     * pane が 2 つ以上            => kill しない (2 window か 2 pane = 作業中)
#     * pane がシェルでない         => kill しない (claude 等が動いている)
#     * attach されている           => kill しない (bootstrap が移動できていない)
#     * 他にセッションが無い        => kill しない (サーバが死ぬ)
#     * クライアントが居ない        => bootstrap ごと諦める
#     * --bootstrap 無し            => bootstrap も kill もしない
#   --save
#     * 起きていない snapshot       => forget してから save --all
#     * 起きているセッション        => forget しない (save --all が上書きする)
#     * --dry-run                   => lazy-tmux を一切呼ばない
#     * --bootstrap と併用          => 使い方エラー (終了コード 2)
#
#   test/lazy-tmux-wake-all.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target=$(cd "${script_dir}/../bin" && pwd)/lazy-tmux-wake-all

tmproot=$(mktemp -d)
trap 'rm -rf "${tmproot}"' EXIT

# 開発者の設定・上位ディレクトリの .git を拾わせない。
export GIT_CEILING_DIRECTORIES="${tmproot}"
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
# クライアント待ちを 1 tick に潰す (テストを 5 秒待たせない)。
export LAZY_TMUX_WAKE_CLIENT_TICKS=1

pass=0
fail=0

# desc / expected / actual を比較し、pass・fail カウンタを更新する。
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

# テスト用 git。グローバル設定を無効化してあるので identity を毎回渡す。
tgit() {
  git -c user.email=t@example.com -c user.name=t "$@"
}

fakebin="${tmproot}/bin"
datadir="${tmproot}/data"
repo="${tmproot}/repo"
plain="${tmproot}/plain"
gone="${tmproot}/gone-forever"
mkdir -p "${fakebin}" "${datadir}/sessions" "${plain}"
tgit init -q -b main "${repo}"
tgit -C "${repo}" commit -q --allow-empty -m init

cat >"${fakebin}/lazy-tmux" <<'FAKE'
#!/usr/bin/env bash
case "$1" in
  config)
    printf 'data_dir        = "%s"\n' "${FAKE_DATA_DIR}"
    ;;
  list)
    [[ -f ${FAKE_LIST} ]] && cat "${FAKE_LIST}"
    ;;
  bootstrap)
    printf 'bootstrap\n' >>"${FAKE_CALLS}"
    ;;
  save)
    printf 'save %s\n' "$2" >>"${FAKE_CALLS}"
    ;;
  wakeup | forget)
    printf '%s %s\n' "$1" "$3" >>"${FAKE_CALLS}"
    ;;
esac
exit 0
FAKE

cat >"${fakebin}/tmux" <<'FAKE'
#!/usr/bin/env bash
# セッション表: name<TAB>attached<TAB>セッション内の総 pane 数<TAB>pane_current_command
# (総 pane 数は実物の `list-panes -s` の行数に対応する。2 なら 2 window か 2 pane)
sess_line() {
  awk -F'\t' -v n="$1" '$1 == n { print; exit }' "${FAKE_SESSIONS}" 2>/dev/null
}
case "$1" in
  has-session)
    [[ -n $(sess_line "${3#=}") ]] && exit 0
    exit 1
    ;;
  list-sessions)
    # list-sessions [-f '#{==:#{session_name},NAME}'] -F '<format>'
    if [[ $2 == -f ]]; then
      name=${3##*,}
      name=${name%\}}
      sess_line "${name}" | cut -f2
      exit 0
    fi
    cut -f1 "${FAKE_SESSIONS}" 2>/dev/null
    ;;
  list-panes)
    # list-panes -s -t "=NAME" -F '#{pane_current_command}'
    # panes 列の数だけ cmd 列を返す (1 行 = 1 window 1 pane)。
    line=$(sess_line "${4#=}")
    [[ -z ${line} ]] && exit 1
    awk -F'\t' '{ for (i = 0; i < $3; i++) print $4 }' <<<"${line}"
    ;;
  list-clients)
    cat "${FAKE_CLIENTS}" 2>/dev/null
    ;;
  display-message)
    printf 'msg\n' >>"${FAKE_CALLS}"
    ;;
  kill-session)
    name=${3#=}
    printf 'kill %s\n' "${name}" >>"${FAKE_CALLS}"
    awk -F'\t' -v n="${name}" '$1 != n' "${FAKE_SESSIONS}" >"${FAKE_SESSIONS}.new"
    mv "${FAKE_SESSIONS}.new" "${FAKE_SESSIONS}"
    ;;
esac
exit 0
FAKE

chmod +x "${fakebin}/lazy-tmux" "${fakebin}/tmux"

export FAKE_DATA_DIR="${datadir}"
export FAKE_LIST="${tmproot}/list.tsv"
export FAKE_CALLS="${tmproot}/calls.log"
export FAKE_SESSIONS="${tmproot}/sessions.tsv"
export FAKE_CLIENTS="${tmproot}/clients.txt"

# 名前 + pane の作業パス群から snapshot JSON を書き、list へ 1 行足す。
add_snapshot() {
  local name="$1"
  shift
  local paths=("$@") panes='' p
  for p in "${paths[@]}"; do
    [[ -n ${panes} ]] && panes+=','
    panes+="{\"index\":1,\"current_path\":\"${p}\"}"
  done
  cat >"${datadir}/sessions/${name}.json" <<JSON
{"version":1,"session_name":"${name}",
 "windows":[{"index":1,"panes":[${panes}]}]}
JSON
  printf '%s\t2026-08-28T07:07:38+09:00\t1w/1p\n' "${name}" >>"${FAKE_LIST}"
}

# 起動中セッションを 1 つ表へ足す: name attached 総pane数 cmd
add_session() {
  printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" >>"${FAKE_SESSIONS}"
}

# 各テストの前に list / 呼び出しログ / snapshot / セッション表を空へ戻す。
# クライアントは 1 つ attach 済みを既定にする。
reset() {
  : >"${FAKE_LIST}"
  : >"${FAKE_CALLS}"
  : >"${FAKE_SESSIONS}"
  printf '/dev/pts/0\n' >"${FAKE_CLIENTS}"
  rm -f "${datadir}"/sessions/*.json
}

# 対象スクリプトを偽 bin 付き PATH で実行し、stdout/stderr を捨てる。
run_target() {
  PATH="${fakebin}:${PATH}" "${target}" "$@" >/dev/null 2>&1
}

# 呼び出しログを 1 行へ畳む (空なら空文字)。
calls() {
  tr '\n' ';' <"${FAKE_CALLS}"
}

test_wakes_git_path() {
  reset
  add_snapshot repo-session "${repo}"
  run_target
  check 'git path => wakeup' 'wakeup repo-session;' "$(calls)"
}

test_wakes_when_any_pane_is_git() {
  reset
  add_snapshot partial "${plain}" "${repo}"
  run_target
  check 'one pane in git => wakeup' 'wakeup partial;' "$(calls)"
}

test_forgets_non_git_path() {
  reset
  add_snapshot scratch "${plain}"
  run_target
  check 'existing but non-git path => forget' 'forget scratch;' "$(calls)"
}

test_forgets_missing_path() {
  reset
  add_snapshot dead "${gone}"
  run_target
  check 'missing path => forget' 'forget dead;' "$(calls)"
}

test_forgets_auto_named_session() {
  reset
  add_snapshot 25 "${repo}"
  run_target
  check 'numeric name => forget even in git' 'forget 25;' "$(calls)"
}

test_skips_running_session() {
  reset
  add_snapshot running "${gone}"
  add_session running 0 1 zsh
  run_target
  check 'already awake => no call' '' "$(calls)"
}

test_forgets_unreadable_snapshot() {
  reset
  add_snapshot broken "${repo}"
  printf 'not json' >"${datadir}/sessions/broken.json"
  run_target
  check 'unreadable snapshot => forget' 'forget broken;' "$(calls)"
}

test_forgets_missing_snapshot() {
  reset
  add_snapshot ghost "${repo}"
  rm -f "${datadir}/sessions/ghost.json"
  run_target
  check 'missing snapshot => forget' 'forget ghost;' "$(calls)"
}

test_dry_run_calls_nothing() {
  reset
  add_snapshot repo-session "${repo}"
  add_snapshot dead "${gone}"
  run_target --dry-run
  check 'dry-run => no call' '' "$(calls)"
}

test_mixed_batch() {
  reset
  add_snapshot repo-session "${repo}"
  add_snapshot scratch "${plain}"
  add_snapshot 0 "${repo}"
  add_snapshot running "${repo}"
  add_session running 0 1 zsh
  run_target
  check 'mixed batch' 'wakeup repo-session;forget scratch;forget 0;' "$(calls)"
}

test_bootstrap_kills_leftover() {
  reset
  add_session 0 0 1 zsh
  add_session mo 1 1 zsh
  run_target --bootstrap
  check 'leftover => bootstrap + kill + forget' 'bootstrap;kill 0;forget 0;' "$(calls)"
}

test_bootstrap_keeps_multi_pane_leftover() {
  reset
  add_session 0 0 2 zsh
  add_session mo 1 1 zsh
  run_target --bootstrap
  check '2 panes => keep' 'bootstrap;' "$(calls)"
}

test_bootstrap_keeps_non_shell_leftover() {
  reset
  add_session 0 0 1 claude
  add_session mo 1 1 zsh
  run_target --bootstrap
  check 'non-shell pane => keep' 'bootstrap;' "$(calls)"
}

test_bootstrap_keeps_attached_leftover() {
  reset
  add_session 0 1 1 zsh
  add_session mo 0 1 zsh
  run_target --bootstrap
  check 'attached => keep' 'bootstrap;' "$(calls)"
}

test_bootstrap_keeps_last_session() {
  reset
  add_session 0 0 1 zsh
  run_target --bootstrap
  check 'only session => keep' 'bootstrap;' "$(calls)"
}

test_bootstrap_without_client() {
  reset
  : >"${FAKE_CLIENTS}"
  add_session 0 0 1 zsh
  add_session mo 0 1 zsh
  run_target --bootstrap
  check 'no client => skip bootstrap' '' "$(calls)"
}

test_no_bootstrap_flag() {
  reset
  add_session 0 0 1 zsh
  add_session mo 1 1 zsh
  run_target
  check 'without --bootstrap => nothing' '' "$(calls)"
}

test_save_forgets_stale_then_saves() {
  reset
  add_snapshot repo-session "${repo}"
  add_snapshot dead "${gone}"
  run_target --save
  check 'save => forget stale then save --all' 'forget repo-session;forget dead;save --all;msg;' "$(calls)"
}

test_save_keeps_running_snapshot() {
  reset
  add_snapshot running "${repo}"
  add_snapshot dead "${gone}"
  add_session running 1 1 zsh
  run_target --save
  check 'save => keep running snapshot' 'forget dead;save --all;msg;' "$(calls)"
}

test_save_dry_run_calls_nothing() {
  reset
  add_snapshot dead "${gone}"
  run_target --save --dry-run
  check 'save --dry-run => no call' '' "$(calls)"
}

test_save_with_bootstrap_is_usage_error() {
  reset
  local rc=0
  run_target --save --bootstrap || rc=$?
  check 'save + bootstrap => exit 2' '2' "${rc}"
  check 'save + bootstrap => no call' '' "$(calls)"
}

main() {
  test_wakes_git_path
  test_wakes_when_any_pane_is_git
  test_forgets_non_git_path
  test_forgets_missing_path
  test_forgets_auto_named_session
  test_skips_running_session
  test_forgets_unreadable_snapshot
  test_forgets_missing_snapshot
  test_dry_run_calls_nothing
  test_mixed_batch

  test_bootstrap_kills_leftover
  test_bootstrap_keeps_multi_pane_leftover
  test_bootstrap_keeps_non_shell_leftover
  test_bootstrap_keeps_attached_leftover
  test_bootstrap_keeps_last_session
  test_bootstrap_without_client
  test_no_bootstrap_flag

  test_save_forgets_stale_then_saves
  test_save_keeps_running_snapshot
  test_save_dry_run_calls_nothing
  test_save_with_bootstrap_is_usage_error

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
