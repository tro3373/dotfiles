#!/usr/bin/env bash

# bin/jira-issue の issue_to_tasks / issue_select_open ユニットテスト
# (実 jira / fzf 不要)。
#
# jira は glamour 経由で描画するため `jira issue view --plain` の出力は 120 桁で
# 折り返される。折り返しは " ,.;-+|" で起き、ブレークポイント文字は折れた行の
# 末尾に残り、空白で折れた場合はその空白 1 個が消える。
# issue_to_tasks のテストはこの折り返し済み出力を模した fixture を stdin から流し込む。
# issue_select_open のテストは fzf/jira/tasks/nvim/gh を関数でスタブして検証する。
#
#   test/jira-issue.test.sh   # 全テスト実行

set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
jira_issue_bin=$(cd "${script_dir}/../bin" && pwd)/jira-issue

# main を起動させずに issue_to_tasks だけを取り込む (bin/jira-issue の source ガード)。
# shellcheck source-path=SCRIPTDIR source=../bin/jira-issue
source "${jira_issue_bin}"

# desc / expected / actual を比較し、呼び出し元 main の pass・fail カウンタを更新する。
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

# jira の plain 出力ヘッダ (タイトル + Description 区切り) を body の前に足して変換する。
# 引数はそのまま issue_to_tasks に渡す (KEY 前置のテスト用)。
convert() {
  {
    printf '\n  # T\n\n'
    printf '  ------------------------ Description ------------------------\n\n'
    cat
  } | issue_to_tasks "$@"
}

# 1. ブレークポイント文字 (. と -) で折れた URL が 1 本に戻る
test_url_split_on_breakpoints_is_rejoined() {
  local actual
  actual=$(
    convert <<'EOF'
  • figama
      • 📍 https://www.figma.
      com/design/nu5pgf7Ui8kIE5e3IQp0D1/LINEUI_251023?node-id=40001930-
      1726&t=AETsDwd2KXWoG4er-0
EOF
  )
  check 'ブレークポイント折り返しの URL が空白なしで連結される' \
    "$(printf -- '- [ ] T\n  - figama\n    - 📍 https://www.figma.com/design/nu5pgf7Ui8kIE5e3IQp0D1/LINEUI_251023?node-id=40001930-1726&t=AETsDwd2KXWoG4er-0')" \
    "${actual}"
}

# 2. 空白で折れた行は半角スペース 1 個を補って連結する (glamour が空白を 1 個落とす)
test_space_wrap_is_rejoined_with_one_space() {
  local actual
  actual=$(
    convert <<'EOF'
  • alpha bravo
  charlie delta
EOF
  )
  check '空白折り返しはスペース 1 個で連結される' \
    "$(printf -- '- [ ] T\n  - alpha bravo charlie delta')" "${actual}"
}

# 3. 空行はブロック境界。連結せず独立したバレットになる
test_blank_line_breaks_the_join() {
  local actual
  actual=$(
    convert <<'EOF'
  • alpha

  bravo
EOF
  )
  check '空行を挟むと連結されない' \
    "$(printf -- '- [ ] T\n  - alpha\n  - bravo')" "${actual}"
}

# 4. • 始まりの行は連結せず新しいバレットになる
test_bullet_line_starts_a_new_item() {
  local actual
  actual=$(
    convert <<'EOF'
  • alpha
  • bravo
EOF
  )
  check '• 始まりの行は新しいバレットになる' \
    "$(printf -- '- [ ] T\n  - alpha\n  - bravo')" "${actual}"
}

# 5. 空バレットは出力されず、後続行の連結先にもならない
test_empty_bullet_is_dropped_and_breaks_the_join() {
  local actual
  actual=$(
    convert <<'EOF'
  • alpha
  •
  bravo
EOF
  )
  check '空バレットは出力されず境界になる' \
    "$(printf -- '- [ ] T\n  - alpha\n  - bravo')" "${actual}"
}

# 6. バレット以外の行 (フッタ等) の折り返しも連結される
test_non_bullet_line_is_rejoined() {
  local actual
  actual=$(
    convert <<'EOF'
  View this issue on Jira: https://zemmov.atlassian.net/browse/LINE-
  146
EOF
  )
  check 'バレット以外の行も折り返しが連結される' \
    "$(printf -- '- [ ] T\n  - View this issue on Jira: https://zemmov.atlassian.net/browse/LINE-146')" \
    "${actual}"
}

