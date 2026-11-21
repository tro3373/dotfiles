#!/usr/bin/env bash

# bin/pr のユニットテスト (実 git 使用)。
# bare の origin を持つ隔離 repo を作り、gh / open は偽物に差し替える。
#
# 検証対象:
#   * --base       : 引数 > $PR_TARGET_BRANCH > origin/develop (あり、かつ develop 上でない)
#                    > origin の default branch。分岐点は見ない
#   * title        : -t > commit が 1 件ならその件名 > "Merge <head> to <base>"
#   * body         : -b > "<head> => <base>" の 1 行。-i は空行を挟んで関連 Issue の節を末尾に足す
#   * 末尾改行     : -t・-b の末尾改行は落とす。gh へ渡す body は改行 1 つで終える
#   * commit 無し  : PR を作らず exit 0
#   * PR 作成失敗  : 中断する
#   * 引数ガード   : 未知のオプション、main 上での実行は中断する
#
#   bin/test/test-pr.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bin_dir=$(cd "${script_dir}/.." && pwd)

# desc / expected / actual を比較し、main の pass・fail カウンタを更新する。
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

# ${repo} に $1 を書いて件名 $2・本文 $3 で commit する。
commit() {
  echo "$2" >"${repo}/$1"
  git -C "${repo}" add -A
  git -C "${repo}" commit -qm "$2" -m "${3:-}"
}

