#!/usr/bin/env bash

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

g() {
  git -C "$1" -c user.email=t@t -c user.name=t "${@:2}"
}

commit() {
  echo "$2" >"$1/${2//\//_}"
  g "$1" add -A
  g "$1" commit -qm "$2"
}

branch_off_main() {
  g "${repo}" checkout -q -b "$1" main
  commit "${repo}" "$1"
  g "${repo}" checkout -q main
}

write_prs() {
  local zero_oid='0000000000000000000000000000000000000000'
  cat >"${root}/prs.json" <<EOF
[
  {"number": 1, "title": "all green", "headRefName": "pr/pass", "headRefOid": "${zero_oid}", "baseRefName": "main",
   "statusCheckRollup": [
     {"__typename": "CheckRun", "status": "COMPLETED", "conclusion": "SUCCESS"},
     {"__typename": "StatusContext", "state": "SUCCESS"}]},
  {"number": 2, "title": "failed beats pending", "headRefName": "pr/fail", "headRefOid": "${zero_oid}", "baseRefName": "main",
   "statusCheckRollup": [
     {"__typename": "CheckRun", "status": "IN_PROGRESS", "conclusion": ""},
     {"__typename": "CheckRun", "status": "COMPLETED", "conclusion": "FAILURE"}]},
  {"number": 3, "title": "running", "headRefName": "pr/pend", "headRefOid": "${zero_oid}", "baseRefName": "main",
   "statusCheckRollup": [{"__typename": "CheckRun", "status": "IN_PROGRESS", "conclusion": ""}]},
  {"number": 4, "title": "no checks", "headRefName": "pr/none", "headRefOid": "${zero_oid}", "baseRefName": "main",
   "statusCheckRollup": []},
  {"number": 5, "title": "context expected", "headRefName": "pr/expected", "headRefOid": "${zero_oid}", "baseRefName": "main",
   "statusCheckRollup": [{"__typename": "StatusContext", "state": "EXPECTED"}]},
  {"number": 6, "title": "context error", "headRefName": "pr/error", "headRefOid": "${zero_oid}", "baseRefName": "main",
   "statusCheckRollup": [{"__typename": "StatusContext", "state": "ERROR"}]},
  {"number": 7, "title": "has worktree", "headRefName": "pr/feat", "headRefOid": "${pr_oid}", "baseRefName": "main",
   "statusCheckRollup": [{"__typename": "CheckRun", "status": "COMPLETED", "conclusion": "SUCCESS"}]},
  {"number": 8, "title": "also local", "headRefName": "feat/both", "headRefOid": "${zero_oid}", "baseRefName": "main",
   "statusCheckRollup": [{"__typename": "CheckRun", "status": "COMPLETED", "conclusion": "TIMED_OUT"}]}
]
EOF
}

setup() {
  root="${tmp}/$1"
  origin="${root}/origin.git"
  repo="${root}/repo"
  other="${root}/other"
  mkdir -p "${root}"
  git init -q --bare -b main "${origin}"
  git init -q -b main "${repo}"
  commit "${repo}" init
  g "${repo}" remote add origin "${origin}"
  g "${repo}" push -q -u origin main
  git clone -q "${origin}" "${other}"
  g "${other}" checkout -q -b pr/feat main
  commit "${other}" pr-feat
  g "${other}" push -q origin pr/feat
  g "${repo}" fetch -q
  g "${repo}" branch -q --track pr/feat origin/pr/feat
  g "${repo}" worktree add -q "${repo}-worktree/pr-feat" pr/feat
  local b
  for b in feat/local feat/wt feat/both removed/old; do
    branch_off_main "${b}"
  done
  g "${repo}" worktree add -q "${repo}-worktree/feat-wt" feat/wt
  pr_oid=$(g "${repo}" rev-parse pr/feat)
  write_prs
  # lint-ignore: uppercase fake の gh が読む環境変数
  export GH_PRS="${root}/prs.json" GH_LOG="${root}/gh.log" GH_ORIGIN="${origin}" GH_LIST_LOG="${root}/gh-list.log"
  unset GH_PR_STATE TASKS_JSON TASKS_FAIL
}

run_merge() {
  (cd "${repo}" && "${bin}" "$@" 2>"${root}/err")
}

