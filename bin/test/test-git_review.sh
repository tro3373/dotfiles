#!/usr/bin/env bash

# bin/git_review のユニットテスト (実 git 使用)。
# fzf と対話 shell は偽物に差し替える:
#   * 偽 fzf   : stdin の行のうち、第 1 フィールドが FAKE_FZF_PICK に一致する行を返す。
#                無ければ中断扱い (exit 1)
#   * 偽 SHELL : worktree 内の状態を FAKE_SHELL_LOG へ書いて終わる。
#                FAKE_SHELL_EDIT=1 ならファイルを 1 つ編集する
#
#   bin/test/test-git_review.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bin=$(cd "${script_dir}/.." && pwd)/git_review

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

# main: A - B、feature: B - C (f を変更、g を追加)。feature を checkout した状態。
new_repo() {
  repo="${tmproot}/repo"
  rm -rf "${repo}"
  mkdir -p "${repo}"
  git -C "${repo}" init -q -b main
  git -C "${repo}" config user.email t@t
  git -C "${repo}" config user.name t
  local c
  for c in A B; do
    echo "${c}" >"${repo}/f"
    git -C "${repo}" add -A
    git -C "${repo}" commit -qm "commit ${c}"
  done
  git -C "${repo}" checkout -q -b feature
  echo C >"${repo}/f"
  echo G >"${repo}/g"
  git -C "${repo}" add -A
  git -C "${repo}" commit -qm 'commit C'
  : >"${log}"
}

setup_fakes() {
  fakebin="${tmproot}/fakebin"
  mkdir -p "${fakebin}"
  cat >"${fakebin}/fzf" <<'FAKE'
#!/usr/bin/env bash
rows=$(cat)
pick=${FAKE_FZF_PICK:-}
[[ -z $pick ]] && exit 1
while IFS=$'\t' read -r f1 rest; do
  [[ $f1 == "$pick" ]] && { printf '%s\t%s\n' "$f1" "$rest"; exit 0; }
done <<<"$rows"
exit 1
FAKE
  fake_shell="${fakebin}/fake_shell"
  cat >"${fake_shell}" <<'FAKE'
#!/usr/bin/env bash
{
  echo "pwd=$PWD"
  echo "head=$(git log -1 --format=%s)"
  echo "status=$(git status --porcelain | tr '\n' ' ')"
} >"$FAKE_SHELL_LOG"
[[ ${FAKE_SHELL_EDIT:-} == 1 ]] && echo edited >g
# セッション内で grr (元の HEAD = feature の先頭へ) => gre をやり直す。
if [[ -n ${FAKE_SHELL_REDO:-} ]]; then
  "$GIT_RESET" -r "$(git rev-parse feature)" >/dev/null 2>&1
  echo "after_grr=$(git log -1 --format=%s)" >>"$FAKE_SHELL_LOG"
  "$GIT_RESET" 1 >/dev/null 2>&1
  echo "after_gre=$(git log -1 --format=%s)" >>"$FAKE_SHELL_LOG"
fi
exit 0
FAKE
  chmod +x "${fakebin}/fzf" "${fake_shell}"
}

# git_review を repo 内で実行する。stdin は $1 (削除確認への回答)。
run() {
  local answer="$1"
  shift
  (cd "${repo}" && printf '%s' "${answer}" |
    PATH="${fakebin}:${PATH}" SHELL="${fake_shell}" TMPDIR="${tmproot}" \
      FAKE_SHELL_LOG="${log}" GIT_RESET="${script_dir}/../git_reset" "${bin}" "$@")
}

worktree_count() { git -C "${repo}" worktree list | wc -l; }
log_value() { sed -n "s/^$1=//p" "${log}"; }
base_hash() { git -C "${repo}" rev-parse main; }

test_review_shows_branch_change_as_unstaged() {
  new_repo
  FAKE_FZF_PICK="$(base_hash)" run '' >/dev/null 2>&1
  check 'review: shell は worktree で起動' 'review-repo-feature.' "$(basename "$(log_value pwd)" | sed 's/....$//')"
  check 'review: worktree の HEAD はベース' 'commit B' "$(log_value head)"
  check 'review: 変更が unstaged で見える' ' M f ?? g ' "$(log_value status)"
  check 'review: exit 後に worktree 削除' '1' "$(worktree_count)"
  check 'review: worktree のディレクトリも消える' 'no' "$([[ -e $(log_value pwd) ]] && echo yes || echo no)"
  check 'review: 元の repo の HEAD は動かない' 'commit C' "$(git -C "${repo}" log -1 --format=%s)"
  check 'review: 元の repo の作業ツリーは clean' '' "$(git -C "${repo}" status --porcelain)"
}

test_count_is_passed_to_git_reset() {
  new_repo
  run '' 1 >/dev/null 2>&1
  check '件数指定: gre 1 と同じく 1 commit 戻す' 'commit B' "$(log_value head)"
  check '件数指定: exit 後に worktree 削除' '1' "$(worktree_count)"
}

test_grr_and_gre_repeat_in_session() {
  new_repo
  FAKE_SHELL_REDO=1 FAKE_FZF_PICK="$(base_hash)" run '' >/dev/null 2>&1
  check 'セッション内 grr: 元の HEAD へ戻る' 'commit C' "$(log_value after_grr)"
  check 'セッション内 gre: 選び直して戻せる' 'commit B' "$(log_value after_gre)"
  check 'セッション内 gre/grr: exit 後に worktree 削除' '1' "$(worktree_count)"
}

test_base_abort_removes_worktree() {
  new_repo
  FAKE_FZF_PICK='' run '' >/dev/null 2>&1
  check 'ベース中断: shell を起動しない' '' "$(cat "${log}")"
  check 'ベース中断: worktree 削除' '1' "$(worktree_count)"
}

test_edited_keeps_worktree_unless_confirmed() {
  new_repo
  FAKE_SHELL_EDIT=1 FAKE_FZF_PICK="$(base_hash)" run '' >/dev/null 2>&1
  check '編集あり + 回答なし: worktree を残す' '2' "$(worktree_count)"
  git -C "${repo}" worktree remove --force "$(log_value pwd)"

  FAKE_SHELL_EDIT=1 FAKE_FZF_PICK="$(base_hash)" run 'y' >/dev/null 2>&1
  check '編集あり + y: worktree 削除' '1' "$(worktree_count)"
}

test_invalid_argument_removes_worktree() {
  new_repo
  local rc=0
  run '' 1 2 >/dev/null 2>&1 || rc=$?
  check '不正な引数: git_reset が失敗' '1' "${rc}"
  check '不正な引数: worktree 削除' '1' "$(worktree_count)"
}

main() {
  set -uo pipefail
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  log="${tmproot}/shell.log"
  setup_fakes
  local pass=0 fail=0

  test_review_shows_branch_change_as_unstaged
  test_count_is_passed_to_git_reset
  test_grr_and_gre_repeat_in_session
  test_base_abort_removes_worktree
  test_edited_keeps_worktree_unless_confirmed
  test_invalid_argument_removes_worktree

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