# 7. Description より前の行は捨て、タイトルだけを task 行にする (既存挙動の保護)
test_pre_description_lines_are_dropped() {
  local actual
  actual=$(printf '\n  ⭐ タスク  🚧 To Do\n\n  # T\n\n  ⏱️  Thu\n\n  --------- Description ---------\n\n  • alpha\n' | issue_to_tasks)
  check 'Description 前のヘッダ行は捨てられる' \
    "$(printf -- '- [ ] T\n  - alpha')" "${actual}"
}

# 8. 既知の制約: 句読点直後で折れた散文はスペースを 1 個失う。
#    出力からは「空白折り返し」と「ブレークポイント折り返し」を区別できないため、
#    URL を壊さないほうを優先した結果。挙動を固定して退行に気付けるようにする。
test_prose_wrapped_after_punctuation_loses_the_space() {
  local actual
  actual=$(
    convert <<'EOF'
  • End of the first sentence.
  Next sentence keeps going.
EOF
  )
  check '句読点終端で折れた散文はスペースを失う (既知の制約)' \
    "$(printf -- '- [ ] T\n  - End of the first sentence.Next sentence keeps going.')" "${actual}"
}

# 9. ANSI エスケープは除去される (既存挙動の保護)
test_ansi_escapes_are_stripped() {
  local actual
  actual=$(printf '  • \x1b[1malpha\x1b[0m\n' | convert)
  check 'ANSI エスケープが除去される' \
    "$(printf -- '- [ ] T\n  - alpha')" "${actual}"
}

# 10. KEY を渡すとタイトル先頭に [KEY] が付く
test_key_is_prefixed_to_title() {
  local actual
  actual=$(
    convert IDNAME-123 <<'EOF'
  • alpha
EOF
  )
  check 'KEY 引数がタイトル先頭に [KEY] として付く' \
    "$(printf -- '- [ ] [IDNAME-123] T\n  - alpha')" "${actual}"
}

# 11. KEY 引数なしなら前置しない (issue_to_tasks 単体利用時の既存挙動の保護)
test_no_key_leaves_title_untouched() {
  local actual
  actual=$(
    convert <<'EOF'
  • alpha
EOF
  )
  check 'KEY なしならタイトルは前置されない' \
    "$(printf -- '- [ ] T\n  - alpha')" "${actual}"
}

# --- issue_select_open 用スタブ ------------------------------------------
# 実コマンドを呼ばず、fzf の引数と sink (tasks/nvim/gh) への入力を ${stub_log} に
# 記録する。stub_log / fzf_selection は各テスト関数の local を動的スコープで参照。

# 候補一覧。fzf は ${fzf_selection} をそのまま選択結果として返す (空なら中断)。
list_issues_plain() { printf 'K-1\tsummary1\nK-2\tsummary2\n'; }
fzf() {
  printf 'fzf %s\n' "$*" >>"${stub_log}"
  cat >/dev/null
  [[ -z ${fzf_selection} ]] && return 130
  printf '%s\n' "${fzf_selection}"
}

# `jira issue view <KEY> --plain` の plain 出力を模し ($3 = KEY)、
# `jira issue link remote ...` は呼び出し引数を記録する。
# ${jira_title} でタイトルを、${jira_link_rc} でリンク登録の成否を差し替える。
jira() {
  if [[ $2 == link ]]; then
    printf 'jira %s\n' "$*" >>"${stub_log}"
    return "${jira_link_rc:-0}"
  fi
  printf '\n  # %s\n\n  ---- Description ----\n\n  • body of %s\n' "${jira_title-title of $3}" "$3"
}

# tasks は呼び出し引数と stdin を記録する (stdin は "| " 前置)
tasks() {
  printf 'tasks %s\n' "$*" >>"${stub_log}"
  sed 's/^/| /' >>"${stub_log}"
  return "${tasks_rc:-0}"
}

