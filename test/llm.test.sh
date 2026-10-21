#!/usr/bin/env bash

# bin/llm のユニットテスト (tgpt / claude を fake に差し替え、NW 不要)。
#
# 担保したいのは:
#   * primary が失敗したら、primary の stdout を fallback の出力と混ぜない:
#     tgpt は API のエラー JSON を stdout へ出してから失敗する。
#     混ざると呼び出し側の JSON parse が壊れる (tasks の meta 生成)。
#   * primary が成功したら primary の出力だけを出し、fallback は呼ばない。
#   * claude はユーザ設定・MCP・tool・skill を読まずに起動する:
#     読むと 1 回ごとに数秒遅くなり、ユーザ向けの規約が出力に混ざる。
#
#   test/llm.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target_bin=$(cd "${script_dir}/../bin" && pwd)/llm

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

# tgpt / claude の偽物。
# tgpt: FAKE_TGPT_EXIT が 0 以外なら、エラー JSON を stdout へ出して失敗する。
# claude: 受け取った引数を 1 行ずつ FAKE_CLAUDE_LOG へ記録し、fallback の JSON を出す。
write_fake_bins() {
  fakebin="${tmproot}/bin"
  mkdir -p "${fakebin}"
  cat >"${fakebin}/tgpt" <<'FAKE'
#!/usr/bin/env bash
cat >/dev/null
if [[ ${FAKE_TGPT_EXIT:-0} -ne 0 ]]; then
  printf '%s\n' '{"error":{"message":"Invalid API Key"}}'
  echo 'Some error has occurred. Statuscode: 401' >&2
  exit "${FAKE_TGPT_EXIT}"
fi
printf '%s\n' '{"from":"tgpt"}'
FAKE
  cat >"${fakebin}/claude" <<'FAKE'
#!/usr/bin/env bash
cat >/dev/null
printf '[%s]\n' "$@" >>"${FAKE_CLAUDE_LOG}"
printf '%s\n' '{"from":"claude"}'
FAKE
  chmod +x "${fakebin}/tgpt" "${fakebin}/claude"
}

# llm -c tgpt -fc claude を実行し、stdout / stderr を ${out} / ${err} へ書き出す。
run_llm() {
  claude_log="${tmproot}/claude.log"
  out="${tmproot}/out"
  err="${tmproot}/err"
  : >"${claude_log}"
  echo 'prompt' |
    PATH="${fakebin}:${PATH}" FAKE_CLAUDE_LOG="${claude_log}" \
      "${target_bin}" -c tgpt -p groq -k dummy -fc claude >"${out}" 2>"${err}"
}

# 1. primary が失敗したら、stdout には fallback の出力だけが出る。
test_fallback_stdout_excludes_failed_primary() {
  FAKE_TGPT_EXIT=1 run_llm
  check 'fallback: exit zero' '0' "$?"
  check 'fallback: stdout is fallback output only' '{"from":"claude"}' "$(cat "${out}")"
  check 'fallback: failed primary output goes to stderr' \
    '1' "$(grep -qF 'Invalid API Key' "${err}" && echo 1 || echo 0)"
}

# 2. primary が成功したら primary の出力を出し、fallback を呼ばない。
test_primary_success_skips_fallback() {
  FAKE_TGPT_EXIT=0 run_llm
  check 'primary: exit zero' '0' "$?"
  check 'primary: stdout is primary output' '{"from":"tgpt"}' "$(cat "${out}")"
  check 'primary: fallback not called' '0' "$(grep -c . "${claude_log}")"
}

# 3. claude はユーザ設定・MCP・tool・skill を読まずに起動する。
test_claude_skips_user_environment() {
  FAKE_TGPT_EXIT=1 run_llm
  local args
  args=$(tr '\n' ' ' <"${claude_log}")
  check 'claude: no setting sources' '1' "$([[ ${args} == *'[--setting-sources] []'* ]] && echo 1 || echo 0)"
  check 'claude: strict mcp config' '1' "$([[ ${args} == *'[--strict-mcp-config]'* ]] && echo 1 || echo 0)"
  check 'claude: no tools' '1' "$([[ ${args} == *'[--tools] []'* ]] && echo 1 || echo 0)"
  check 'claude: no skills' '1' "$([[ ${args} == *'[--disable-slash-commands]'* ]] && echo 1 || echo 0)"
}

main() {
  set -uo pipefail
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0
  write_fake_bins

  test_fallback_stdout_excludes_failed_primary
  test_primary_success_skips_fallback
  test_claude_skips_user_environment

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
