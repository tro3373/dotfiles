#!/usr/bin/env bash

# bin/tasks-add のユニットテスト (gen_task_title_and_branch・tasks・fzf を fake に差し替え。NW 不要)。
#
# 担保したいのは次の 2 つ。
#   * 生成した title / name / branch と本文を tasks add へどう渡すか。
#     引数は生成値の後ろに付ける: pflag は後勝ちなので、利用者の --title などが生成値に勝つ
#   * index.md のブロック (`- [ ]` の行と、その下の字下げした行) を選んで 1 つずつ add し、
#     add できたブロックだけを index.md から消すこと。
#     消す間だけ index.md のディレクトリに flock を取る。tasks add も同じ lock で一覧を作り直すので、
#     add の間に持っていると互いに待って止まる
#
#   test/tasks-add.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tasks_add_bin=$(cd "${script_dir}/../bin" && pwd)/tasks-add

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
  tasks_args="${tmproot}/tasks.args"
  tasks_in="${tmproot}/tasks.in"
  calls="${tmproot}/calls"
  where_log="${tmproot}/where.log"
  lock_probe="${tmproot}/lock.probe"
  fzf_in="${tmproot}/fzf.in"
  index_dir="${tmproot}/store/repo"
  index="${index_dir}/index.md"
  config_file="${tmproot}/config.yaml"
  tasks_exit=0
  tasks_fail_at=0
  meta_exit=0
  mkdir -p "${fakebin}" "${index_dir}"
  # 生成コマンドの fake: 受けた本文を残し、meta.json を出す
  cat >"${fakebin}/gen_task_title_and_branch" <<EOS
#!/usr/bin/env bash
cat >"${meta_in}"
cat "${meta_json}"
exit "\${FAKE_META_EXIT:-0}"
EOS
  # tasks の fake
  #   where: 呼ばれたことを残し、index.md のパスを JSON で出す
  #   add: 引数を 1 行 1 個で、stdin をそのまま、呼んだ回ごとにも残し、ID を出す。
  #        index.md のディレクトリの lock を他が持っていれば lock.probe に書く
  cat >"${fakebin}/tasks" <<EOS
#!/usr/bin/env bash
if [[ \$1 == config ]]; then
  echo "${config_file}"
  exit 0
fi
if [[ \$1 == where ]]; then
  echo where >>"${where_log}"
  printf '{"place":"main","index":"%s"}\n' "${index}"
  exit 0
fi
n=\$((\$(cat "${calls}" 2>/dev/null || echo 0) + 1))
echo "\${n}" >"${calls}"
printf '%s\n' "\$@" >"${tasks_args}"
cat >"${tasks_in}"
cp "${tasks_args}" "${tmproot}/args.\${n}"
cp "${tasks_in}" "${tmproot}/in.\${n}"
flock -n "${index_dir}" true || echo held >>"${lock_probe}"
[[ \${n} == "\${FAKE_TASKS_FAIL_AT:-0}" ]] && exit 4
echo "20261102-00000\${n}"
exit "\${FAKE_TASKS_EXIT:-0}"
EOS
  # fzf の fake: 候補を残し、2 列目 (表示する列) が FAKE_FZF_PICK に合う行を選んだことにする。
  # 1 行も合わなければ、選ばずに閉じたときと同じ 130
  cat >"${fakebin}/fzf" <<EOS
#!/usr/bin/env bash
cat >"${fzf_in}"
# 選ぶ間に他の tasks が一覧の側を作り直したことにする
[[ -n \${FAKE_FZF_SHIFT:-} ]] && sed -i '1i - ⬜ [後から足されたタスク](store/repo/20261102-000009_z/task.md)' "${index}"
awk -F '\t' -v re="\${FAKE_FZF_PICK:-^\$}" '\$2 ~ re { print; n++ } END { exit n ? 0 : 130 }' "${fzf_in}"
EOS
  chmod +x "${fakebin}/gen_task_title_and_branch" "${fakebin}/tasks" "${fakebin}/fzf"
  printf '%s' '{"branch":"feature/x-y","name":"x-を-y","title":"x を y","abbr":"x-y"}' >"${meta_json}"

  # 一覧の側 (先頭) とマーカーと人の側を持つ index.md。行番号をテストで指すので、行を変えたら全テストを見直す
  #    1-2: CLI の一覧 / 4: マーカー / 8-11: ブロック A (10 の空行は 11 が字下げなので A の内)
  #   13-14: 済んだ行 (ブロックでない) / 15: ブロック B / 16: 字下げしない人のメモ
  #   17: 字下げした `- [ ]` (ブロックの頭でない) / 19: ブロック D
  sample_index=$'- ⬜ [既存のタスク](store/repo/20261101-000000_x/task.md)
  - 🚧 [子](store/repo/20261101-000001_y/task.md)