branches() {
  g "${repo}" branch --format '%(refname:short)' | sort | paste -sd ' '
}

remote_branches() {
  g "${origin}" branch --format '%(refname:short)' | sort | paste -sd ' '
}

worktrees() {
  g "${repo}" worktree list --porcelain | sed -n 's#^branch refs/heads/##p' | sort | paste -sd ' '
}

exists() {
  [[ -e $1 ]] && echo 1 || echo 0
}

pick() {
  printf '%s\t%s\t%s\t' "$1" "$2" "${3:-}"
}

offered_keys() {
  cut -f1-3 "${root}/fzf.in" | tr '\t' ' ' | sed 's/ $//'
}

offer() {
  FZF_PICK='^$' FZF_LOG="${root}/fzf.in" run_merge >/dev/null
}

test_list() {
  setup list
  offer
  check "PR の行 (fixture の順) の後ろにローカルの行。PR と同名の local・removed/*・今の branch は出ない" \
    "pr pr/pass 1
pr pr/fail 2
pr pr/pend 3
pr pr/none 4
pr pr/expected 5
pr pr/error 6
pr pr/feat 7
pr feat/both 8
local feat/local
local feat/wt" "$(offered_keys)"
  check "表示: PR は icon・番号・CI・branch・title、ローカルは icon・branch。worktree の branch に印" \
    "${icon_pr} #1 ${icon_ci_passed} pr/pass all green
${icon_pr} #2 ${icon_ci_failed} pr/fail failed beats pending
${icon_pr} #3 ${icon_ci_pending} pr/pend running
${icon_pr} #4 - pr/none no checks
${icon_pr} #5 ${icon_ci_pending} pr/expected context expected
${icon_pr} #6 ${icon_ci_failed} pr/error context error
${icon_pr} #7 ${icon_ci_passed} pr/feat has worktree ${icon_worktree}
${icon_pr} #8 ${icon_ci_failed} feat/both also local
${icon_local} feat/local
${icon_local} feat/wt ${icon_worktree}" "$(cut -f4 "${root}/fzf.in")"
}

test_list_gh_failure() {
  setup ghfail
  GH_FAIL=1 offer
  check "gh pr list が失敗したらローカルの行だけを出し、警告する" \
    "local feat/both|local feat/local|local feat/wt|local pr/feat|1" "$(offered_keys | paste -sd '|')|$(grep -c 'gh pr list に失敗' "${root}/err")"
}

test_list_without_remote() {
  setup noremote
  g "${repo}" remote remove origin
  offer
  check "remote が無ければ gh を呼ばずローカルの行だけを出す" \
    "local feat/both|local feat/local|local feat/wt|local pr/feat|0" \
    "$(cut -f1,2 "${root}/fzf.in" | tr '\t' ' ' | paste -sd '|')|$(exists "${GH_LIST_LOG}")"
}

test_list_without_gh() {
  setup nogh
  FZF_PICK='^$' FZF_LOG="${root}/fzf.in" PATH="${nogh_path}" run_merge >/dev/null
  check "gh が無ければローカルの行だけを出す" \
    "local feat/both
local feat/local
local feat/wt
local pr/feat" "$(cut -f1,2 "${root}/fzf.in" | tr '\t' ' ')"
}

test_list_hides_doing_task_branches() {
  setup doing
  echo '[{"status":"doing","branch":"feat/local"},{"status":"ready","branch":"feat/wt"},{"status":"doing","branch":"feat/both"}]' >"${root}/tasks.json"
  TASKS_JSON="${root}/tasks.json" offer
  check "doing のタスクのブランチはローカルの行に出ない。ready のタスクのブランチと PR の行は出る" \
    "pr feat/both 8|local feat/wt" "$(offered_keys | tail -n 2 | paste -sd '|')"
}

test_list_tasks_failure() {
  setup tasksfail
  TASKS_FAIL=1 offer
  check "tasks list が失敗したらローカルの行を全部出し、警告する" \
    "local feat/local|local feat/wt|1" "$(offered_keys | tail -n 2 | paste -sd '|')|$(grep -c 'tasks list に失敗' "${root}/err")"
}

