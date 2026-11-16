#!/usr/bin/env bash

# bin/git_branch_clean のテスト。bare の origin と、別 clone からの push で
# 「ローカルの main は古いまま origin/main だけ進んだ」状態を作って検証する。
# fzf は PATH 先頭の偽物に差し替える (FZF_PICK に一致する行だけ選ぶ)。
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

test_local() {
  check "dry-run: origin/main 基準で merge 済みを出す。保護・checkout 中・未 merge・gone は出ない" \
    "git branch -D feat/merged
git branch -D feature/release-x" "$(clean | sort)"

  check "-g: gone も出す" \
    "git branch -D feat/merged
git branch -D feat/squash
git branch -D feature/release-x" "$(clean -g | sort)"

  check "dry-run はブランチを消さない" \
    "develop feat/current feat/local feat/merged feat/squash feat/wip feat/wt feature/release-x main" "$(branches)"
}

test_interactive() {
  check "-i: merged と gone をラベル付きで fzf に渡す" \
    "gone	feat/squash
merged	feat/merged
merged	feature/release-x" "$(
      FZF_PICK='^$' FZF_LOG="${tmp}/fzf.in" clean -i >/dev/null
      sort "${tmp}/fzf.in"
    )"

  check "-i: fzf で選んだものだけ消す" \
    "git branch -D feat/squash" "$(FZF_PICK='squash' clean -i)"

  check "-i: 何も選ばなければ何も消さず正常終了" \
    "0:" "$(
      out=$(FZF_PICK='^$' clean -i -e)
      echo "$?:${out}"
    )"
}

test_execute() {
  clean -e >/dev/null
  check "-e: base 以外を checkout 中でも merge 済みを消す" \
    "develop feat/current feat/local feat/squash feat/wip feat/wt main" "$(branches)"
}

test_remote() {
  check "-r: origin の merge 済みを出す。HEAD・保護・未 merge は出ない" \
    "git push origin --delete feat/current
git push origin --delete feat/merged
git push origin --delete feat/wt
git push origin --delete feature/release-x" "$(clean -r | sort)"

  clean -r -e >/dev/null
  check "-r -e: origin から消す" "develop feat/wip main" "$(remote_branches)"
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
input=$(cat)
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
  test_local
  test_interactive
  test_execute
  test_remote
  test_unknown_option
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
