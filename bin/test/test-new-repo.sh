#!/usr/bin/env bash

# bin/new-repo のテスト。実 ghq / git を使い、gh だけ偽物に差し替える。
# 偽 gh は repo create で bare repo を作り、git の insteadOf で
# git@github.com: への push をその bare repo へ向ける。

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bin_dir=$(cd "${script_dir}/.." && pwd)

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

setup() {
  rm -rf "${tmproot}"
  mkdir -p "${tmproot}/fakebin" "${tmproot}/remotes" "${tmproot}/ghq"
  # lint-ignore: uppercase 子プロセス (ghq・git・偽 gh) へ渡す環境変数
  export GHQ_ROOT="${tmproot}/ghq" GIT_CONFIG_GLOBAL="${tmproot}/gitconfig" GIT_CONFIG_NOSYSTEM=1 \
    FAKE_REMOTES="${tmproot}/remotes" FAKE_GH_LOG="${tmproot}/gh.log" FAKE_GH_FAIL=0
  git config --global user.name t
  git config --global user.email t@t
  git config --global init.defaultBranch main
  git config --global url."${FAKE_REMOTES}/".insteadOf "git@github.com:"
  cat >"${tmproot}/fakebin/gh" <<'EOF'
#!/usr/bin/env bash
echo "$*" >>"$FAKE_GH_LOG"
case "$1 $2" in
  "api user") echo login-user ;;
  "api gitignore/templates")
    if [[ "$*" == *" -q "* ]]; then printf 'Go\nNode\nPython\n'; else echo '["Go","Node","Python"]'; fi
    ;;
  "api gitignore/templates/Go") printf '*.test\nvendor/\n' ;;
  "api licenses/mit") printf 'MIT License\n\nCopyright (c) [year] [fullname]\n' ;;
  "api licenses/apache-2.0") printf 'Apache License\nCopyright [yyyy] [name of copyright owner]\nappendix []\n' ;;
  "api licenses/"*) exit 1 ;;
  "repo create")
    [[ $FAKE_GH_FAIL -eq 1 ]] && exit 1
    git init -q --bare "$FAKE_REMOTES/$3.git"
    ;;
esac
EOF
  chmod +x "${tmproot}/fakebin/gh"
  # lint-ignore: uppercase 偽 gh と bin/new-repo を優先させる
  export PATH="${tmproot}/fakebin:${bin_dir}:${PATH}"
}

root_of() { git -C "$1" rev-list --max-parents=0 HEAD; }

remote_log() { git -C "${FAKE_REMOTES}/login-user/myrepo.git" log --reverse --format=%s main | paste -sd'|'; }

remote_file() { git -C "${FAKE_REMOTES}/login-user/myrepo.git" show "main:$1" 2>/dev/null; }

run_new_repo() {
  out=$(new-repo "$@" 2>/dev/null)
  rc=$?
}

test_bare_name_uses_gh_login() {
  setup
  run_new_repo myrepo
  local dir="${GHQ_ROOT}/github.com/login-user/myrepo"
  check "bare name: exit 0" 0 "${rc}"
  check "bare name: prints created path" "${dir}" "${out}"
  check "bare name: creates private repo by default" "repo create login-user/myrepo --private" "$(grep 'repo create' "${FAKE_GH_LOG}")"
  check "bare name: origin is SSH" "git@github.com:login-user/myrepo.git" "$(git -C "${dir}" config remote.origin.url)"
  check "bare name: root commit has no files" "" "$(git -C "${dir}" ls-tree -r "$(root_of "${dir}")")"
  check "bare name: pushed to remote main" "$(git -C "${dir}" rev-parse HEAD)" \
    "$(git -C "${FAKE_REMOTES}/login-user/myrepo.git" rev-parse main)"
  check "bare name: upstream is set" "origin/main" "$(git -C "${dir}" rev-parse --abbrev-ref '@{u}')"
}