# nvim は開いたファイルの置き場と、タブごとのファイル名・中身を記録する。
# ${nvim_rc} を立てたテストでは異常終了 (:cq やクラッシュ) を模す。
nvim() {
  local flag="$1" file
  shift
  printf 'nvim %s\n' "${flag}" >>"${stub_log}"
  printf 'tmpdir %s\n' "$(dirname "$1")" >>"${stub_log}"
  for file in "$@"; do
    printf '# %s\n' "${file##*/}" >>"${stub_log}"
    sed 's/^/| /' "${file}" >>"${stub_log}"
  done
  return "${nvim_rc:-0}"
}

# gh は `issue list` の検索結果として ${gh_existing_titles} を返し、`issue create` の
# title/body を記録する。--body は複数行なので引数行から外し、本文は "| " 前置で残す。
gh() {
  local title="" issue_body="" repo=""
  local -a shown=()
  while (($#)); do
    case "$1" in
      --title) title="$2" && shift ;;
      --body) issue_body="$2" && shift ;;
      # repo は受け取った argv から取る。jira-issue 側の gh_repo_args を覗くと
      # 「変数に入ったか」しか見なくなり、gh へ渡し忘れても緑のまま通る。
      -R | --repo) repo="$2" && shown+=("$1" "$2") && shift ;;
      *) shown+=("$1") ;;
    esac
    shift
  done
  printf 'gh %s\n' "${shown[*]}" >>"${stub_log}"
  if [[ ${shown[1]} == list ]]; then
    [[ -n ${gh_existing_titles:-} ]] && printf '%s\n' "${gh_existing_titles}"
    return "${gh_list_rc:-0}"
  fi
  printf 'gh-title %s\n' "${title}" >>"${stub_log}"
  printf '%s\n' "${issue_body}" | sed 's/^/| /' >>"${stub_log}"
  # 作成した issue の URL を返す。KEY 末尾の数字を issue 番号に流用して issue ごとに
  # 別 URL にし、repo は -R の指定を反映する (tracker の owner/repo が cwd ではなく
  # 作成先から来ることを検証するため)。
  # ${gh_create_out} で URL を含まない / 想定外の形の出力に差し替えられる。
  local key=${title%%]*}
  key=${key#"["}
  printf '%s\n' "${gh_create_out-https://github.com/${repo:-o/r}/issues/${key##*-}}"
}

fzf_line() { grep '^fzf ' "${stub_log}"; }
nvim_tmpdir() { sed -n 's/^tmpdir //p' "${stub_log}"; }
sink_log() { grep -v -e '^fzf ' -e '^tmpdir ' -e '^gh ' "${stub_log}"; }
gh_lines() { grep '^gh ' "${stub_log}"; }
tasks_lines() { grep '^tasks ' "${stub_log}"; }
tracker_lines() { sed -n 's/^| //p' "${stub_log}" | grep -- '- tracker:'; }

# 12. to-tasks は複数選択でき、issue ごとに tasks -a が呼ばれる
test_to_tasks_appends_each_selected_issue() {
  local stub_log fzf_selection
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1\nK-2\tsummary2')
  issue_select_open to-tasks
  check '複数選択した issue が 1 件ずつ tasks -a に渡る' \
    "$(printf 'tasks -a\n| - [ ] [K-1] title of K-1\n|   - tracker: jira=K-1\n|   - body of K-1\ntasks -a\n| - [ ] [K-2] title of K-2\n|   - tracker: jira=K-2\n|   - body of K-2')" \
    "$(sink_log)"
  rm -f "${stub_log}"
}

# 13. どちらのモードでも fzf は multi-select で起動する
test_both_modes_enable_fzf_multi_select() {
  local stub_log fzf_selection actual=no
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-tasks
  [[ $(fzf_line) == *--multi* ]] && actual=yes
  check 'to-tasks では fzf が multi-select で起動する' yes "${actual}"

  : >"${stub_log}"
  actual=no
  issue_select_open
  [[ $(fzf_line) == *--multi* ]] && actual=yes
  check 'open でも fzf が multi-select で起動する' yes "${actual}"
  rm -f "${stub_log}"
}

# 14. to-tasks で 1 件選択なら 1 件だけ追加される (既存挙動の保護)
test_to_tasks_with_single_pick_appends_one_task() {
  local stub_log fzf_selection
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-tasks
  check '1 件選択なら tasks -a は 1 回だけ' \
    "$(printf 'tasks -a\n| - [ ] [K-1] title of K-1\n|   - tracker: jira=K-1\n|   - body of K-1')" \
    "$(sink_log)"
  rm -f "${stub_log}"
}

