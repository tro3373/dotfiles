#!/usr/bin/env bash
#
# after-done.test.sh - after-done が repo の after-done ファイルを、/bot の after_done.sh が読める形で読み書きすることを確かめる。
#
#   bash test/after-done.test.sh

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" && readonly script_dir
readonly target="${script_dir}/../bin/after-done"

make_stubs() {
  work_dir=$(mktemp -d)
  mkdir -p "${work_dir}/bin" "${work_dir}/store/repo"
  config="${work_dir}/store/repo/after-done"
  cat >"${work_dir}/bin/tasks" <<STUB
#!/usr/bin/env bash
[[ -n "\${WHERE_FAILS:-}" ]] && exit 2
printf '{"index":"${work_dir}/store/repo/index.md"}\n'
STUB
  cat >"${work_dir}/bin/trash" <<'STUB'
#!/usr/bin/env bash
command rm -f "$1"
STUB
  # 候補を記録し、$FZF_PICK 行目を返す。$FZF_PICK が無ければ選ばずに閉じる
  cat >"${work_dir}/bin/fzf" <<STUB
#!/usr/bin/env bash
cat >"${work_dir}/fzf_input"
[[ -n "\${FZF_PICK:-}" ]] || exit 130
sed -n "\${FZF_PICK}p" "${work_dir}/fzf_input"
STUB
  chmod +x "${work_dir}/bin/tasks" "${work_dir}/bin/trash" "${work_dir}/bin/fzf"
}

fail() {
  printf 'FAIL %s\n  want: %q\n  got:  %q\n' "${name}" "$1" "$2" >&2
  fails=$((fails + 1))
}

set_config() {
  command rm -f "${config}"
  [[ $1 == NONE ]] && return 0
  printf '%b' "$1" >"${config}"
}

read_config() {
  [[ -e ${config} ]] || {
    printf 'NONE'
    return 0
  }
  cat "${config}"
}

# check <名前> <前の after-done> <want code> <want after-done> <引数...>。NONE はファイル無し
check() {
  local name="$1" before="$2" want_code="$3" want="$4" got code=0
  shift 4
  set_config "${before}"
  PATH="${work_dir}/bin:${PATH}" bash "${target}" "$@" >/dev/null 2>&1 </dev/null || code=$?
  ((code == want_code)) || fail "code ${want_code}" "code ${code}"
  got=$(read_config)
  [[ ${got} == "${want}" ]] || fail "${want}" "${got}"
}

check_show() {
  local name="$1" before="$2" want="$3" got
  set_config "${before}"
  got=$(PATH="${work_dir}/bin:${PATH}" bash "${target}" 2>/dev/null </dev/null)
  [[ ${got} == "${want}" ]] || fail "${want}" "${got}"
}

# 端末で打った形にするため script の pty の中で動かす
run_on_tty() {
  PATH="${work_dir}/bin:${PATH}" FZF_PICK="${1:-}" \
    script -qec "bash '${target}'" /dev/null >/dev/null 2>&1
}

check_pick() {
  local name="$1" before="$2" pick="$3" want="$4" want_first="$5" got first
  set_config "${before}"
  run_on_tty "${pick}" || true
  got=$(read_config)
  [[ ${got} == "${want}" ]] || fail "${want}" "${got}"
  first=$(head -1 "${work_dir}/fzf_input" | cut -f1)
  [[ ${first} == "${want_first}" ]] || fail "${want_first}" "${first}"
}

main() {
  set -uo pipefail
  local fails=0
  make_stubs
  trap 'command rm -rf "${work_dir}"' EXIT
  cd "${work_dir}" || return 1

  check 'merge を書く' NONE 0 $'merge' merge
  check 'merge-push を書く' NONE 0 $'merge-push' merge-push
  check 'merge-confirm を書く' NONE 0 $'merge-confirm' merge-confirm
  check 'pr を書く' NONE 0 $'pr' pr
  check '今の値を上書きする' 'merge\n' 0 $'pr' pr
  check 'ask はファイルを消す' 'merge\n' 0 NONE ask
  check 'ファイルが無くても ask は成功する' NONE 0 NONE ask
  check '不正な値は書かない' 'merge\n' 2 $'merge' bogus
  check '引数が 2 つなら書かない' 'merge\n' 2 $'merge' merge pr
  WHERE_FAILS=1 check 'repo の外では失敗する' NONE 2 NONE merge

  check_show '端末でなければ今の値を出す' 'pr\n' pr
  check_show 'ファイルが無ければ ask' NONE ask
  check_show '空のファイルは ask' '' ask

  check_pick '選んだ値を書く' NONE 2 $'merge-push' ask
  check_pick '今の値が先頭に来る' 'pr\n' 1 $'pr' pr
  check_pick '今の値が merge-confirm でも先頭に来る' 'merge-confirm\n' 1 $'merge-confirm' merge-confirm
  check_pick '閉じたら変えない' 'pr\n' '' $'pr' pr

  ((fails == 0)) || return 1
  printf 'ok\n'
}

main "$@"
