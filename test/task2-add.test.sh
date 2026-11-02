#!/usr/bin/env bash

# bin/task2-add のユニットテスト (gen_task_title_and_branch と task2 を fake に差し替え。NW 不要)。
#
# 担保したいのは、生成した title / name / branch と本文を task2 add へどう渡すか。
# 引数は生成値の後ろに付ける: pflag は後勝ちなので、利用者の --title などが生成値に勝つ。
#
#   test/task2-add.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
task2_add_bin=$(cd "${script_dir}/../bin" && pwd)/task2-add

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
  meta_json="${tmproot}/meta.json"
  meta_in="${tmproot}/meta.in"
  task2_args="${tmproot}/task2.args"
  task2_in="${tmproot}/task2.in"
  task2_exit=0
  meta_exit=0
  mkdir -p "${fakebin}"
  # 生成コマンドの fake: 受けた本文を残し、meta.json を出す
  cat >"${fakebin}/gen_task_title_and_branch" <<EOS
#!/usr/bin/env bash
cat >"${meta_in}"
cat "${meta_json}"
exit "\${FAKE_META_EXIT:-0}"
EOS
  # task2 の fake: 引数を 1 行 1 個で、stdin をそのまま残し、ID を出す
  cat >"${fakebin}/task2" <<EOS
#!/usr/bin/env bash
printf '%s\n' "\$@" >"${task2_args}"
cat >"${task2_in}"
echo 20261102-000000
exit "\${FAKE_TASK2_EXIT:-0}"
EOS
  chmod +x "${fakebin}/gen_task_title_and_branch" "${fakebin}/task2"
  printf '%s' '{"branch":"feature/x-y","name":"x-を-y","title":"x を y"}' >"${meta_json}"
}

# 本文 (stdin) と引数で task2-add を流す。stdout と終了コードを out / rc に入れる
run() {
  local body="$1"
  shift
  rm -f "${task2_args}" "${task2_in}" "${meta_in}"
  out=$(printf '%s' "${body}" |
    PATH="${fakebin}:${PATH}" FAKE_TASK2_EXIT="${task2_exit}" FAKE_META_EXIT="${meta_exit}" \
      "${task2_add_bin}" "$@" 2>/dev/null)
  rc=$?
}

test_passes_generated_meta_as_flags() {
  run $'- [ ] [20261101_213912] x を y にする\n  - 詳細'
  check 'meta: 生成した title / name / branch を task2 add のフラグで渡す' \
    $'add\n--title\nx を y\n--name\nx-を-y\n--branch\nfeature/x-y' "$(cat "${task2_args}" 2>/dev/null)"
  check 'meta: 本文を生成コマンドに渡す' \
    $'- [ ] [20261101_213912] x を y にする\n  - 詳細' "$(cat "${meta_in}" 2>/dev/null)"
}

# 番兵を付けて読み、末尾の改行まで比べる
read_exact() { cat "$1" 2>/dev/null; printf .; }

test_passes_body_to_task2_stdin() {
  local body
  for body in $'- [ ] x を y にする\n  - 詳細' $'- [ ] x を y にする\n  - 詳細\n' $'- [ ] x\n\n\n'; do
    run "${body}"
    check "body (${body@Q}): 本文を末尾の改行まで task2 add の stdin へそのまま渡す" "${body}." "$(read_exact "${task2_in}")"
  done
}

test_appends_args_after_generated_flags() {
  run 'x' --parent 2026 --title '手で付けた題' -R mo
  check 'args: 引数は生成値の後ろに付けて task2 add へ渡す' \
    $'add\n--title\nx を y\n--name\nx-を-y\n--branch\nfeature/x-y\n--parent\n2026\n--title\n手で付けた題\n-R\nmo' \
    "$(cat "${task2_args}" 2>/dev/null)"
}

test_returns_task2_stdout_and_exit_code() {
  run 'x'
  check 'task2: stdout の ID をそのまま出す' '20261102-000000' "${out}"
  check 'task2: 成功の終了コードを返す' '0' "${rc}"
  task2_exit=3
  run 'x'
  check 'task2: 失敗の終了コードをそのまま返す' '3' "${rc}"
  task2_exit=0
}

test_rejects_failed_generation() {
  meta_exit=5
  run 'x'
  meta_exit=0
  check 'gen-failed: 終了コード 1' '1' "${rc}"
  check 'gen-failed: task2 add を呼ばない' 'no' "$([[ -e ${task2_args} ]] && echo yes || echo no)"
}

test_rejects_empty_body() {
  run $' \n\t\n'
  check 'empty: 終了コード 1' '1' "${rc}"
  check 'empty: 生成コマンドを呼ばない' 'no' "$([[ -e ${meta_in} ]] && echo yes || echo no)"
  check 'empty: task2 add を呼ばない' 'no' "$([[ -e ${task2_args} ]] && echo yes || echo no)"
}

main() {
  set -uo pipefail
  setup
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0

  test_passes_generated_meta_as_flags
  test_passes_body_to_task2_stdin
  test_appends_args_after_generated_flags
  test_returns_task2_stdout_and_exit_code
  test_rejects_failed_generation
  test_rejects_empty_body

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
