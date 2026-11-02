#!/usr/bin/env bash

# bin/gen_task_title_and_branch のユニットテスト (prp と llm を fake に差し替え。NW 不要)。
#
# 担保したいのは、LLM の出力のうち branch / name / title として使えるものだけを通すこと。
# 改行入りの値は task.md の front matter や一覧を壊すので拒む。
#
#   test/gen_task_title_and_branch.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
gen_bin=$(cd "${script_dir}/../bin" && pwd)/gen_task_title_and_branch

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
  tmproot=$(mktemp -d)
  fakebin="${tmproot}/bin"
  llm_out="${tmproot}/llm.out"
  # prp と llm はパイプで同時に動くので、書く順が決まらない。ログを分ける
  prp_log="${tmproot}/prp.log"
  calls_log="${tmproot}/llm.log"
  llm_exit=0
  mkdir -p "${fakebin}"
  # prp の fake: 引数を残し、本文に prompt の印を付けて流す
  cat >"${fakebin}/prp" <<EOS
#!/usr/bin/env bash
echo "prp \$*" >>"${prp_log}"
echo PROMPT
cat
EOS
  # llm の fake: 引数と受けた入力を残し、llm.out を出す
  cat >"${fakebin}/llm" <<EOS
#!/usr/bin/env bash
echo "llm \$*" >>"${calls_log}"
cat >>"${calls_log}"
cat "${llm_out}"
exit "\${FAKE_LLM_EXIT:-0}"
EOS
  chmod +x "${fakebin}/prp" "${fakebin}/llm"
}

run() {
  rm -f "${prp_log}" "${calls_log}"
  out=$(printf '%s' "$1" | PATH="${fakebin}:${PATH}" XDG_CONFIG_HOME="${tmproot}/config" \
    FAKE_LLM_EXIT="${llm_exit}" "${gen_bin}" 2>/dev/null)
  rc=$?
}

test_outputs_valid_meta() {
  printf '%s' '{"branch":"feature/x","name":"x","title":"x を直す"}' >"${llm_out}"
  run $'- [ ] x を直す\n  - 詳細'
  check 'valid: JSON をそのまま出す' '{"branch":"feature/x","name":"x","title":"x を直す"}' "${out}"
  check 'valid: 終了コード 0' '0' "${rc}"
  check 'valid: prompt を付けた本文を groq で生成する' \
    $'prp -ne gen-task-title-and-branch.md$\nllm -c tgpt -p groq -fc claude\nPROMPT\n- [ ] x を直す\n  - 詳細' \
    "$(cat "${prp_log}" "${calls_log}")"
}

# terms.tsv (日本語 TAB 英語 TAB 許す語) があれば、英語の技術用語を日本語に置き換えない指示を prompt の前に付ける
test_adds_terms_rule() {
  printf '%s' '{"branch":"feature/x","name":"x","title":"x"}' >"${llm_out}"
  mkdir -p "${tmproot}/config/tasks"
  printf '# comment\n秘密\tsecret\t秘密鍵,秘密保持\n鉤\thook\n' >"${tmproot}/config/tasks/terms.tsv"
  run 'x'
  rm -r "${tmproot}/config"
  local prp_call
  prp_call=$(cat "${prp_log}")
  check 'terms: 日本語 => 英語 の対応を渡す' '1' "$([[ ${prp_call} == *'- 秘密 => secret (ok: 秘密鍵, 秘密保持)'* ]] && echo 1 || echo 0)"
  check 'terms: 許す語の無い行も渡す' '1' "$([[ ${prp_call} == *'- 鉤 => hook'* && ${prp_call} != *'- 鉤 => hook (ok'* ]] && echo 1 || echo 0)"
  check 'terms: コメント行は渡さない' '0' "$([[ ${prp_call} == *comment* ]] && echo 1 || echo 0)"
  check 'terms: prompt の前に付ける (-pm)' '1' "$([[ ${prp_call} == 'prp -pm '* ]] && echo 1 || echo 0)"
}

test_rejects_invalid_meta() {
  local meta
  for meta in 'not json' '{"branch":"b","name":"n"}' '{"branch":"b","name":"","title":"t"}' \
    '{"branch":"b","name":1,"title":"t"}' '["b","n","t"]' \
    '{"branch":"b","name":"n","title":"t"}{"branch":"b","name":"n","title":"t"}' \
    '{"branch":"b","name":"a\nb","title":"t"}' '{"branch":"b\tc","name":"n","title":"t"}'; do
    printf '%s' "${meta}" >"${llm_out}"
    run 'x'
    check "invalid (${meta}): 終了コード 1" '1' "${rc}"
    check "invalid (${meta}): 何も出さない" '' "${out}"
  done
}

test_fails_when_llm_fails() {
  printf '%s' '{"branch":"b","name":"n","title":"t"}' >"${llm_out}"
  llm_exit=3
  run 'x'
  llm_exit=0
  check 'llm-failed: 終了コード 1' '1' "${rc}"
  check 'llm-failed: 何も出さない' '' "${out}"
}

main() {
  set -uo pipefail
  setup
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0

  test_outputs_valid_meta
  test_adds_terms_rule
  test_rejects_invalid_meta
  test_fails_when_llm_fails

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
