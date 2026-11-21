#!/usr/bin/env bash

# apps/vim/.vim/conf.d/102_funcs.vim の OpenUrlOrFilePathOnCursor が
# tasks の ID (YYYYMMDD-HHMMSS) を task.md へ解決してタブで開く挙動のテスト (実 nvim headless)。
# tasks と open は PATH 先頭の fake に差し替える。

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
funcs=$(cd "${script_dir}/../../vim/.vim/conf.d" && pwd)/102_funcs.vim

tmproot=$(mktemp -d)
trap 'rm -rf "${tmproot}"' EXIT
probe="${tmproot}/probe.txt"
tasks="${tmproot}/tasks"
known_a=20261106-184159
known_b=20261107-210354
unknown=19990101-000000

pass=0
fail=0

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

mkdir -p "${tmproot}/bin" "${tasks}/${known_a}_a" "${tasks}/${known_b}_b" "${tmproot}/repo"
touch "${tasks}/${known_a}_a/task.md" "${tasks}/${known_b}_b/task.md"

cat >"${tmproot}/bin/tasks" <<SH
#!/usr/bin/env bash
# tasks show <ID> --path だけを真似る
[[ \$1 != show || \$3 != --path ]] && exit 2
for d in "${tasks}/\$2"_*; do
  [[ ! -d \$d ]] && break
  echo "\$d/task.md"
  exit 0
done
echo "tasks: タスクが見つからない: \$2" >&2
exit 1
SH
printf '#!/usr/bin/env bash\n' >"${tmproot}/bin/open"
chmod +x "${tmproot}/bin/tasks" "${tmproot}/bin/open"

harness="${tmproot}/harness.vim"
cat >"${harness}" <<'VIM'
let g:is_wsl = 0
let g:is_orb = 0
let g:is_windows = 0
let g:is_mac = 0
let g:is_linux = 1
let g:winclip = ''
let g:plug = {}
function! g:plug.is_installed(name) abort
  return 0
endfunction
VIM

driver="${tmproot}/driver.vim"
cat >"${driver}" <<'VIM'
execute 'source ' . $t_harness
execute 'source ' . $t_funcs
execute 'edit ' . fnameescape($t_note)
let g:before = tabpagenr('$')
silent! call OpenUrlOrFilePathOnCursor()
let g:after = tabpagenr('$')
let g:opened = g:after > g:before ? fnamemodify(bufname(winbufnr(0)), ':p') : 'NONE'
call writefile([g:opened, string(g:after - g:before)], $t_out)
qa!
VIM

_drive() {
  printf '%s\n' "$1" >"${tmproot}/repo/note.md"
  : >"${probe}"
  PATH="${tmproot}/bin:${PATH}" t_harness="${harness}" t_funcs="${funcs}" \
    t_note="${tmproot}/repo/note.md" t_out="${probe}" \
    nvim --headless --clean -S "${driver}" >/dev/null 2>&1
}

opened() {
  _drive "$1"
  sed -n 1p "${probe}"
}

tabs() {
  _drive "$1"
  sed -n 2p "${probe}"
}

main() {
  set -euo pipefail
  local a="${tasks}/${known_a}_a/task.md" b="${tasks}/${known_b}_b/task.md"

  check 'ID 単体で task.md を開く' "${a}" "$(opened "${known_a}")"
  check '文中の ID を開く' "${a}" "$(opened "元: ${known_a} の confirm")"
  check '和文に直接続く ID を開く' "${a}" "$(opened "元${known_a}の confirm")"
  check 'バッククォートで囲んだ ID を開く' "${a}" "$(opened "\`${known_a}\` を参照")"
  check '文末のピリオドの前の ID を開く' "${a}" "$(opened "see ${known_a}.")"
  check '1 行に 2 つの ID で 2 タブ' '2' "$(tabs "${known_a} と ${known_b}")"
  check '同じ ID は 1 タブ' '1' "$(tabs "${known_b} と ${known_b}")"
  check '無い ID は開かない' 'NONE' "$(opened "${unknown}")"
  check '無い ID があっても他の ID は開く' "${b}" "$(opened "${unknown} ${known_b}")"
  check 'パスの一部の ID は開かない' 'NONE' "$(opened "tasks/mo/${known_b}_x/task.md")"
  check 'ファイル名の一部の ID は開かない' 'NONE' "$(opened "${known_b}.md")"
  check '長い数字列の一部は開かない' 'NONE' "$(opened "1${known_b}9")"
  check 'ハイフンで続く語の一部は開かない' 'NONE' "$(opened "x-${known_b}")"
  check 'URL の行は URL を優先する' 'NONE' "$(opened "https://example.com ${known_b}")"
  check 'Markdown リンクの中の ID は開かない' 'NONE' "$(opened "[${known_b}](missing.md)")"

  echo
  echo "pass=${pass} fail=${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