# 15. open は選択した issue ごとに <KEY>.md を作り、nvim のタブとして開く
test_open_mode_opens_one_tab_per_issue() {
  local stub_log fzf_selection
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1\nK-2\tsummary2')
  issue_select_open
  check 'open は issue ごとの <KEY>.md を nvim -p でタブに開く' \
    "$(printf 'nvim -p\n# K-1.md\n| - [ ] [K-1] title of K-1\n|   - body of K-1\n# K-2.md\n| - [ ] [K-2] title of K-2\n|   - body of K-2')" \
    "$(sink_log)"
  rm -f "${stub_log}"
}

# 16. nvim 終了後に一時ファイルは残らない (名無しバッファ時代のスクラッチ性を維持)
test_open_mode_removes_tmpdir_after_nvim_exits() {
  local stub_log fzf_selection actual=exists
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open
  [[ -d $(nvim_tmpdir) ]] || actual=removed
  check 'nvim 終了後に一時ディレクトリが削除される' removed "${actual}"
  rm -f "${stub_log}"
}

# 17. nvim が異常終了しても一時ファイルは消し、終了コードは握り潰さない
test_open_mode_cleans_up_when_nvim_fails() {
  local stub_log fzf_selection actual=exists rc=0
  local nvim_rc=1 # :cq やクラッシュ相当
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  # main と同条件で走らせる。`|| rc=$?` を付けると errexit が無効化されるため、
  # サブシェルで囲んで終了コードだけ受け取る
  (
    set -euo pipefail
    issue_select_open
  )
  rc=$?
  [[ -d $(nvim_tmpdir) ]] || actual=removed
  check 'nvim が異常終了しても一時ディレクトリは削除される' removed "${actual}"
  check 'nvim の終了コードが伝播する' 1 "${rc}"
  rm -f "${stub_log}"
}

# 18. fzf を中断したら sink は呼ばれない (既存挙動の保護)
test_cancelled_selection_calls_no_sink() {
  local stub_log fzf_selection=""
  stub_log=$(mktemp)
  issue_select_open to-tasks
  check '選択なしなら tasks は呼ばれない' '' "$(sink_log)"

  : >"${stub_log}"
  issue_select_open
  check '選択なしなら nvim は呼ばれない' '' "$(sink_log)"

  : >"${stub_log}"
  issue_select_open to-gh
  check '選択なしなら gh は呼ばれない' '' "$(gh_lines)"
  rm -f "${stub_log}"
}

# 19. to-gh は選択した issue ごとに GH issue を作る (title = [KEY] SUMMARY, body = 変換結果)
test_to_gh_creates_one_issue_per_selection() {
  local stub_log fzf_selection
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1\nK-2\tsummary2')
  issue_select_open to-gh
  check '選択した issue ごとに [KEY] 付きの GH issue が作られる' \
    "$(printf 'gh-title [K-1] title of K-1\n| - [ ] [K-1] title of K-1\n|   - body of K-1\njira issue link remote K-1 https://github.com/o/r/issues/1 [K-1] title of K-1\ntasks -a\n| - [ ] [K-1] title of K-1\n|   - tracker: gh=o/r#1 jira=K-1\n|   - body of K-1\ngh-title [K-2] title of K-2\n| - [ ] [K-2] title of K-2\n|   - body of K-2\njira issue link remote K-2 https://github.com/o/r/issues/2 [K-2] title of K-2\ntasks -a\n| - [ ] [K-2] title of K-2\n|   - tracker: gh=o/r#2 jira=K-2\n|   - body of K-2')" \
    "$(sink_log)"
  rm -f "${stub_log}"
}

# 20. 同じ KEY の GH issue が既にあれば作らない (再選択しても二重作成しない)
test_to_gh_skips_existing_issue() {
  local stub_log fzf_selection
  local gh_existing_titles='[K-1] title of K-1'
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-gh
  check '既存の [KEY] issue があれば作成しない' '' "$(sink_log)"
  check '既存の [KEY] issue があればタスクも積まない' '' "$(tasks_lines)"
  rm -f "${stub_log}"
}

