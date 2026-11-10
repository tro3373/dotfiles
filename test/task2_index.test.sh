#!/usr/bin/env bash

# bin/lib/task2_index のユニットテスト (偽 task2 を PATH に置く。実 store に触らない)。
#
#   test/task2_index.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
lib=$(cd "${script_dir}/../bin/lib" && pwd)/task2_index

# shellcheck source-path=SCRIPTDIR source=../bin/lib/task2_index
source "${lib}"

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

# 偽 task2。`current -C <dir> --path` は <dir>/.task-path があればその中身、
# `where` は cwd の .index-path を index に持つ JSON を出す。
write_fake_task2() {
  cat >"${fakebin}/task2" <<'EOS'
#!/usr/bin/env bash
case $1 in
  current)
    [[ -f $3/.task-path ]] || exit 1
    cat "$3/.task-path"
    ;;
  where)
    printf '{"index":"%s"}\n' "$(cat .index-path)"
    ;;
esac
EOS
  chmod +x "${fakebin}/task2"
}

test_doc_path_prefers_task() {
  local dir="${tmp}/wt"
  mkdir -p "${dir}"
  printf '%s\n' "${tmp}/store/task.md" >"${dir}/.task-path"
  printf '%s\n' "${tmp}/store/index.md" >"${dir}/.index-path"
  check 'doc_path: ブランチのタスクがあれば task.md' "${tmp}/store/task.md" "$(task2_doc_path "${dir}")"
}

test_doc_path_falls_back_to_index() {
  local dir="${tmp}/main"
  mkdir -p "${dir}"
  printf '%s\n' "${tmp}/store/index.md" >"${dir}/.index-path"
  check 'doc_path: タスクが無ければ repo の index.md' "${tmp}/store/index.md" "$(task2_doc_path "${dir}")"
}

test_append_adds_to_end() {
  local index="${tmp}/store/index.md"
  printf 'list\n----\nhuman\n' >"${index}"
  printf -- '- [ ] a\n  - b\n' | task2_index_append "${index}"
  check 'append: 末尾に足す' $'list\n----\nhuman\n- [ ] a\n  - b' "$(cat "${index}")"
}

test_append_skips_empty() {
  local index="${tmp}/store/empty.md"
  printf 'x\n' >"${index}"
  task2_index_append "${index}" </dev/null
  check 'append: 中身が空なら何も足さない' 'x' "$(cat "${index}")"
}

# task2 が一覧を作り直す間 (lock を握る間) は書かず、離してから足す。
test_append_waits_for_lock() {
  local index="${tmp}/store/locked.md"
  printf 'old\n' >"${index}"
  (
    flock -x 9
    sleep 0.3
    printf 'rewritten\n' >"${index}.tmp"
    mv "${index}.tmp" "${index}"
  ) 9<"$(dirname "${index}")" &
  sleep 0.1
  printf 'added\n' | task2_index_append "${index}"
  wait
  check 'append: 作り直しの lock を待ち、置き換え後のファイルに足す' $'rewritten\nadded' "$(cat "${index}")"
}

main() {
  set -uo pipefail
  local pass=0 fail=0 tmp fakebin
  tmp=$(mktemp -d)
  fakebin="${tmp}/bin"
  mkdir -p "${fakebin}" "${tmp}/store"
  write_fake_task2
  # lint-ignore: uppercase 偽 task2 を先に引かせるため PATH を書き換える
  PATH="${fakebin}:${PATH}"

  test_doc_path_prefers_task
  test_doc_path_falls_back_to_index
  test_append_adds_to_end
  test_append_skips_empty
  test_append_waits_for_lock

  rm -rf "${tmp}"
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  ((fail == 0))
}
main "$@"