test_nothing_picked() {
  setup nothing
  local before after
  before="$(branches)|$(g "${repo}" rev-parse main)"
  rm -f "${GH_LOG}"
  FZF_PICK='^$' run_merge >/dev/null
  local rc=$?
  after="$(branches)|$(g "${repo}" rev-parse main)"
  check "何も選ばなければ何も変えず正常終了" "0:${before}|0" "${rc}:${after}|$(exists "${GH_LOG}")"
}

test_local_row() {
  setup local
  tmux kill-server 2>/dev/null
  tmux new-session -d -s only-wt -c "${repo}-worktree/feat-wt" 'sleep 600'
  tmux new-session -d -s mixed -c "${repo}-worktree/feat-wt" 'sleep 600'
  tmux new-window -t mixed -c "${repo}" 'sleep 600'
  FZF_PICK="$(pick local feat/wt)" run_merge >/dev/null
  local rc=$?
  check "ローカルの行: 終了コード 0" "0" "${rc}"
  check "ローカルの行: 今のブランチへ merge される" "1" "$(g "${repo}" log --format=%s main | grep -cx 'feat/wt')"
  check "ローカルの行: worktree・branch・removed/<branch> が消える。他は残る" \
    "feat/both feat/local main pr/feat removed/old" "$(branches)"
  check "ローカルの行: worktree が消える" "0" "$(exists "${repo}-worktree/feat-wt")"
  check "ローカルの行: push しない" "0" "$(g "${origin}" log --format=%s main | grep -cx 'feat/wt')"
  check "ローカルの行: worktree 内だけの tmux session は消える" "0" "$(tmux has-session -t '=only-wt' 2>/dev/null && echo 1 || echo 0)"
  check "ローカルの行: 外にも pane がある tmux session は残る" "1" "$(tmux has-session -t '=mixed' 2>/dev/null && echo 1 || echo 0)"
  tmux kill-server 2>/dev/null
}

test_local_row_without_worktree() {
  setup localplain
  FZF_PICK="$(pick local feat/local)" run_merge >/dev/null
  check "worktree の無いローカルの行: merge して branch を消す" \
    "1|feat/both feat/wt main pr/feat removed/old" \
    "$(g "${repo}" log --format=%s main | grep -cx 'feat/local')|$(branches)"
}

test_local_row_makes_merge_commit() {
  setup localnoff
  local ff_able
  ff_able=$(g "${repo}" merge-base --is-ancestor main feat/local && echo yes || echo no)
  FZF_PICK="$(pick local feat/local)" run_merge >/dev/null
  check "ローカルの行: fast-forward できても merge commit を作る" \
    "yes|2" "${ff_able}|$(g "${repo}" rev-list --parents -n1 main | awk '{ print NF - 1 }')"
}

test_skip_cleanup() {
  setup keep
  FZF_PICK="$(pick local feat/wt)" run_merge -k >/dev/null
  check "-k: merge はするが worktree と branch を残す" \
    "1|1|feat/wt" \
    "$(g "${repo}" log --format=%s main | grep -cx 'feat/wt')|$(exists "${repo}-worktree/feat-wt")|$(branches | tr ' ' '\n' | grep -x 'feat/wt')"
}

test_local_row_merge_failure() {
  setup conflict
  g "${repo}" checkout -q -b feat/conflict main
  echo a >"${repo}/init"
  g "${repo}" commit -qam a
  g "${repo}" checkout -q main
  echo b >"${repo}/init"
  g "${repo}" commit -qam b
  FZF_PICK="$(pick local feat/conflict)" run_merge >/dev/null
  local rc=$?
  g "${repo}" merge --abort
  check "ローカルの行: merge が失敗したら終了コード 1 で branch を残す" \
    "1:1" "${rc}:$(branches | tr ' ' '\n' | grep -cx 'feat/conflict')"
}

test_method_on_local_row() {
  setup localmethod
  local before rc
  before=$(g "${repo}" rev-parse main)
  FZF_PICK="$(pick local feat/wt)" run_merge -s >/dev/null
  rc=$?
  check "-s をローカルの行に使うと終了コード 2 で何も merge しない" \
    "2:${before}:1" "${rc}:$(g "${repo}" rev-parse main):$(exists "${repo}-worktree/feat-wt")"
  FZF_PICK="$(pick local feat/wt)" run_merge -r >/dev/null
  check "-r も同じ" "2" "$?"
}

test_both_methods() {
  setup bothmethods
  run_merge -s -r >/dev/null
  check "-s と -r の同時指定は終了コード 2" "2" "$?"
}