# 21. GitHub の検索は記号を落とすため無関係な issue にも当たる。
#     タイトルに [KEY] を含まないヒットはスキップ理由にしない
test_to_gh_creates_when_hit_lacks_key_prefix() {
  local stub_log fzf_selection
  local gh_existing_titles='Fix K 1 handling'
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-gh
  check '[KEY] を含まない検索ヒットでは作成をスキップしない' \
    "$(printf 'gh-title [K-1] title of K-1\n| - [ ] [K-1] title of K-1\n|   - body of K-1\njira issue link remote K-1 https://github.com/o/r/issues/1 [K-1] title of K-1\ntasks -a\n| - [ ] [K-1] title of K-1\n|   - tracker: gh=o/r#1 jira=K-1\n|   - body of K-1')" \
    "$(sink_log)"
  rm -f "${stub_log}"
}

# 22. -R owner/repo は検索と作成の双方に渡る (片方だけだと別 repo を見て二重作成する)
test_to_gh_passes_repo_override_to_both_calls() {
  local stub_log fzf_selection
  local -a gh_repo_args=()
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  set_gh_repo_args -R owner/repo
  issue_select_open to-gh
  check '-R owner/repo が gh の list / create 双方に渡る' \
    "$(printf 'list\ncreate')" \
    "$(gh_lines | grep -F -- '-R owner/repo' | awk '{print $3}')"
  rm -f "${stub_log}"
}

# 23. -R 未指定なら repo 引数を渡さない (gh が cwd の git remote から解決する)
test_gh_repo_args_are_empty_without_override() {
  local -a gh_repo_args=(-R stale/repo)
  set_gh_repo_args
  check '-R 未指定なら gh に repo 引数を渡さない' '' "${gh_repo_args[*]}"
  set_gh_repo_args --repo owner/repo
  check '--repo も -R として gh に渡る' '-R owner/repo' "${gh_repo_args[*]}"
}

# 24. 検索の失敗を「存在しない」と取り違えない (取り違えると既存 issue を作り直す)
test_to_gh_stops_when_the_search_fails() {
  local stub_log fzf_selection rc=0
  local gh_list_rc=1
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  (issue_select_open to-gh) >/dev/null 2>&1
  rc=$?
  check '検索に失敗したら issue を作らない' '' "$(sink_log)"
  check '検索に失敗したら異常終了する' 1 "${rc}"
  rm -f "${stub_log}"
}

# 25. [KEY] がタイトル途中にあるだけの issue は既存扱いにしない
#     (参照タイトルに引きずられると、作るべき issue を黙って作らなくなる)
test_to_gh_matches_the_key_only_as_a_title_prefix() {
  local stub_log fzf_selection
  local gh_existing_titles='Follow-up for [K-1] migration'
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-gh
  check '[KEY] がタイトル先頭でないヒットは既存扱いにしない' \
    "$(printf 'gh-title [K-1] title of K-1\n| - [ ] [K-1] title of K-1\n|   - body of K-1\njira issue link remote K-1 https://github.com/o/r/issues/1 [K-1] title of K-1\ntasks -a\n| - [ ] [K-1] title of K-1\n|   - tracker: gh=o/r#1 jira=K-1\n|   - body of K-1')" \
    "$(sink_log)"
  rm -f "${stub_log}"
}

# 26. 重複判定のクエリを固定する。--state all が落ちると close 済みの issue を
#     毎回作り直し、in:title が落ちると本文ヒットで作成をスキップする
test_to_gh_pins_the_duplicate_search_query() {
  local stub_log fzf_selection
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-gh
  check '重複判定は close 済みも含めてタイトルの "[KEY]" を検索する' \
    'gh issue list --search "[K-1]" in:title --state all --limit 100 --json title --jq .[].title' \
    "$(gh_lines | grep -- ' list ')"
  rm -f "${stub_log}"
}

# 27. -g の後ろの知らない引数は黙って捨てない (-R の綴り違いで別 repo に作る事故)
test_unknown_option_is_rejected() {
  local rc=0
  (set_gh_repo_args -Rowner/repo) >/dev/null 2>&1
  rc=$?
  check '知らない引数は黙って無視せず落ちる' 1 "${rc}"
}

