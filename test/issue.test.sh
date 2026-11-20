#!/usr/bin/env bash

# bin/issue のユニットテスト (実 gh / fzf / nvim / tasks 不要)。
#
# issue_to_tasks は `gh issue view --json number,title,body,comments,url` の JSON を
# 受け取るので、fixture もその形で組む (gh_issue ヘルパ)。
# issue_select_open / parse_args は gh / fzf / tasks / nvim を関数でスタブして検証する。
#
#   test/issue.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
issue_bin=$(cd "${script_dir}/../bin" && pwd)/issue

# shellcheck source-path=SCRIPTDIR source=../bin/issue
source "${issue_bin}"

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

# 最小の issue JSON。$1 = number, $2 = body, $3 = comments 配列 (既定 []),
# $4 = url (既定 https://github.com/o/r/issues/<number>)。
gh_issue() {
  local number=$1 body=${2-} comments=${3:-[]} url=${4-https://github.com/o/r/issues/$1}
  jq -nc --argjson n "${number}" --arg body "${body}" --argjson c "${comments}" --arg url "${url}" \
    '{number:$n, title:("title of #" + ($n|tostring)), body:$body, comments:$c, url:$url}'
}

comment_of() {
  jq -nc --arg who "$1" --arg at "$2" --arg body "$3" '{author:{login:$who}, createdAt:$at, body:$body}'
}

# 1. タイトル行は `- [ ] [#NN] Title`、footer に issue の URL
test_title_and_footer() {
  check 'タイトルが [#NN] 付きの task 行になり、footer に URL が付く' \
    "$(printf -- '- [ ] [#12] title of #12\n  - View this issue on GitHub: https://github.com/o/r/issues/12')" \
    "$(gh_issue 12 | issue_to_tasks)"
}

# 2. body は markdown のまま 2 スペース字下げされ、空行が落ちる
test_body_is_indented_markdown() {
  check 'body が 2 スペース下がり、空行が落ちる' \
    "$(printf -- '- [ ] [#1] title of #1\n  ## 背景\n  - alpha\n  - View this issue on GitHub: https://github.com/o/r/issues/1')" \
    "$(gh_issue 1 $'## 背景\r\n\n- alpha\n' | tr -d '\r' | issue_to_tasks)"
}

# 3. コメントは古い順に 1 件 1 ブロックで並ぶ
test_comments_are_one_block_each_in_order() {
  local comments
  comments=$(jq -nc --argjson a "$(comment_of alice 2026-03-02T00:00:00Z first)" \
    --argjson b "$(comment_of bob 2026-03-03T09:30:00Z second)" '[$a,$b]')
  check 'コメントが古い順に 1 件 1 ブロックで並ぶ' \
    "$(printf -- '- [ ] [#1] title of #1\n  - Comments\n    - alice • 2026-03-02 09:00\n      first\n    - bob • 2026-03-03 18:30\n      second\n  - View this issue on GitHub: https://github.com/o/r/issues/1')" \
    "$(gh_issue 1 '' "${comments}" | TZ=Asia/Tokyo issue_to_tasks)"
}

# --- issue_select_open: 外部コマンドのスタブ ---
# fzf が起動している間 (= 一覧の JSON が残っている間) に、preview を 1 番目の候補で
# 実際に走らせて出力を記録する。preview がネットワークに出ず、手元の JSON だけで
# 描けることを確かめるため。
fzf() {
  printf 'fzf %s\n' "$*" >>"${stub_log}"
  local first preview=''
  while [[ -n ${1:-} ]]; do
    [[ $1 == --preview ]] && preview=$2
    shift
  done
  first=$(head -n1 | cut -f1)
  [[ -n ${first} && -n ${preview} ]] && bash -c "${preview//\{1\}/${first}}" | sed 's/^/preview> /' >>"${stub_log}"
  [[ -z ${fzf_selection:-} ]] && return 130
  printf '%s\n' "${fzf_selection}"
}
gh() {
  printf 'gh %s\n' "$*" >>"${stub_log}"
  if [[ $2 == list ]]; then
    jq -nc '[{number:5, title:"five", body:"body of #5\nline 2", labels:[{name:"bug"}], author:{login:"u"}}]'
    return 0
  fi
  [[ $2 != view ]] && return 0
  [[ -n ${gh_view_rc:-} ]] && return "${gh_view_rc}"
  local number=$3 repo=o/r
  [[ ${4:-} == -R ]] && repo=$5
  gh_issue "${number}" "body of #${number}" '[]' "https://github.com/${repo}/issues/${number}"
}
tasks() {
  printf 'tasks %s\n' "$*" >>"${stub_log}"
  sed 's/^/| /' >>"${stub_log}"
}
nvim() {
  printf 'nvim %s\n' "$1" >>"${stub_log}"
  local f
  shift
  for f in "$@"; do
    printf '# %s\n' "${f##*/}" >>"${stub_log}"
    sed 's/^/| /' "${f}" >>"${stub_log}"
  done
}

sink_log() { grep -v -e '^fzf ' -e '^gh ' -e '^preview> ' "${stub_log}"; }

# 5. to-tasks は issue ごとに tasks add に渡す
test_to_tasks_appends_each_selected_issue() {
  local stub_log fzf_selection mode=to-tasks gh_repo_args=()
  stub_log=$(mktemp)
  fzf_selection=$(printf '1\tt1\n2\tt2')
  issue_select_open
  check '複数選択した issue が 1 件ずつ tasks add に渡る' \
    "$(printf 'tasks add\n| - [ ] [#1] title of #1\n|   body of #1\n|   - View this issue on GitHub: https://github.com/o/r/issues/1\ntasks add\n| - [ ] [#2] title of #2\n|   body of #2\n|   - View this issue on GitHub: https://github.com/o/r/issues/2')" \
    "$(sink_log)"
  rm -f "${stub_log}"
}

# 6. -R は list / view / preview のすべてに渡る
test_repo_override_reaches_every_gh_call() {
  local stub_log fzf_selection mode=to-tasks gh_repo_args=(-R x/y) actual
  stub_log=$(mktemp)
  fzf_selection=$(printf '3\tt3')
  issue_select_open
  actual=$(grep -c -e '^gh issue list -R x/y' -e '^gh issue view 3 -R x/y' "${stub_log}")
  check 'list と view の両方に -R が渡る' 2 "${actual}"
  rm -f "${stub_log}"
}

# 7. view が落ちたら tasks add を呼ばずに止まる
test_to_tasks_stops_when_view_fails() {
  local stub_log fzf_selection mode=to-tasks gh_repo_args=() gh_view_rc=1 rc=0
  stub_log=$(mktemp)
  fzf_selection=$(printf '1\tt1')
  (issue_select_open) 2>/dev/null || rc=$?
  check 'view が落ちたら tasks add を呼ばない' '' "$(sink_log)"
  check 'view が落ちたら異常終了する' 1 "${rc}"
  rm -f "${stub_log}"
}

# 8. open は選択した issue ごとに <NN>.md を nvim -p のタブで開く
test_open_mode_opens_one_tab_per_issue() {
  local stub_log fzf_selection mode=open gh_repo_args=()
  stub_log=$(mktemp)
  fzf_selection=$(printf '1\tt1\n2\tt2')
  issue_select_open
  check 'open は issue ごとの <NN>.md を nvim -p で開く' \
    "$(printf 'nvim -p\n# 1.md\n| - [ ] [#1] title of #1\n|   body of #1\n|   - View this issue on GitHub: https://github.com/o/r/issues/1\n# 2.md\n| - [ ] [#2] title of #2\n|   body of #2\n|   - View this issue on GitHub: https://github.com/o/r/issues/2')" \
    "$(sink_log)"
  rm -f "${stub_log}"
}

# 9. 選択をキャンセルしたらどの sink も呼ばない
test_cancelled_selection_calls_no_sink() {
  local stub_log fzf_selection='' mode=to-tasks gh_repo_args=()
  stub_log=$(mktemp)
  issue_select_open
  check 'キャンセル時は tasks も nvim も呼ばない' '' "$(sink_log)"
  rm -f "${stub_log}"
}

# 9b. preview は一覧で取った JSON から描き、gh を呼ばない
test_preview_reads_listed_json() {
  local stub_log fzf_selection='' mode=open gh_repo_args=()
  stub_log=$(mktemp)
  issue_select_open
  check 'preview は一覧の JSON から番号・タイトル・body を出す' \
    "$(printf 'preview> # #5 five\npreview> \npreview> body of #5\npreview> line 2')" \
    "$(grep '^preview> ' "${stub_log}")"
  check 'gh は一覧の 1 回しか呼ばれない' 1 "$(grep -c '^gh ' "${stub_log}")"
  check '一覧は number / title / labels / author を TSV で fzf に渡す' "$(printf '5\tfive\tbug\tu')" \
    "$(gh issue list | issue_lines)"
  rm -f "${stub_log}"
}

# 9d. fzf を抜けたら一覧の一時ファイルは残らない
test_list_cache_is_removed() {
  local stub_log fzf_selection='' mode=open gh_repo_args=() cache_path actual=removed
  stub_log=$(mktemp)
  issue_select_open
  cache_path=$(grep '^fzf ' "${stub_log}" | grep -o '/[^ ]*tmp[^ ]*' | tail -n1)
  [[ -n ${cache_path} && -e ${cache_path} ]] && actual=exists
  if [[ -z ${cache_path} ]]; then
    actual=not-found
  fi
  check 'fzf 終了後に一覧の JSON を消す' removed "${actual}"
  rm -f "${stub_log}"
}

# 10. 引数: 既定は open、-t / -a / -R を読み、知らない引数と -a 外の -f は落とす
test_parse_args() {
  local mode file='' title='' gh_repo_args rc
  mode=open gh_repo_args=()
  parse_args
  check '引数なしは open' open "${mode}"
  parse_args -t -R a/b
  check '-t は to-tasks' to-tasks "${mode}"
  check '-R は gh_repo_args に入る' '-R a/b' "${gh_repo_args[*]}"
  mode=open file='' title=''
  parse_args -a -f x.md --title T
  check '-a は add、-f / --title を読む' 'add x.md T' "${mode} ${file} ${title}"
  rc=0
  (parse_args --bogus) 2>/dev/null || rc=$?
  check '知らない引数は落とす' 1 "${rc}"
  rc=0
  (
    mode=open file='' title=''
    parse_args -f x.md
  ) 2>/dev/null || rc=$?
  check '-a 以外で -f は落とす' 1 "${rc}"
}

main() {
  set -uo pipefail
  local pass=0 fail=0
  test_title_and_footer
  test_body_is_indented_markdown
  test_comments_are_one_block_each_in_order
  test_to_tasks_appends_each_selected_issue
  test_repo_override_reaches_every_gh_call
  test_to_tasks_stops_when_view_fails
  test_open_mode_opens_one_tab_per_issue
  test_cancelled_selection_calls_no_sink
  test_preview_reads_listed_json
  test_list_cache_is_removed
  test_parse_args

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
