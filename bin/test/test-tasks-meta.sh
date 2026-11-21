#!/usr/bin/env bash

# bin/tasks-meta のユニットテスト (llm を fake に差し替え。NW 不要)。
#
# 担保したいのは、naming.md に従わせて生成し、LLM の出力のうち branch / name / title / abbr として使えるものだけを通すこと。
# 改行入りの値は task.md の front matter や一覧を壊すので拒む。
#
#   bin/test/test-tasks-meta.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
gen_bin=$(cd "${script_dir}/.." && pwd)/tasks-meta

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
  calls_log="${tmproot}/llm.log"
  llm_exit=0
  mkdir -p "${fakebin}" "${tmproot}/config/tasks"
  printf 'NAMING RULES\n' >"${tmproot}/config/tasks/naming.md"
  # llm の fake: 引数と受けた入力を残し、llm.out を出す
  cat >"${fakebin}/llm" <<EOS
#!/usr/bin/env bash
echo "llm \$*" >>"${calls_log}"
cat >>"${calls_log}"
cat "${llm_out}"
exit "\${FAKE_LLM_EXIT:-0}"
EOS
  chmod +x "${fakebin}/llm"
}

run() {
  rm -f "${calls_log}"
  out=$(printf '%s' "$1" | PATH="${fakebin}:${PATH}" XDG_CONFIG_HOME="${tmproot}/config" \
    FAKE_LLM_EXIT="${llm_exit}" "${gen_bin}" 2>/dev/null)
  rc=$?
}

test_outputs_valid_meta() {
  printf '%s' '{"branch":"feature/x","name":"x","title":"x を直す","abbr":"a"}' >"${llm_out}"
  run $'- [ ] x を直す\n  - 詳細'
  check 'valid: JSON をそのまま出す' '{"branch":"feature/x","name":"x","title":"x を直す","abbr":"a"}' "${out}"
  check 'valid: 終了コード 0' '0' "${rc}"
  local call
  call=$(cat "${calls_log}")
  check 'valid: groq で生成する' 'llm -c tgpt -p groq -fc claude' "$(head -1 <<<"${call}")"
  check 'valid: naming.md を prompt に入れる' '1' "$([[ ${call} == *'NAMING RULES'* ]] && echo 1 || echo 0)"
  check 'valid: 本文を最後に入れる' $'-- Here is the content --\n\n- [ ] x を直す\n  - 詳細' "$(tail -4 <<<"${call}")"
}

test_fails_without_naming() {
  printf '%s' '{"branch":"feature/x","name":"x","title":"x","abbr":"a"}' >"${llm_out}"
  mv "${tmproot}/config/tasks/naming.md" "${tmproot}/naming.md"
  run 'x'
  mv "${tmproot}/naming.md" "${tmproot}/config/tasks/naming.md"
  check 'no-naming: 終了コード 1' '1' "${rc}"
  check 'no-naming: llm を呼ばない' '0' "$([[ -f ${calls_log} ]] && echo 1 || echo 0)"
}

# terms.tsv (日本語 TAB 英語 TAB 許す語) があれば、英語の技術用語を日本語に置き換えない指示を prompt の前に付ける
test_adds_terms_rule() {
  printf '%s' '{"branch":"feature/x","name":"x","title":"x","abbr":"a"}' >"${llm_out}"
  printf '# comment\n鍵束\tkeyring\t鍵束管理,鍵束番号\n鉤\thook\n' >"${tmproot}/config/tasks/terms.tsv"
  run 'x'
  rm "${tmproot}/config/tasks/terms.tsv"
  local call
  call=$(cat "${calls_log}")
  check 'terms: 日本語 => 英語 の対応を渡す' '1' "$([[ ${call} == *'- 鍵束 => keyring (ok: 鍵束管理, 鍵束番号)'* ]] && echo 1 || echo 0)"
  check 'terms: 許す語の無い行も渡す' '1' "$([[ ${call} == *'- 鉤 => hook'* && ${call} != *'- 鉤 => hook (ok'* ]] && echo 1 || echo 0)"
  check 'terms: コメント行は渡さない' '0' "$([[ ${call} == *comment* ]] && echo 1 || echo 0)"
}

test_rejects_invalid_meta() {
  local meta
  for meta in 'not json' '{"branch":"b","name":"n","title":"t"}' '{"name":"n","title":"t","abbr":"a"}' \
    '{"branch":"b","name":"n","title":"t","abbr":""}' '{"branch":"","name":"n","title":"t","abbr":"a"}' \
    '{"branch":"b","name":1,"title":"t","abbr":"a"}' '["b","n","t","a"]' \
    '{"branch":"b","name":"n","title":"t","abbr":"a"}{"branch":"b","name":"n","title":"t","abbr":"a"}' \
    '{"branch":"b","name":"a\nb","title":"t","abbr":"a"}' '{"branch":"b\tc","name":"n","title":"t","abbr":"a"}'; do
    printf '%s' "${meta}" >"${llm_out}"
    run 'x'
    check "invalid (${meta}): 終了コード 1" '1' "${rc}"
    check "invalid (${meta}): 何も出さない" '' "${out}"
  done
}

test_fails_when_llm_fails() {
  printf '%s' '{"branch":"b","name":"n","title":"t","abbr":"a"}' >"${llm_out}"
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
  test_fails_without_naming
  test_adds_terms_rule
  test_rejects_invalid_meta
  test_fails_when_llm_fails

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
