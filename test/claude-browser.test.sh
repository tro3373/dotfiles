#!/usr/bin/env bash

# bin/claude-browser のユニットテスト。chrome を fake に差し替え、
# どの CHROME_PROFILE で呼ばれたかを見る。
#
#   test/claude-browser.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target_bin=$(cd "${script_dir}/../bin" && pwd)/claude-browser

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

new_fakebin() {
  fakebin="${tmproot}/bin"
  mkdir -p "${fakebin}"
  cat >"${fakebin}/chrome" <<'EOS'
#!/usr/bin/env bash
printf '%s %s\n' "${CHROME_PROFILE:-<none>}" "$*"
EOS
  chmod +x "${fakebin}/chrome"
}

run() {
  PATH="${fakebin}:${PATH}" "${target_bin}" "$@"
}

artifact_url=https://claude.ai/code/artifact/abc
other_url=https://example.com/

test_artifact_uses_artifact_profile() {
  check "Artifact は専用アカウントで開く" "art@ ${artifact_url}" \
    "$(CHROME_PROFILE=repo@ CLAUDE_ARTIFACT_CHROME_PROFILE=art@ run "${artifact_url}")"
}

test_short_artifact_url() {
  check "claude.ai/artifact/ も Artifact 扱い" "art@ https://claude.ai/artifact/x" \
    "$(CLAUDE_ARTIFACT_CHROME_PROFILE=art@ run https://claude.ai/artifact/x)"
}

test_other_follows_repo_profile() {
  check "Artifact 以外は repo の CHROME_PROFILE に従う" "repo@ ${other_url}" \
    "$(CHROME_PROFILE=repo@ CLAUDE_ARTIFACT_CHROME_PROFILE=art@ run "${other_url}")"
}

test_artifact_without_setting_follows_repo_profile() {
  check "専用アカウント未設定なら Artifact も repo に従う" "repo@ ${artifact_url}" \
    "$(CHROME_PROFILE=repo@ CLAUDE_ARTIFACT_CHROME_PROFILE='' run "${artifact_url}")"
}

main() {
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  pass=0
  fail=0
  new_fakebin

  test_artifact_uses_artifact_profile
  test_short_artifact_url
  test_other_follows_repo_profile
  test_artifact_without_setting_follows_repo_profile

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
