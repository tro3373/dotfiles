#!/usr/bin/env bash

# bin/prp のユニットテスト (fzf と nvim を fake に差し替え。tty 不要)。
#
# 担保したいのは、呼び出しごとに一時ファイルを分けること。
# 共有すると、並列で呼んだときに別の呼び出しの本文が混ざる。
#
#   bin/test/test-prp.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
prp_bin=$(cd "${script_dir}/.." && pwd)/prp

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
  fakehome="${tmproot}/home"
  nvim_log="${tmproot}/nvim.log"
  mkdir -p "${fakebin}" "${fakehome}/.mo/prompt" "${tmproot}/tmp"
  printf 'PROMPT\n' >"${fakehome}/.mo/prompt/p.md"
  # fzf の fake: 候補の先頭を選ぶ
  printf '#!/usr/bin/env bash\nhead -1\n' >"${fakebin}/fzf"
  # nvim の fake: 渡されたパスと、その時点の中身を残す
  cat >"${fakebin}/nvim" <<EOS
#!/usr/bin/env bash
printf '%s\n' "\$1" >"${nvim_log}"
cat "\$1" >>"${nvim_log}"
EOS
  chmod +x "${fakebin}/fzf" "${fakebin}/nvim"
}

run_prp() {
  HOME="${fakehome}" PATH="${fakebin}:${PATH}" TMPDIR="${tmproot}/tmp" "${prp_bin}" "$@"
}

# 本文が長いほど、共有ファイルへの書き込みと読み出しが重なりやすい
body_of() { seq -f "$1%g" 1 2000; }

test_parallel_calls_do_not_mix_bodies() {
  local want_a want_b mixed=0
  want_a=PROMPT$'\n'$(body_of A)
  want_b=PROMPT$'\n'$(body_of B)
  for _ in $(seq 1 20); do
    body_of A | run_prp -ne p.md >"${tmproot}/a.out" &
    body_of B | run_prp -ne p.md >"${tmproot}/b.out" &
    wait
    if [[ $(cat "${tmproot}/a.out") != "${want_a}" ]]; then
      mixed=$((mixed + 1))
    fi
    if [[ $(cat "${tmproot}/b.out") != "${want_b}" ]]; then
      mixed=$((mixed + 1))
    fi
  done
  check 'parallel: 各呼び出しは自分の本文だけを返す (40 出力中の混入数)' '0' "${mixed}"
  check 'parallel: TMPDIR に何も残さない' '' "$(ls -A "${tmproot}/tmp")"
}

test_edit_mode_removes_temp_file() {
  printf 'BODY\n' | run_prp p.md
  local path
  path=$(head -1 "${nvim_log}")
  check 'edit: nvim にプロンプトと本文を渡す' $'PROMPT\nBODY' "$(tail -n +2 "${nvim_log}")"
  check 'edit: nvim の終了後に一時ファイルを残さない' 'absent' "$([[ -e ${path} ]] && echo present || echo absent)"
  check 'edit: nvim の終了後に TMPDIR に何も残さない' '' "$(ls -A "${tmproot}/tmp")"
}

main() {
  set -uo pipefail
  setup
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0

  test_parallel_calls_do_not_mix_bodies
  test_edit_mode_removes_temp_file

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