pr_merge_args() {
  cat "${GH_LOG}" 2>/dev/null
}

test_pr_row() {
  setup pr
  FZF_PICK="$(pick pr pr/feat 7)" run_merge >/dev/null
  local rc=$?
  check "PR の行: 終了コード 0" "0" "${rc}"
  check "PR の行: gh pr merge を --merge と --match-head-commit で呼ぶ (--delete-branch は付けない)" "pr merge 7 --merge --match-head-commit ${pr_oid}" "$(pr_merge_args)"
  check "PR の行: origin の head branch を消す" "main" "$(remote_branches)"
  check "PR の行: checkout 中の local の base が origin/main へ進む" \
    "$(g "${origin}" rev-parse main)" "$(g "${repo}" rev-parse main)"
  check "PR の行: worktree と branch を片付ける" \
    "0|feat/both feat/local feat/wt main removed/old" "$(exists "${repo}-worktree/pr-feat")|$(branches)"
}

test_pr_row_methods() {
  local flag
  for flag in squash rebase; do
    setup "pr-${flag}"
    FZF_PICK="$(pick pr pr/feat 7)" run_merge "-${flag:0:1}" >/dev/null
    check "PR の行 -${flag:0:1}: --${flag} で呼び、祖先関係が無くても local の branch を消す" \
      "pr merge 7 --${flag} --match-head-commit ${pr_oid}|1|feat/both feat/local feat/wt main removed/old" \
      "$(pr_merge_args)|$(g "${repo}" log --format=%s main | grep -c 'pr-feat\|squash')|$(branches)"
  done
}

test_pr_row_base_not_checked_out() {
  setup prbase
  g "${repo}" checkout -q feat/local
  FZF_PICK="$(pick pr pr/feat 7)" run_merge >/dev/null
  check "PR の行: base がどの worktree でも checkout されていなければ fetch で local の base を進める" \
    "$(g "${origin}" rev-parse main)" "$(g "${repo}" rev-parse main)"
}

test_pr_row_keeps_current_worktree() {
  setup prcwd
  FZF_PICK="$(pick pr pr/feat 7)" bash -c "cd '${repo}-worktree/pr-feat' && '${bin}'" >/dev/null 2>"${root}/err"
  check "PR の行: 今いる worktree の branch は片付けず警告する" \
    "1|pr/feat|1" \
    "$(exists "${repo}-worktree/pr-feat")|$(branches | tr ' ' '\n' | grep -x 'pr/feat')|$(grep -c 'checkout 中なので後片付けしない' "${root}/err")"
}

test_pr_row_remote_branch_already_gone() {
  setup prwarn
  g "${origin}" branch -q -D pr/feat
  FZF_PICK="$(pick pr pr/feat 7)" run_merge >/dev/null
  check "PR の行: origin の branch が既に無ければ何も言わず後片付けまで進む" \
    "0|0" "$(exists "${repo}-worktree/pr-feat")|$(grep -c 'Warning' "${root}/err")"
}

test_pr_row_keeps_unpushed_commits() {
  setup prunpushed
  commit "${repo}-worktree/pr-feat" unpushed
  FZF_PICK="$(pick pr pr/feat 7)" run_merge >/dev/null
  local rc=$?
  check "PR の行: PR に無い local の commit があれば worktree と branch を残し警告する" \
    "0|1|pr/feat|1" \
    "${rc}|$(exists "${repo}-worktree/pr-feat")|$(branches | tr ' ' '\n' | grep -x 'pr/feat')|$(grep -c 'PR #7 に無い commit' "${root}/err")"
}

test_pr_row_not_merged_yet() {
  setup prqueued
  GH_PR_STATE=OPEN FZF_PICK="$(pick pr pr/feat 7)" run_merge >/dev/null
  local rc=$?
  check "PR の行: merge 済みでなければ origin と local の branch を残し終了コード 1" \
    "1|main pr/feat|1|pr/feat|1" \
    "${rc}|$(remote_branches)|$(exists "${repo}-worktree/pr-feat")|$(branches | tr ' ' '\n' | grep -x 'pr/feat')|$(grep -c 'まだ merge されていない' "${root}/err")"
}

