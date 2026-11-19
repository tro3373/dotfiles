#!/usr/bin/env bash

# bin/git_branch_clean のテスト。bare の origin と、別 clone からの push で
# 「ローカルの main は古いまま origin/main だけ進んだ」状態を作って検証する。
# fzf は PATH 先頭の偽物に差し替える (--header-lines の行数を除き、FZF_PICK に一致する行だけ選ぶ)。
#
#   test/git_branch_clean.test.sh

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

# origin/main に merge した branch を、origin 側にも残した状態で作る
merged_branch() {
  local name="$1"
  g "${other}" checkout -q -b "${name}" main
  commit "${other}" "${name}"
  g "${other}" push -q origin "${name}"
  g "${other}" checkout -q main
  g "${other}" merge -q --no-ff -m "merge ${name}" "${name}"
}

# ローカル:
#   feat/merged, feature/release-x  origin/main に merge 済み (ローカル main は未 pull)
#   feat/squash                     squash merge 済みで origin から削除 (gone)
#   feat/wip                        未 merge、origin あり
#   feat/local                      未 merge、upstream なし
#   feat/wt                         merge 済みだが別 worktree で checkout 中
#   feat/current                    merge 済みで今 checkout 中
#   develop                         merge 済みだが保護
# tag:
#   backup/feat/old-20260101-000000  元のブランチ feat/old が無い
#   backup/feat/wip-20260101-000000  元のブランチ feat/wip が残っている
#   backup/feat/wip                  日時なし。元のブランチ feat/wip が残っている
#   backup/feat/wip-1-2              日時ではない数字。元のブランチ feat/wip-1-2 が無い
#   v1.0                             backup ではない
setup() {
  origin="${tmp}/origin.git"
  repo="${tmp}/repo"
  other="${tmp}/other"
  git init -q --bare -b main "${origin}"
  git init -q -b main "${repo}"
  commit "${repo}" init
  g "${repo}" remote add origin "${origin}"
  g "${repo}" push -q -u origin main
  g "${origin}" symbolic-ref HEAD refs/heads/main
  g "${repo}" remote set-head origin main
  git clone -q "${origin}" "${other}"

  local b
  for b in feat/merged feature/release-x feat/wt feat/current develop; do
    merged_branch "${b}"
  done
  g "${other}" checkout -q -b feat/squash main
  commit "${other}" squash
  g "${other}" push -q origin feat/squash
  g "${other}" checkout -q -b feat/wip main
  commit "${other}" wip
  g "${other}" push -q origin feat/wip
  g "${other}" push -q origin main

  g "${repo}" fetch -q
  for b in feat/merged feature/release-x feat/wt feat/current develop feat/squash feat/wip; do
    g "${repo}" branch -q --track "${b}" "origin/${b}"
  done
  g "${repo}" checkout -q -b feat/local main
  commit "${repo}" local
  g "${repo}" checkout -q feat/current
  g "${repo}" worktree add -q "${tmp}/wt" feat/wt
  g "${other}" push -q origin --delete feat/squash
  g "${repo}" tag backup/feat/old-20260101-000000 main
  g "${repo}" tag backup/feat/wip-20260101-000000 feat/wip
  g "${repo}" tag backup/feat/wip feat/wip
  g "${repo}" tag backup/feat/wip-1-2 feat/wip
  g "${repo}" tag v1.0 main
}

clean() {
  (cd "${repo}" && "${bin}" "$@" 2>/dev/null)
}

branches() {
  g "${repo}" branch --format '%(refname:short)' | sort | paste -sd ' '
}

remote_branches() {
  g "${origin}" branch --format '%(refname:short)' | sort | paste -sd ' '
}

tags() {
  g "${repo}" tag -l | sort | paste -sd ' '
}

# fzf に渡った候補の `<state> <kind> <name>`
offered() {
  FZF_PICK='^$' FZF_LOG="${tmp}/fzf.in" clean "$@" >/dev/null
  cut -f1-3 "${tmp}/fzf.in" | tr '\t' ' '
}

pick() {
  printf '%s\t%s\t%s\t' "$@"
}

test_safe_view() {
  check "既定: 🟢 だけを local・remote・tag の順に出す。保護・checkout 中・HEAD は出ない" \
    "safe local feat/merged
safe local feat/squash
safe local feature/release-x
safe remote feat/current
safe remote feat/merged
safe remote feat/wt
safe remote feature/release-x
safe tag backup/feat/old-20260101-000000
safe tag backup/feat/wip-1-2" "$(offered)"
}