# 28. SUMMARY が空なら作らない。"[KEY]" だけの issue を作ると、以後その KEY は
#     既存扱いになり本来の issue が二度と作られない
test_to_gh_rejects_an_issue_without_summary() {
  local stub_log fzf_selection rc=0
  local jira_title=""
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  (issue_select_open to-gh) >/dev/null 2>&1
  rc=$?
  check 'SUMMARY が空なら [KEY] だけの issue を作らない' '' "$(sink_log)"
  check 'SUMMARY が空なら異常終了する' 1 "${rc}"
  rm -f "${stub_log}"
}

# 29. 作成した GH issue の URL を Jira 側の Web Link として張り返す
test_to_gh_links_the_created_url_back_to_jira() {
  local stub_log fzf_selection
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-gh
  check '作成した issue の URL が Jira の Web Link として登録される' \
    'jira issue link remote K-1 https://github.com/o/r/issues/1 [K-1] title of K-1' \
    "$(grep '^jira ' "${stub_log}")"
  rm -f "${stub_log}"
}

# 30. gh の出力から URL を取れなければ止める。issue は既に出来ているので、
#     黙って進むと Jira 側だけ空のまま次の KEY へ行ってしまう
test_to_gh_stops_when_the_created_url_is_missing() {
  local stub_log fzf_selection rc=0
  local gh_create_out=""
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  (issue_select_open to-gh) >/dev/null 2>&1
  rc=$?
  check 'URL を取れなければ Web Link を張らない' 0 "$(grep -c '^jira ' "${stub_log}")"
  check 'URL を取れなければ異常終了する' 1 "${rc}"
  rm -f "${stub_log}"
}

# 31. Web Link の登録に失敗したら止める。次回の -g は「GH issue が既にある」で
#     スキップするため、黙って進むとリンクが永久に付かない
test_to_gh_stops_when_the_jira_link_fails() {
  local stub_log fzf_selection rc=0 out=""
  local jira_link_rc=1
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1\nK-2\tsummary2')
  out=$( (issue_select_open to-gh) 2>&1)
  rc=$?
  check 'Web Link の登録に失敗したら異常終了する' 1 "${rc}"
  check '失敗した KEY で止まり、次の issue を作らない' 1 "$(grep -c '^gh-title ' "${stub_log}")"
  check '手で貼れるように URL を出す' yes \
    "$([[ ${out} == *https://github.com/o/r/issues/1* ]] && echo yes || echo no)"
  rm -f "${stub_log}"
}

# 32. 既存でスキップした KEY には Web Link を張らない (作成していないので URL が無い)
test_to_gh_does_not_link_a_skipped_issue() {
  local stub_log fzf_selection
  local gh_existing_titles='[K-1] title of K-1'
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-gh
  check 'スキップした KEY には Web Link を張らない' 0 "$(grep -c '^jira ' "${stub_log}")"
  rm -f "${stub_log}"
}

# 33. to-gh が積むタスクの tracker は作成した issue の URL から組む。
#     `gh=` を書く経路はここだけなので、番号がずれると /task が別 issue に投稿する
test_to_gh_tracker_points_at_the_created_issue() {
  local stub_log fzf_selection
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-gh
  check '積んだタスクの tracker が作成した issue と Jira の KEY を指す' \
    '  - tracker: gh=o/r#1 jira=K-1' \
    "$(tracker_lines)"
  rm -f "${stub_log}"
}

# 34. tracker の owner/repo は作成先 repo。-R で別 repo に作ったときに cwd の repo を
#     書くと、/task が存在しない issue へ投稿しに行く
test_to_gh_tracker_uses_the_created_repo() {
  local stub_log fzf_selection
  local -a gh_repo_args=()
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  set_gh_repo_args -R owner/repo
  issue_select_open to-gh
  check '-R 指定時の tracker は作成先 repo を指す' \
    '  - tracker: gh=owner/repo#1 jira=K-1' \
    "$(tracker_lines)"
  rm -f "${stub_log}"
}

# 35. 想定外の形の URL からは tracker を組まない。当て推量で番号を作ると
#     /task が無関係な issue にコメントする
test_to_gh_stops_when_the_url_shape_is_unexpected() {
  local stub_log fzf_selection rc=0
  local gh_create_out=https://example.com/nope
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  (issue_select_open to-gh) >/dev/null 2>&1
  rc=$?
  check '想定外の URL 形式ならタスクを積まない' '' "$(tasks_lines)"
  check '想定外の URL 形式なら異常終了する' 1 "${rc}"
  rm -f "${stub_log}"
}