test_pr_row_remote_branch_moved() {
  setup prmoved
  commit "${other}" moved
  g "${other}" push -q origin pr/feat
  FZF_PICK="$(pick pr pr/feat 7)" run_merge >/dev/null
  check "PR の行: origin の branch が PR の head でなければ消さず警告する" \
    "main pr/feat|1" "$(remote_branches)|$(grep -c 'origin/pr/feat は PR #7 の head を指していない' "${root}/err")"
}

test_pr_row_keeps_stale_removed_branch() {
  setup prstale
  g "${repo}" branch removed/pr/feat feat/local
  local stale
  stale=$(g "${repo}" rev-parse removed/pr/feat)
  FZF_PICK="$(pick pr pr/feat 7)" run_merge >/dev/null
  check "PR の行: 以前から在る別物の removed/<branch> は消さない" \
    "${stale}|0|0" \
    "$(g "${repo}" rev-parse removed/pr/feat)|$(exists "${repo}-worktree/pr-feat")|$(branches | tr ' ' '\n' | grep -cx 'pr/feat')"
}

test_local_row_detached_head() {
  setup detached
  g "${repo}" checkout -q --detach main
  FZF_PICK="$(pick local feat/local)" run_merge >/dev/null
  local rc=$?
  check "ローカルの行: detached HEAD には merge せず終了コード 1 で branch を残す" \
    "1:1:$(g "${repo}" rev-parse main)" "${rc}:$(branches | tr ' ' '\n' | grep -cx 'feat/local'):$(g "${repo}" rev-parse HEAD)"
}

test_local_row_keeps_main_worktree() {
  setup keepmain
  g "${repo}" checkout -q feat/local
  FZF_PICK="$(pick local feat/local)" bash -c "cd '${repo}-worktree/feat-wt' && '${bin}'" >/dev/null 2>"${root}/err"
  check "親リポジトリで checkout 中の branch は片付けず警告する" \
    "feat/local|1" \
    "$(branches | tr ' ' '\n' | grep -x feat/local)|$(grep -c 'checkout 中なので後片付けしない' "${root}/err")"
}

test_local_row_worktree_outside_root() {
  setup outside
  branch_off_main feat/w
  g "${repo}" worktree add -q "${root}/elsewhere" feat/w
  FZF_PICK="$(pick local feat/w)" run_merge >/dev/null
  local rc=$?
  check "置き場所の外の worktree は消さず、名前が似た置き場所の中の worktree も残る" \
    "0|1|1|1|1|1|0" \
    "${rc}|$(exists "${root}/elsewhere")|$(exists "${repo}-worktree/feat-wt")|$(branches | tr ' ' '\n' | grep -cx 'feat/wt')|$(branches | tr ' ' '\n' | grep -cx 'feat/w')|$(grep -c 'git_worktree -r .* に失敗した' "${root}/err")|$(grep -c 'ブランチ .* を消せなかった' "${root}/err")"
}

install_fakes() {
  mkdir -p "${tmp}/bin"
  cat >"${tmp}/bin/fzf" <<'EOF'
#!/usr/bin/env bash
query=
while [[ $# -gt 0 ]]; do
  [[ $1 == --query ]] && query="$2"
  shift
done
input=$(cat)
if [[ -n ${query} ]]; then
  selected=$(printf '%s\n' "${input}" | grep -F -- "${query}" | head -n 1)
  [[ -z ${selected} ]] && exit 1
  printf '%s\n' "${selected}"
  exit 0
fi
[[ -n ${FZF_LOG:-} ]] && printf '%s\n' "${input}" >"${FZF_LOG}"
selected=$(printf '%s\n' "${input}" | grep -E "${FZF_PICK}")
[[ -z ${selected} ]] && exit 1
printf '%s\n' "${selected}"
EOF
  cat >"${tmp}/bin/gh" <<'EOF'
#!/usr/bin/env bash
git_in() {
  git -c user.email=t@t -c user.name=t "$@"
}
merge_into_origin() {
  local number="$1" method="$2" head base work
  head=$(jq -r --argjson n "${number}" '.[] | select(.number == $n) | .headRefName' "${GH_PRS}")
  base=$(jq -r --argjson n "${number}" '.[] | select(.number == $n) | .baseRefName' "${GH_PRS}")
  work=$(mktemp -d)
  git clone -q "${GH_ORIGIN}" "${work}/c"
  cd "${work}/c" || exit 1
  git_in checkout -q "${base}"
  case "${method}" in
    --merge) git_in merge -q --no-ff -m "merge ${head}" "origin/${head}" ;;
    --squash) git_in merge -q --squash "origin/${head}" && git_in commit -qm "squash ${head}" ;;
    --rebase) git_in merge -q --ff-only "origin/${head}" ;;
  esac
  git_in push -q origin "${base}"
}
[[ $1 == pr ]] || exit 1
case "$2" in
  list)
    echo list >>"${GH_LIST_LOG}"
    [[ -n ${GH_FAIL:-} ]] && { echo "gh: boom" >&2; exit 1; }
    cat "${GH_PRS}"
    ;;
  view)
    [[ $4 == --json ]] && { echo "${GH_PR_STATE:-MERGED}"; exit 0; }
    echo "PR #$3"
    ;;
  merge)
    echo "pr merge ${*:3}" >>"${GH_LOG}"
    merge_into_origin "$3" "$4"
    ;;