test_all_view() {
  check "-a: 🟢 の後ろに ⚠️ (未 merge・ブランチが残る backup tag) も出す。backup 以外の tag は出ない" \
    "safe local feat/merged
safe local feat/squash
safe local feature/release-x
safe remote feat/current
safe remote feat/merged
safe remote feat/wt
safe remote feature/release-x
safe tag backup/feat/old-20260101-000000
safe tag backup/feat/wip-1-2
risky local feat/local
risky local feat/wip
risky remote feat/wip
risky tag backup/feat/wip
risky tag backup/feat/wip-20260101-000000" "$(offered -a)"
}

test_base() {
  check "base に渡したブランチは local も remote も出ない" \
    "" "$(offered -a feat/wip | grep -E '^[a-z]+ (local|remote) feat/wip$')"
}

test_display() {
  offered -a >/dev/null
  check "表示: 状態と種類の絵文字・種類名・名前・理由" \
    "🟢 💻 local  feat/squash gone (upstream が消えた)
🟢 ☁️ remote feat/merged merged
🟢 🔖 tag    backup/feat/old-20260101-000000 ブランチ無し
⚠️ 💻 local  feat/wip 未 merge
⚠️ 🔖 tag    backup/feat/wip-20260101-000000 ブランチあり" "$(
      cut -f5 "${tmp}/fzf.in" | sed -e 's/\x1b\[[0-9]*m//g' -e 's/  *\(merged\|gone\|未\|ブランチ\)/ \1/' |
        grep -E 'feat/squash|remote feat/merged|[0-9]{6} |local  feat/wip'
    )"
}

test_nothing_picked() {
  check "何も選ばなければ何も消さず正常終了" \
    "0:develop feat/current feat/local feat/merged feat/squash feat/wip feat/wt feature/release-x main" "$(
      FZF_PICK='^$' clean >/dev/null
      echo "$?:$(branches)"
    )"
}

test_delete_safe() {
  FZF_PICK="$(pick safe local feat/squash)|$(pick safe tag backup/feat/old-20260101-000000)|$(pick safe remote feat/merged)" \
    clean </dev/null >/dev/null
  check "🟢 は確認なしで消す: local (base 以外を checkout 中でも)" \
    "develop feat/current feat/local feat/merged feat/wip feat/wt feature/release-x main" "$(branches)"
  check "🟢 は確認なしで消す: tag" "backup/feat/wip backup/feat/wip-1-2 backup/feat/wip-20260101-000000 v1.0" "$(tags)"
  check "🟢 は確認なしで消す: remote" \
    "develop feat/current feat/wip feat/wt feature/release-x main" "$(remote_branches)"
}

test_delete_risky() {
  check "⚠️ は y 以外で消さず終了コード 1" \
    "1:backup/feat/wip-20260101-000000" "$(
      FZF_PICK="$(pick risky tag backup/feat/wip-20260101-000000)" clean -a <<<n >/dev/null
      echo "$?:$(tags | grep -o 'backup/feat/wip-20260101-000000')"
    )"

  FZF_PICK="$(pick risky tag backup/feat/wip-20260101-000000)|$(pick risky local feat/local)|$(pick risky remote feat/wip)" \
    clean -a <<<y >/dev/null
  check "⚠️ は y で消す: local" \
    "develop feat/current feat/merged feat/wip feat/wt feature/release-x main" "$(branches)"
  check "⚠️ は y で消す: tag" "backup/feat/wip backup/feat/wip-1-2 v1.0" "$(tags)"
  check "⚠️ は y で消す: remote" \
    "develop feat/current feat/wt feature/release-x main" "$(remote_branches)"
}

test_unknown_option() {
  check "未知のオプションは終了コード 2" "2" "$(
    clean -x >/dev/null
    echo "$?"
  )"
}

install_fake_fzf() {
  mkdir -p "${tmp}/bin"
  cat >"${tmp}/bin/fzf" <<'EOF'
#!/usr/bin/env bash
header_lines=0
while [[ $# -gt 0 ]]; do
  [[ $1 == --header-lines ]] && header_lines="$2"
  shift
done
input=$(tail -n "+$((header_lines + 1))")
[[ -n ${FZF_LOG:-} ]] && printf '%s\n' "${input}" >"${FZF_LOG}"
selected=$(printf '%s\n' "${input}" | grep -E "${FZF_PICK}")
[[ -z ${selected} ]] && exit 1
printf '%s\n' "${selected}"
EOF
  chmod +x "${tmp}/bin/fzf"
  # lint-ignore: uppercase PATH は環境変数
  PATH="${tmp}/bin:${PATH}"
}

main() {
  local pass=0 fail=0 tmp bin
  bin="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/git_branch_clean"
  tmp=$(mktemp -d)
  # shellcheck disable=SC2064 # local 変数なので定義時に展開する
  trap "rm -rf '${tmp}'" EXIT
  # lint-ignore: uppercase git が読む環境変数
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  install_fake_fzf
  setup
  test_safe_view
  test_all_view
  test_base
  test_display
  test_nothing_picked
  test_delete_safe
  test_delete_risky
  test_unknown_option
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