--------------------------------------------------------------------------------

# メモ

- [ ] A を作る
  - A の詳細

  - A の続き

- [x] 済んだもの
  - 済の詳細
- [ ] B を直す
自由なメモ
  - [ ] 字下げした C

- [ ] D
'
  block_a=$'- [ ] A を作る\n  - A の詳細\n\n  - A の続き\n'
  block_b=$'- [ ] B を直す\n'
  block_d=$'- [ ] D\n'
}

reset_records() {
  rm -f "${tasks_args}" "${tasks_in}" "${meta_in}" "${calls}" "${where_log}" "${lock_probe}" "${fzf_in}" \
    "${tmproot}"/args.* "${tmproot}"/in.*
}

# index_content があればその中身、無ければ sample_index にする。config の index_position は index_position の値 (空なら書かない)
reset_index() {
  printf '%s' "${index_content:-${sample_index}}" >"${index}"
  rm -f "${config_file}"
  [[ -z ${index_position:-} ]] || printf 'store: x\nindex_position: %s   # 既定: top\n' "${index_position}" >"${config_file}"
}

# 本文 (stdin) と引数で tasks-add を流す。stdout と終了コードを out / rc に入れる
run() {
  local body="$1"
  shift
  reset_records
  out=$(printf '%s' "${body}" |
    PATH="${fakebin}:${PATH}" FAKE_TASKS_EXIT="${tasks_exit}" FAKE_META_EXIT="${meta_exit}" \
      "${tasks_add_bin}" "$@" 2>/dev/null)
  rc=$?
}

# index.md を初期の中身に戻し、stdin を端末でないまま引数だけで流す
run_index() {
  reset_records
  reset_index
  out=$(PATH="${fakebin}:${PATH}" FAKE_TASKS_FAIL_AT="${tasks_fail_at}" \
    "${tasks_add_bin}" "$@" </dev/null 2>/dev/null)
  rc=$?
}

# index.md を初期の中身に戻し、stdin を端末にして流す。fzf で FAKE_FZF_PICK に合うブロックを選ぶ
run_tty() {
  local pick="$1" cmd
  shift
  reset_records
  reset_index
  cmd=$(printf '%q ' env PATH="${fakebin}:${PATH}" FAKE_FZF_PICK="${pick}" "${tasks_add_bin}" "$@")
  out=$(script -qec "${cmd} 2>/dev/null" /dev/null </dev/null | tr -d '\r')
  rc=$?
}

# sentinel を付けて読み、末尾の改行まで比べる
read_exact() {
  cat "$1" 2>/dev/null
  printf .
}

# sample_index から行を消した中身 (sed の script で指す。行番号は元の index.md のもの)。末尾に sentinel を付ける
index_without() {
  printf '%s' "${sample_index}" | sed "$1"
  printf .
}

exists() {
  [[ -e $1 ]] && echo yes || echo no
}

test_passes_generated_meta_as_flags() {
  run $'- [ ] [20261101_213912] x を y にする\n  - 詳細'
  check 'meta: 生成した title / name / branch / abbr を tasks add のフラグで渡す' \
    $'add\n--title\nx を y\n--name\nx-を-y\n--branch\nfeature/x-y\n--abbr\nx-y' "$(cat "${tasks_args}" 2>/dev/null)"
  check 'meta: 本文を生成コマンドに渡す' \
    $'- [ ] [20261101_213912] x を y にする\n  - 詳細' "$(cat "${meta_in}" 2>/dev/null)"
}

test_passes_body_to_tasks_stdin() {
  local body
  for body in $'- [ ] x を y にする\n  - 詳細' $'- [ ] x を y にする\n  - 詳細\n' $'- [ ] x\n\n\n'; do
    run "${body}"
    check "body (${body@Q}): 本文を末尾の改行まで tasks add の stdin へそのまま渡す" "${body}." "$(read_exact "${tasks_in}")"
  done
}