# 36. tracker は .tasks.md の目印。GitHub issue 本文には入れない
#     (本文へ入れると issue が自分自身を指す行を持つ)
test_to_gh_body_has_no_tracker_line() {
  local stub_log fzf_selection
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  issue_select_open to-gh
  check 'GitHub issue 本文には tracker 行を入れない' 0 \
    "$(sed -n '/^gh-title /,/^jira /p' "${stub_log}" | grep -c -- '- tracker:')"
  rm -f "${stub_log}"
}

# 37. タスク追記が落ちても Web Link は残る。逆順だと issue だけ出来て link も
#     タスクも付かず、次の -g は「既に issue がある」でスキップして復旧できない。
#     production と同じ errexit 下で確かめる (テスト既定の set -uo pipefail では
#     この経路の止まり方が変わる)
test_to_gh_links_before_appending_the_task() {
  local stub_log fzf_selection rc=0
  local tasks_rc=1
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  (
    set -euo pipefail
    issue_select_open to-gh
  ) >/dev/null 2>&1
  rc=$?
  check 'タスク追記が落ちても Web Link は張られている' \
    'jira issue link remote K-1 https://github.com/o/r/issues/1 [K-1] title of K-1' \
    "$(grep '^jira ' "${stub_log}")"
  check 'タスク追記が落ちたら異常終了する' 1 "${rc}"
  rm -f "${stub_log}"
}

# 38. tracker の `gh=owner/repo#NN` は host を持たず /task は github.com へ投稿する。
#     GHE の URL から組むと黙って別の issue を指すので、組まずに落とす
test_to_gh_rejects_a_non_github_host() {
  local stub_log fzf_selection rc=0
  local gh_create_out=https://ghe.example.com/o/r/issues/1
  stub_log=$(mktemp)
  fzf_selection=$(printf 'K-1\tsummary1')
  (issue_select_open to-gh) >/dev/null 2>&1
  rc=$?
  check 'github.com 以外の host ではタスクを積まない' '' "$(tasks_lines)"
  check 'github.com 以外の host なら異常終了する' 1 "${rc}"
  rm -f "${stub_log}"
}

main() {
  local pass=0 fail=0

  test_url_split_on_breakpoints_is_rejoined
  test_space_wrap_is_rejoined_with_one_space
  test_blank_line_breaks_the_join
  test_bullet_line_starts_a_new_item
  test_empty_bullet_is_dropped_and_breaks_the_join
  test_non_bullet_line_is_rejoined
  test_pre_description_lines_are_dropped
  test_prose_wrapped_after_punctuation_loses_the_space
  test_ansi_escapes_are_stripped
  test_key_is_prefixed_to_title
  test_no_key_leaves_title_untouched
  test_to_tasks_appends_each_selected_issue
  test_both_modes_enable_fzf_multi_select
  test_to_tasks_with_single_pick_appends_one_task
  test_open_mode_opens_one_tab_per_issue
  test_open_mode_removes_tmpdir_after_nvim_exits
  test_open_mode_cleans_up_when_nvim_fails
  test_cancelled_selection_calls_no_sink
  test_to_gh_creates_one_issue_per_selection
  test_to_gh_skips_existing_issue
  test_to_gh_creates_when_hit_lacks_key_prefix
  test_to_gh_passes_repo_override_to_both_calls
  test_gh_repo_args_are_empty_without_override
  test_to_gh_stops_when_the_search_fails
  test_to_gh_matches_the_key_only_as_a_title_prefix
  test_to_gh_pins_the_duplicate_search_query
  test_unknown_option_is_rejected
  test_to_gh_rejects_an_issue_without_summary
  test_to_gh_links_the_created_url_back_to_jira
  test_to_gh_stops_when_the_created_url_is_missing
  test_to_gh_stops_when_the_jira_link_fails
  test_to_gh_does_not_link_a_skipped_issue
  test_to_gh_tracker_points_at_the_created_issue
  test_to_gh_tracker_uses_the_created_repo
  test_to_gh_stops_when_the_url_shape_is_unexpected
  test_to_gh_body_has_no_tracker_line
  test_to_gh_links_before_appending_the_task
  test_to_gh_rejects_a_non_github_host

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