esac
EOF
  cat >"${tmp}/bin/tasks" <<'EOF'
#!/usr/bin/env bash
[[ "$*" == "list --json" ]] || exit 2
[[ -n ${TASKS_FAIL:-} ]] && { echo "tasks: boom" >&2; exit 1; }
[[ -n ${TASKS_JSON:-} ]] && { cat "${TASKS_JSON}"; exit 0; }
echo '[]'
EOF
  chmod +x "${tmp}/bin/fzf" "${tmp}/bin/gh" "${tmp}/bin/tasks"
}

make_path_without_gh() {
  local dir file
  mkdir -p "${tmp}/nogh"
  while IFS= read -r dir; do
    [[ ! -d ${dir} ]] && continue
    for file in "${dir}"/*; do
      [[ ${file##*/} == gh ]] && continue
      [[ -x ${file} && ! -d ${file} ]] && ln -sf "${file}" "${tmp}/nogh/${file##*/}" 2>/dev/null
    done
  done < <(tr ':' '\n' <<<"${PATH}" | tac)
  nogh_path="${tmp}/bin_fzf_only:${tmp}/nogh"
  mkdir -p "${tmp}/bin_fzf_only"
  ln -sf "${tmp}/bin/fzf" "${tmp}/bin_fzf_only/fzf"
}

main() {
  local pass=0 fail=0 tmp bin bin_dir root origin repo other nogh_path pr_oid
  local icon_pr=$'☁️' icon_local=$'\U0001F4BB' icon_worktree=$'\U0001F332'
  local icon_ci_failed=$'❌' icon_ci_pending=$'⏳' icon_ci_passed=$'✅'
  bin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if ! "${bin_dir}/tmux-sandbox" --inside; then
    exec "${bin_dir}/tmux-sandbox" "${BASH_SOURCE[0]}" "$@"
  fi
  bin="${bin_dir}/merge"
  tmp=$(mktemp -d)
  # shellcheck disable=SC2064 # local 変数なので定義時に展開する
  trap "rm -rf '${tmp}'" EXIT
  # lint-ignore: uppercase git が読む環境変数
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_MERGE_AUTOEDIT=no \
    GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
  install_fakes
  make_path_without_gh
  # lint-ignore: uppercase PATH は環境変数
  PATH="${tmp}/bin:${bin_dir}:${PATH}"
  nogh_path="${nogh_path}:${bin_dir}"
  test_list
  test_list_gh_failure
  test_list_without_remote
  test_list_without_gh
  test_list_hides_doing_task_branches
  test_list_tasks_failure
  test_nothing_picked
  test_local_row
  test_local_row_without_worktree
  test_local_row_makes_merge_commit
  test_skip_cleanup
  test_local_row_merge_failure
  test_method_on_local_row
  test_both_methods
  test_pr_row
  test_pr_row_methods
  test_pr_row_base_not_checked_out
  test_pr_row_keeps_current_worktree
  test_pr_row_remote_branch_already_gone
  test_pr_row_keeps_unpushed_commits
  test_pr_row_not_merged_yet
  test_pr_row_remote_branch_moved
  test_pr_row_keeps_stale_removed_branch
  test_local_row_detached_head
  test_local_row_keeps_main_worktree
  test_local_row_worktree_outside_root
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