test_appends_args_after_generated_flags() {
  run 'x' --parent 2026 --title '手で付けた題' -R mo
  check 'args: 引数は生成値の後ろに付けて tasks add へ渡す' \
    $'add\n--title\nx を y\n--name\nx-を-y\n--branch\nfeature/x-y\n--abbr\nx-y\n--parent\n2026\n--title\n手で付けた題\n-R\nmo' \
    "$(cat "${tasks_args}" 2>/dev/null)"
}

test_returns_tasks_stdout_and_exit_code() {
  run 'x'
  check 'tasks: stdout の ID をそのまま出す' '20261102-000001' "${out}"
  check 'tasks: 成功の終了コードを返す' '0' "${rc}"
  tasks_exit=3
  run 'x'
  check 'tasks: 失敗の終了コードをそのまま返す' '3' "${rc}"
  tasks_exit=0
}

test_stdin_does_not_read_index() {
  run 'x'
  check 'stdin: 本文を stdin で受けたら index.md の場所を引かない' 'no' "$(exists "${where_log}")"
  check 'stdin: 本文を stdin で受けたら 1 タスクだけ add する' '1' "$(cat "${calls}" 2>/dev/null)"
}

test_rejects_failed_generation() {
  meta_exit=5
  run 'x'
  meta_exit=0
  check 'gen-failed: 終了コード 1' '1' "${rc}"
  check 'gen-failed: tasks add を呼ばない' 'no' "$(exists "${tasks_args}")"
}

test_rejects_empty_body() {
  run $' \n\t\n'
  check 'empty: 終了コード 1' '1' "${rc}"
  check 'empty: 生成コマンドを呼ばない' 'no' "$(exists "${meta_in}")"
  check 'empty: tasks add を呼ばない' 'no' "$(exists "${tasks_args}")"
}

test_help() {
  local opt
  for opt in -h --help; do
    run 'x' "${opt}"
    check "help (${opt}): 終了コード 0" '0' "${rc}"
    check "help (${opt}): 使い方を出す" 'yes' "$([[ ${out} == *'tasks-add --lines 10,20'* ]] && echo yes || echo no)"
    check "help (${opt}): tasks add を呼ばない" 'no' "$(exists "${tasks_args}")"
  done
}

test_lines_adds_whole_block() {
  run_index --lines 9,9
  check 'lines: 範囲がブロックの途中でも、ブロック全体を 1 タスクで add する' '1' "$(cat "${calls}" 2>/dev/null)"
  check 'lines: ブロックを、内側の空行と末尾の改行まで tasks add の stdin へ渡す' "${block_a}." "$(read_exact "${tmproot}/in.1")"
  check 'lines: ブロックを生成コマンドに渡す' "${block_a}." "$(read_exact "${meta_in}")"
  check 'lines: add した ID を出す' '20261102-000001' "${out}"
  check 'lines: 成功の終了コード 0' '0' "${rc}"
  check 'lines: add したブロックと、その後ろの空行を index.md から消す' "$(index_without '8,12d')" "$(read_exact "${index}")"
}

test_lines_adds_each_block_in_order() {
  run_index --lines 9,19
  check 'lines: 範囲にかかるブロックごとに 1 回ずつ add する' '3' "$(cat "${calls}" 2>/dev/null)"
  check 'lines: 1 回目は index.md の上のブロック' "${block_a}." "$(read_exact "${tmproot}/in.1")"
  check 'lines: 2 回目は次のブロック (済んだ行と字下げした「- [ ]」は飛ばす)' "${block_b}." "$(read_exact "${tmproot}/in.2")"
  check 'lines: 3 回目は最後のブロック' "${block_d}." "$(read_exact "${tmproot}/in.3")"
  check 'lines: add した ID を 1 行ずつ出す' $'20261102-000001\n20261102-000002\n20261102-000003' "${out}"
  check 'lines: add したブロックを全て消し、一覧・マーカー・ブロックでない行は残す' \
    "$(index_without '8,12d;15d;18,19d')" "$(read_exact "${index}")"
}

test_lines_excludes_trailing_blank() {
  run_index --lines 12,15
  check 'lines: ブロックの後ろの空行は、そのブロックに含めない' "${block_b}." "$(read_exact "${tmproot}/in.1")"
  check 'lines: 範囲にかかるブロックだけを add する' '1' "$(cat "${calls}" 2>/dev/null)"
}