# 偽コマンド。gh は受けた引数と body を記録し、FAKE_GH_FAIL=1 なら失敗する。
make_fakebin() {
  fakebin="${tmproot}/fakebin"
  mkdir -p "${fakebin}"
  cat >"${fakebin}/gh" <<'EOF'
#!/usr/bin/env bash
if [[ $1 == pr && $2 == create ]]; then
  [[ ${FAKE_GH_FAIL:-0} -eq 1 ]] && exit 1
  printf '%s\n' "$@" >"${FAKE_LOG}/gh_args"
  cat >"${FAKE_LOG}/gh_body"
  exit 0
fi
[[ $1 == pr && $2 == view ]] && echo "https://example.invalid/pr/1"
EOF
  printf '#!/usr/bin/env bash\n' >"${fakebin}/open"
  chmod +x "${fakebin}"/*
}

# ${repo} に origin を付けて A を push する。origin の HEAD は default branch $1。
init_repo() {
  local default_branch="$1"
  origin="${tmproot}/origin.git"
  repo="${tmproot}/repo"
  trash "${origin}" "${repo}" >/dev/null 2>&1
  trash "${tmproot}/gh_args" "${tmproot}/gh_body" >/dev/null 2>&1
  git init -q --bare -b "${default_branch}" "${origin}"
  git init -q -b "${default_branch}" "${repo}"
  git -C "${repo}" config user.email t@t
  git -C "${repo}" config user.name t
  git -C "${repo}" remote add origin "${origin}"
  commit f 'commit A'
  git -C "${repo}" push -q origin "${default_branch}"
}

# origin: main (A) => develop (B C) => origin/feature-a (D)。
# ローカルの作業ブランチは引数で作る。
new_repo() {
  init_repo main
  git -C "${repo}" checkout -q -b develop
  commit f 'commit B'
  commit f 'commit C'
  git -C "${repo}" push -q origin develop
  git -C "${repo}" checkout -q -b feature-a
  commit g 'commit D'
  git -C "${repo}" push -q origin feature-a
  git -C "${repo}" checkout -q develop
}

# develop の無い origin。default branch は $1。
new_repo_without_develop() {
  init_repo "$1"
  git -C "${repo}" checkout -q -b feature-a
  commit g 'commit D'
  git -C "${repo}" push -q origin feature-a
}

# ${repo} で pr を実行する (stdin は tty でない)。stdout だけ返す。
run_pr() {
  (cd "${repo}" && PATH="${fakebin}:${bin_dir}:${PATH}" FAKE_LOG="${tmproot}" \
    "${bin_dir}/pr" "$@" </dev/null 2>/dev/null)
}

test_base_feature_from_develop() {
  new_repo
  git -C "${repo}" checkout -q -b feature-b develop
  commit h 'commit E'
  check "develop から切った feature は origin/develop" "origin/develop" "$(run_pr --base)"
}

test_base_stacked_feature() {
  new_repo
  git -C "${repo}" checkout -q -b feature-c feature-a
  commit h 'commit E'
  check "feature-a から切った feature も origin/develop" "origin/develop" "$(run_pr --base)"
}

test_base_on_develop_is_main() {
  new_repo
  commit h 'commit E'
  check "develop 上では origin/main" "origin/main" "$(run_pr --base)"
}

test_base_without_develop() {
  new_repo_without_develop main
  check "origin/develop が無ければ origin/main" "origin/main" "$(run_pr --base)"
}

test_base_default_branch_is_trunk() {
  new_repo_without_develop trunk
  check "default branch が trunk なら origin/trunk" "origin/trunk" "$(run_pr --base)"
}

test_base_env_and_arg() {
  new_repo
  git -C "${repo}" checkout -q -b feature-b develop
  commit h 'commit E'
  check "PR_TARGET_BRANCH を優先" "origin/main" "$(PR_TARGET_BRANCH=origin/main run_pr --base)"
  check "引数を最優先" "origin/feature-a" "$(PR_TARGET_BRANCH=origin/main run_pr --base origin/feature-a)"
}

test_guard_main() {
  new_repo
  git -C "${repo}" checkout -q main
  run_pr --base >/dev/null
  check "main 上では中断" "1" "$?"
}

test_guard_unknown_option() {
  new_repo
  git -C "${repo}" checkout -q -b feature-b develop
  commit h 'commit E'
  run_pr -c origin/develop >/dev/null
  check "未知のオプションは中断" "1" "$?"
  check "未知のオプションは usage を出す" "1" "$(run_pr -c origin/develop | grep -c '^  Usage:')"
  check "未知のオプションでは PR を作らない" "0" "$(find "${tmproot}" -maxdepth 1 -name gh_args | wc -l)"
}

test_guard_on_default_branch() {
  new_repo_without_develop trunk
  git -C "${repo}" checkout -q trunk
  commit h 'commit E'
  run_pr >/dev/null
  check "default branch 上では中断" "1" "$?"
  check "default branch 上では push しない" "1" "$(git -C "${origin}" rev-list --count trunk)"
}

test_guard_develop_without_tty() {
  new_repo
  commit h 'commit E'
  run_pr >/dev/null
  check "develop 上は tty が無ければ中断" "1" "$?"
  check "develop の確認で止めたら push しない" "3" "$(git -C "${origin}" rev-list --count develop)"
}

test_generate_head_branch() {
  new_repo
  run_pr feature-a origin/develop >/dev/null
  check "head 指定なら origin の head の件名が title" "1" "$(grep -cx 'commit D' "${tmproot}/gh_args")"
  check "head 指定ならその branch から PR を作る" "1" "$(grep -cx 'feature-a' "${tmproot}/gh_args")"
  check "head 指定でも body は base に origin/ が付かない 1 行" "feature-a => develop" "$(cat "${tmproot}/gh_body")"
}

# feature-b を develop から切り、commit E (body 付き) を 1 件積む。
setup_one_commit() {
  new_repo
  git -C "${repo}" checkout -q -b feature-b develop
  commit h 'commit E' 'because of reason E'
}

test_generate_one_commit() {
  setup_one_commit
  run_pr origin/develop >/dev/null
  check "commit が 1 件なら件名が title" "1" "$(grep -cx 'commit E' "${tmproot}/gh_args")"
  check "body は head => base の 1 行" "feature-b => develop" "$(cat "${tmproot}/gh_body")"
  check "Issue 指定が無ければ関連 Issue は付かない" "0" "$(grep -c '関連Issue' "${tmproot}/gh_body")"
}

test_generate_several_commits() {
  setup_one_commit
  commit i 'commit F'
  run_pr origin/develop >/dev/null
  check "commit が複数なら Merge title" "1" "$(grep -cx 'Merge feature-b to develop' "${tmproot}/gh_args")"
  check "commit が複数でも body は head => base の 1 行" "feature-b => develop" "$(cat "${tmproot}/gh_body")"
}

test_generate_issue() {
  setup_one_commit
  run_pr -i 12 origin/develop >/dev/null
  check "-i で関連 Issue が付く" "1" "$(grep -cx -- '- #12' "${tmproot}/gh_body")"
  check "-i でも body の 1 行目は head => base" "feature-b => develop" "$(head -n 1 "${tmproot}/gh_body")"
  check "-i は 1 行目の後に空行を挟んで関連 Issue の節を足す" \
    "$(printf 'feature-b => develop\n\n## 関連Issue\n\n- #12')" "$(cat "${tmproot}/gh_body")"
}

test_generate_trailing_newlines() {
  setup_one_commit
  run_pr -t $'my title\n\n' -b $'my body\n\n' -i 12 origin/develop >/dev/null
  check "-t の末尾改行は落とす" "--body-file" "$(grep -A1 -x 'my title' "${tmproot}/gh_args" | sed -n 2p)"
  check "-b の末尾改行は落とし、空行 1 つで関連 Issue を足す" \
    "$(printf 'my body\n\n## 関連Issue\n\n- #12')" "$(cat "${tmproot}/gh_body")"
  check "gh へ渡す body は改行 1 つで終える" "5" "$(wc -l <"${tmproot}/gh_body")"
}

test_generate_override() {
  setup_one_commit
  run_pr -t 'my title' -b 'my body' -i 12 origin/develop >/dev/null
  check "-t が title になる" "1" "$(grep -cx 'my title' "${tmproot}/gh_args")"
  check "-b が body になる" "1" "$(grep -cx 'my body' "${tmproot}/gh_body")"
  check "-b なら既定の 1 行は付かない" "0" "$(grep -c 'feature-b => develop' "${tmproot}/gh_body")"
  check "-b でも -i は付く" "1" "$(grep -cx -- '- #12' "${tmproot}/gh_body")"
}

test_generate_no_commits() {
  new_repo
  git -C "${repo}" checkout -q -b feature-b develop
  run_pr origin/develop >/dev/null
  check "commit が無ければ exit 0" "0" "$?"
  check "commit が無ければ PR を作らない" "0" "$(find "${tmproot}" -maxdepth 1 -name gh_args | wc -l)"
}

test_create_failure() {
  setup_one_commit
  FAKE_GH_FAIL=1 run_pr origin/develop >/dev/null
  check "PR 作成に失敗したら中断" "1" "$?"
}

main() {
  pass=0 fail=0
  tmproot=$(mktemp -d)
  trap 'trash "${tmproot}" >/dev/null 2>&1' EXIT
  make_fakebin
  test_base_feature_from_develop
  test_base_stacked_feature
  test_base_on_develop_is_main
  test_base_without_develop
  test_base_default_branch_is_trunk
  test_base_env_and_arg
  test_guard_main
  test_guard_unknown_option
  test_guard_on_default_branch
  test_guard_develop_without_tty
  test_generate_head_branch
  test_generate_one_commit
  test_generate_several_commits
  test_generate_issue
  test_generate_override
  test_generate_trailing_newlines
  test_generate_no_commits
  test_create_failure
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