test_owner_and_public() {
  setup
  run_new_repo --public my-org/legit-tool
  check "owner/public: exit 0" 0 "${rc}"
  check "owner/public: keeps given owner and name" "${GHQ_ROOT}/github.com/my-org/legit-tool" "${out}"
  check "owner/public: no login lookup" "" "$(grep 'api user' "${FAKE_GH_LOG}")"
  check "owner/public: creates public repo" "repo create my-org/legit-tool --public" "$(grep 'repo create' "${FAKE_GH_LOG}")"
}

test_gh_failure_removes_local_dir() {
  setup
  FAKE_GH_FAIL=1 run_new_repo myrepo
  check "gh failure: exit 1" 1 "${rc}"
  check "gh failure: local dir removed" "no" "$([[ -e ${GHQ_ROOT}/github.com/login-user/myrepo ]] && echo yes || echo no)"
}

test_rejects_bad_args() {
  setup
  run_new_repo
  check "no args: exit 1" 1 "${rc}"
  run_new_repo a b
  check "two args: exit 1" 1 "${rc}"
  run_new_repo --unknown a
  check "unknown option: exit 1" 1 "${rc}"
  run_new_repo -p a
  check "removed -p option: exit 1" 1 "${rc}"
  check "bad args: gh not called" "no" "$([[ -e ${FAKE_GH_LOG} ]] && echo yes || echo no)"
}

test_default_license_is_mit() {
  setup
  run_new_repo myrepo
  local year
  year=$(date +%Y)
  check "default license: commits root then LICENSE" "Initial empty commit|Add LICENSE" "$(remote_log)"
  check "default license: MIT with year and name filled" "MIT License

Copyright (c) ${year} t" "$(remote_file LICENSE)"
}

test_license_none() {
  setup
  run_new_repo --license none myrepo
  check "license none: only root commit" "Initial empty commit" "$(remote_log)"
  check "license none: no LICENSE" "" "$(remote_file LICENSE)"
}

test_license_apache() {
  setup
  run_new_repo --license apache-2.0 myrepo
  local year
  year=$(date +%Y)
  check "apache: fills its placeholders and keeps literal []" "Apache License
Copyright ${year} t
appendix []" "$(remote_file LICENSE)"
}

test_description_passed_to_gh() {
  setup
  run_new_repo --description "my tool" myrepo
  check "description: passed to gh repo create" "repo create login-user/myrepo --private --description my tool" "$(grep 'repo create' "${FAKE_GH_LOG}")"
}

test_gitignore_is_case_insensitive() {
  setup
  run_new_repo --gitignore go myrepo
  check "gitignore: exit 0" 0 "${rc}"
  check "gitignore: commit order" "Initial empty commit|Add .gitignore|Add LICENSE" "$(remote_log)"
  check "gitignore: content from resolved template" "*.test
vendor/" "$(remote_file .gitignore)"
  check "gitignore: root commit has no files" "" "$(git -C "${out}" ls-tree -r "$(root_of "${out}")")"
}

test_fetch_failure_leaves_nothing() {
  local label
  for label in "--gitignore rust" "--license bogus"; do
    setup
    # shellcheck disable=SC2086 # 意図した分割
    run_new_repo ${label} myrepo
    check "${label}: exit 1" 1 "${rc}"
    check "${label}: no local dir" "no" "$([[ -e ${GHQ_ROOT}/github.com/login-user/myrepo ]] && echo yes || echo no)"
    check "${label}: gh repo create not called" "" "$(grep 'repo create' "${FAKE_GH_LOG}")"
  done
}

main() {
  pass=0
  fail=0
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  test_bare_name_uses_gh_login
  test_owner_and_public
  test_gh_failure_removes_local_dir
  test_rejects_bad_args
  test_default_license_is_mit
  test_license_none
  test_license_apache
  test_description_passed_to_gh
  test_gitignore_is_case_insensitive
  test_fetch_failure_leaves_nothing
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