test_lines_passes_args_without_lines() {
  run_index --lines 15,15 --parent 2026 -R mo
  check 'lines: --lines を除いた引数を、生成値の後ろに付けて tasks add へ渡す' \
    $'add\n--title\nx を y\n--name\nx-を-y\n--branch\nfeature/x-y\n--abbr\nx-y\n--parent\n2026\n-R\nmo' \
    "$(cat "${tmproot}/args.1" 2>/dev/null)"
}

test_lines_without_block() {
  run_index --lines 1,4
  check 'lines-none: 範囲にブロックが無ければ終了コード 1' '1' "${rc}"
  check 'lines-none: tasks add を呼ばない' 'no' "$(exists "${calls}")"
  check 'lines-none: index.md を変えない' "$(index_without '')" "$(read_exact "${index}")"
}

test_lines_rejects_bad_range() {
  local range
  for range in '' 'a,b' '3-5' '5,3'; do
    run_index --lines "${range}"
    check "lines-bad (${range@Q}): 使い方エラーの終了コード 2" '2' "${rc}"
    check "lines-bad (${range@Q}): tasks add を呼ばない" 'no' "$(exists "${calls}")"
  done
}

test_lines_stops_at_failed_add() {
  tasks_fail_at=2
  run_index --lines 9,19
  tasks_fail_at=0
  check 'add-failed: tasks add の失敗の終了コードを返す' '4' "${rc}"
  check 'add-failed: 失敗した後のブロックは add しない' '2' "$(cat "${calls}" 2>/dev/null)"
  check 'add-failed: add できたブロックだけ消し、失敗したブロックと後ろは残す' \
    "$(index_without '8,12d')" "$(read_exact "${index}")"
}

test_lines_without_index() {
  reset_records
  rm -f "${index}"
  out=$(PATH="${fakebin}:${PATH}" "${tasks_add_bin}" --lines 1,1 </dev/null 2>/dev/null)
  rc=$?
  check 'no-index: index.md が無ければ終了コード 1' '1' "${rc}"
  check 'no-index: tasks add を呼ばない' 'no' "$(exists "${calls}")"
}

test_lock_is_not_held_during_add() {
  run_index --lines 9,19
  check 'lock: tasks add の間は index.md のディレクトリの lock を持たない' 'no' "$(exists "${lock_probe}")"
}

test_removal_waits_for_lock() {
  local got="${tmproot}/holder.got" snapshot="${tmproot}/holder.snapshot" holder
  reset_index
  rm -f "${got}" "${snapshot}"
  flock "${index_dir}" bash -c "touch '${got}'; sleep 1; cp '${index}' '${snapshot}'" &
  holder=$!
  while [[ ! -e ${got} ]]; do sleep 0.05; done
  reset_records
  out=$(PATH="${fakebin}:${PATH}" "${tasks_add_bin}" --lines 9,9 </dev/null 2>/dev/null)
  rc=$?
  wait "${holder}"
  check 'lock: 他が lock を持つ間は index.md を書き換えない' "$(index_without '')" "$(read_exact "${snapshot}")"
  check 'lock: lock が空いたらブロックを消す' "$(index_without '8,12d')" "$(read_exact "${index}")"
}

test_tty_offers_blocks_to_fzf() {
  run_tty '^A '
  check 'fzf: ブロックごとに「開始行,終了行<TAB>頭の行の本文」を 1 行で fzf に渡す' \
    $'8,11\tA を作る\n15,15\tB を直す\n19,19\tD' "$(cat "${fzf_in}" 2>/dev/null)"
}

test_tty_adds_selected_blocks() {
  run_tty '^(A |D$)' --parent 2026
  check 'fzf: 選んだブロックごとに 1 回ずつ add する' '2' "$(cat "${calls}" 2>/dev/null)"
  check 'fzf: 1 回目は選んだ上のブロック' "${block_a}." "$(read_exact "${tmproot}/in.1")"
  check 'fzf: 2 回目は選んだ下のブロック' "${block_d}." "$(read_exact "${tmproot}/in.2")"
  check 'fzf: 引数を生成値の後ろに付けて tasks add へ渡す' \
    $'add\n--title\nx を y\n--name\nx-を-y\n--branch\nfeature/x-y\n--abbr\nx-y\n--parent\n2026' \
    "$(cat "${tmproot}/args.2" 2>/dev/null)"
  check 'fzf: 選んだブロックだけを index.md から消す' "$(index_without '8,12d;18,19d')" "$(read_exact "${index}")"
  check 'fzf: 成功の終了コード 0' '0' "${rc}"
}

