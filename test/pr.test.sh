#!/usr/bin/env bash

# bin/pr のユニットテスト (実 git 使用)。
# bare の origin を持つ隔離 repo を作り、gh / llm / fzf / prp / open は偽物に差し替える。
#
# 検証対象:
#   * --base       : 引数 > $PR_TARGET_BRANCH > origin 上の一番近い分岐点。
#                    同じ近さなら develop > main > master。develop 上では main/master に絞る
#   * 生成         : llm へ渡す入力はコミットメッセージと diff stat。diff 本体は渡さない
#   * 一時 dir     : 成功したら消し、PR 作成に失敗したら -d で打ち直せるよう残す
#   * 引数ガード   : -c と -d の併用、main 上での実行は中断する
#
#   test/pr.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bin_dir=$(cd "${script_dir}/../bin" && pwd)

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
  cat >"${fakebin}/llm" <<'EOF'
#!/usr/bin/env bash
cat >"${FAKE_LOG}/llm_input"
echo '{"title": "generated title", "body": "generated body"}'
EOF
  printf '#!/usr/bin/env bash\ncat\n' >"${fakebin}/prp"
  printf '#!/usr/bin/env bash\nhead -1 | cut -f3\n' >"${fakebin}/fzf"
  printf '#!/usr/bin/env bash\n' >"${fakebin}/open"
  chmod +x "${fakebin}"/*
}

# origin: main (A) => develop (B C) => origin/feature-a (D)。
# ローカルの作業ブランチは引数で作る。
new_repo() {
  origin="${tmproot}/origin.git"
  repo="${tmproot}/repo"
  trash "${origin}" "${repo}" >/dev/null 2>&1
  git init -q --bare "${origin}"
  git init -q -b main "${repo}"
  git -C "${repo}" config user.email t@t
  git -C "${repo}" config user.name t
  git -C "${repo}" remote add origin "${origin}"
  commit f 'commit A'
  git -C "${repo}" push -q origin main
  git -C "${repo}" checkout -q -b develop
  commit f 'commit B'
  commit f 'commit C'
  git -C "${repo}" push -q origin develop
  git -C "${repo}" checkout -q -b feature-a
  commit g 'commit D'
  git -C "${repo}" push -q origin feature-a
  git -C "${repo}" checkout -q develop
}

# ${repo} で pr を実行する (stdin は tty でない)。stdout だけ返す。
run_pr() {
  (cd "${repo}" && PATH="${fakebin}:${bin_dir}:${PATH}" FAKE_LOG="${tmproot}" \
    TMPDIR="${tmproot}/tmp" "${bin_dir}/pr" "$@" </dev/null 2>/dev/null)
}

test_base_nearest_is_develop() {
  new_repo
  git -C "${repo}" checkout -q -b feature-b develop
  commit h 'commit E'
  check "develop から切った feature は origin/develop" "origin/develop" "$(run_pr --base)"
}

test_base_stacked_feature() {
  new_repo
  git -C "${repo}" checkout -q -b feature-c feature-a
  commit h 'commit E'
  check "feature-a から切った feature は origin/feature-a" "origin/feature-a" "$(run_pr --base)"
}

test_base_tie_prefers_develop() {
  new_repo
  git -C "${repo}" push -q origin develop:zz-same-as-develop
  git -C "${repo}" checkout -q -b feature-b develop
  commit h 'commit E'
  check "同じ分岐点なら develop を優先" "origin/develop" "$(run_pr --base)"
}

test_base_on_develop_is_main() {
  new_repo
  commit h 'commit E'
  check "develop 上では feature を無視して origin/main" "origin/main" "$(run_pr --base)"
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

test_guard_compact_with_dir() {
  new_repo
  mkdir -p "${tmproot}/parts"
  echo t >"${tmproot}/parts/title"
  echo b >"${tmproot}/parts/body"
  run_pr -c -d "${tmproot}/parts" origin/main >/dev/null
  check "-c と -d の併用は中断" "1" "$?"
}

test_generate_from_commits_and_stat() {
  new_repo
  git -C "${repo}" checkout -q -b feature-b develop
  commit h 'commit E' 'because of reason E'
  mkdir -p "${tmproot}/tmp"
  run_pr origin/develop >/dev/null
  local input="${tmproot}/llm_input"
  check "llm 入力にコミット body が載る" "1" "$(grep -c 'because of reason E' "${input}")"
  check "llm 入力に diff stat が載る" "1" "$(grep -c '1 file changed' "${input}")"
  check "llm 入力に diff 本体は載らない" "0" "$(grep -c '^+commit E' "${input}")"
  check "生成した title で PR を作る" "1" "$(grep -cx 'generated title' "${tmproot}/gh_args")"
  check "body にコミット一覧が付く" "1" "$(grep -c '^- .* commit E$' "${tmproot}/gh_body")"
  check "成功したら一時 dir を消す" "0" "$(find "${tmproot}/tmp" -mindepth 1 | wc -l)"
}

test_keep_parts_on_failure() {
  new_repo
  git -C "${repo}" checkout -q -b feature-b develop
  commit h 'commit E'
  trash "${tmproot}/tmp" >/dev/null 2>&1
  mkdir -p "${tmproot}/tmp"
  FAKE_GH_FAIL=1 run_pr -c origin/develop >/dev/null
  check "PR 作成に失敗したら中断" "1" "$?"
  check "失敗したら parts を残す" "1" "$(find "${tmproot}/tmp" -name title | wc -l)"
}

main() {
  pass=0 fail=0
  tmproot=$(mktemp -d)
  trap 'trash "${tmproot}" >/dev/null 2>&1' EXIT
  make_fakebin
  test_base_nearest_is_develop
  test_base_stacked_feature
  test_base_tie_prefers_develop
  test_base_on_develop_is_main
  test_base_env_and_arg
  test_guard_main
  test_guard_compact_with_dir
  test_generate_from_commits_and_stat
  test_keep_parts_on_failure
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