test_tty_list_rebuilt_while_picking() {
  FAKE_FZF_SHIFT=1 run_tty '^A '
  check 'fzf-shift: 選ぶ間に一覧の側の行数が変わっても、選んだブロックを add する' "${block_a}." "$(read_exact "${tmproot}/in.1")"
  check 'fzf-shift: 選んだブロックを index.md から消す' no "$(grep -q '^- \[ \] A を作る$' "${index}" && echo yes || echo no)"
}

# マーカーの向こう (一覧の側) に人の行が残った index.md。index_position を変えてマーカーを動かす前の形
list_side_index() {
  printf '%s\n' '- [ ] 上' '' "$(printf -- '-%.0s' {1..80})" '' '- [ ] 下'
}

test_tty_skips_list_side_top() {
  local index_content
  index_content=$(list_side_index)
  run_tty '.'
  check 'list-side: index_position を書かなければ (top)、マーカーより上をブロックにしない' $'5,5\t下' "$(cat "${fzf_in}" 2>/dev/null)"
}

test_tty_skips_list_side_bottom() {
  local index_content index_position=bottom
  index_content=$(list_side_index)
  run_tty '.'
  check 'list-side: index_position が bottom なら、マーカーより下をブロックにしない' $'1,1\t上' "$(cat "${fzf_in}" 2>/dev/null)"
  check 'list-side: 人の側のブロックを add して消す' "$(printf -- '-%.0s' {1..80})"$'\n\n- [ ] 下\n.' \
    "$(read_exact "${index}")"
}

test_tty_skips_legacy_reference() {
  local index_content
  index_content=$'- [ ] [20261104-090516_x](tasks/mo/20261104-090516_x/index.md)\n- [ ] [記事](https://example.com) を読む\n'
  run_tty '.'
  check 'legacy-ref: 旧 tasks の参照行 (リンクだけで .md を指す) をブロックにしない' \
    $'2,2\t[記事](https://example.com) を読む' "$(cat "${fzf_in}" 2>/dev/null)"
}

test_tty_cancelled() {
  run_tty '^$'
  check 'fzf-cancel: 選ばずに閉じたら終了コード 130' '130' "${rc}"
  check 'fzf-cancel: tasks add を呼ばない' 'no' "$(exists "${calls}")"
  check 'fzf-cancel: index.md を変えない' "$(index_without '')" "$(read_exact "${index}")"
}

test_tty_without_block() {
  local cmd
  reset_records
  printf '%s' $'メモだけ\n- [x] 済んだもの\n' >"${index}"
  cmd=$(printf '%q ' env PATH="${fakebin}:${PATH}" FAKE_FZF_PICK=. "${tasks_add_bin}")
  script -qec "${cmd} 2>/dev/null" /dev/null </dev/null >/dev/null
  rc=$?
  check 'fzf-none: ブロックが無ければ終了コード 1' '1' "${rc}"
  check 'fzf-none: fzf を開かない' 'no' "$(exists "${fzf_in}")"
}

main() {
  set -uo pipefail
  setup
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0

  test_passes_generated_meta_as_flags
  test_passes_body_to_tasks_stdin
  test_appends_args_after_generated_flags
  test_returns_tasks_stdout_and_exit_code
  test_stdin_does_not_read_index
  test_rejects_failed_generation
  test_rejects_empty_body
  test_help
  test_lines_adds_whole_block
  test_lines_adds_each_block_in_order
  test_lines_excludes_trailing_blank
  test_lines_passes_args_without_lines
  test_lines_without_block
  test_lines_rejects_bad_range
  test_lines_stops_at_failed_add
  test_lines_without_index
  test_lock_is_not_held_during_add
  test_removal_waits_for_lock
  test_tty_offers_blocks_to_fzf
  test_tty_adds_selected_blocks
  test_tty_list_rebuilt_while_picking
  test_tty_skips_list_side_top
  test_tty_skips_list_side_bottom
  test_tty_skips_legacy_reference
  test_tty_cancelled
  test_tty_without_block

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
