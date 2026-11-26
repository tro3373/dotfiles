#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && readonly script_dir
bin_dir=$(cd "${script_dir}/.." && pwd) && readonly bin_dir
readonly me=me@example.com

check() {
  local desc="$1" expected="$2" actual="$3"
  if [[ ${expected} != "${actual}" ]]; then
    fail=$((fail + 1))
    printf 'FAIL - %s\n--- expected\n%s\n--- actual\n%s\n' "${desc}" "${expected}" "${actual}"
    return
  fi
  pass=$((pass + 1))
  printf 'ok   - %s\n' "${desc}"
}

ago() {
  printf '@%s +0900' "$((now - $1))"
}

# commit <dir> <seconds ago> <subject> [author email]
commit() {
  local dir="$1" when
  when=$(ago "$2")
  echo "$3" >>"${dir}/file"
  git -C "${dir}" add -A
  GIT_AUTHOR_DATE="${when}" GIT_COMMITTER_DATE="${when}" \
    git -C "${dir}" -c user.email="${4:-${me}}" -c user.name=t commit -qm "$3"
}

# merge_no_ff <dir> <branch> <seconds ago>
merge_no_ff() {
  local when
  when=$(ago "$3")
  GIT_AUTHOR_DATE="${when}" GIT_COMMITTER_DATE="${when}" \
    git -C "$1" -c user.email="${me}" -c user.name=t merge -q --no-ff -m "merge $2" "$2"
}

new_repo() {
  local dir="$1" origin="$2"
  git init -q -b main "${dir}"
  git -C "${dir}" config user.email "${me}"
  git -C "${dir}" remote add origin "${origin}"
}

install_fakes() {
  mkdir -p "${fake_bin}"
  cat >"${fake_bin}/ghq" <<EOF
#!/usr/bin/env bash
case "\$1" in
  root) echo "${fake_home}/ghq" ;;
  list) printf '%s\n' "${owner_dir}/tasks" "${owner_dir}/tasks-worktree/feat" "${owner_dir}/md" "${owner_dir}/md_" ;;
esac
EOF
  cat >"${fake_bin}/gh" <<EOF
#!/usr/bin/env bash
case "\$1 \$2" in
  "auth status") cat "${fixtures}/auth.json" ;;
  "auth token") echo "token-\$4" ;;
  "api graphql") cat "${fixtures}/\${GH_TOKEN}.json" ;;
esac
EOF
  chmod +x "${fake_bin}/ghq" "${fake_bin}/gh"
}

write_fixtures() {
  mkdir -p "${fixtures}"
  cat >"${fixtures}/auth.json" <<'EOF'
{"hosts":{"github.com":[
  {"state":"success","login":"me-home"},
  {"state":"success","login":"me-work"}]}}
EOF
  local hour_ago week_ago
  hour_ago=$(date -u -d "@$((now - 3600))" +%Y-%m-%dT%H:%M:%SZ)
  week_ago=$(date -u -d "@$((now - 10 * 86400))" +%Y-%m-%dT%H:%M:%SZ)
  cat >"${fixtures}/token-me-home.json" <<EOF
{"data":{"search":{"pageInfo":{"hasNextPage":false,"endCursor":null},"nodes":[
  {"repository":{"nameWithOwner":"tro3373/tasks"},"mergedAt":"${hour_ago}"},
  {"repository":{"nameWithOwner":"tro3373/md"},"mergedAt":"${week_ago}"},
  {"repository":{"nameWithOwner":"someone/elsewhere"},"mergedAt":"${week_ago}"}]}}}
EOF
  cat >"${fixtures}/token-me-work.json" <<EOF
{"data":{"search":{"pageInfo":{"hasNextPage":false,"endCursor":null},"nodes":[
  {"repository":{"nameWithOwner":"Corp/api"},"mergedAt":"${hour_ago}"}]}}}
EOF
}

build_repos() {
  local day=86400
  new_repo "${fake_home}/.dot" git@github.com:tro3373/dotfiles.git
  commit "${fake_home}/.dot" $((40 * day)) "dot too old"
  commit "${fake_home}/.dot" 7200 "someone else" other@example.com
  commit "${fake_home}/.dot" "${day}" "dot exactly a day ago"
  commit "${fake_home}/.dot" 3600 "dot recent"
  echo wip >>"${fake_home}/.dot/file"
  echo new >"${fake_home}/.dot/untracked"
  git -C "${fake_home}/.dot" -c user.email="${me}" -c user.name=t stash push -q -u
  git -C "${fake_home}/.dot" -c user.email="${me}" -c user.name=t notes add -m note

  local tasks="${owner_dir}/tasks"
  new_repo "${tasks}" https://github.com/tro3373/tasks.git
  commit "${tasks}" $((20 * day)) "tasks base"
  git -C "${tasks}" checkout -q -b feat
  commit "${tasks}" $((3 * day)) "tasks feat"
  git -C "${tasks}" checkout -q main
  merge_no_ff "${tasks}" feat 1800
  git -C "${tasks}" checkout -q -b master main~1
  git -C "${tasks}" checkout -q -b side
  commit "${tasks}" 900 "tasks side"
  git -C "${tasks}" checkout -q master
  merge_no_ff "${tasks}" side 600
  git -C "${tasks}" checkout -q -b rebased feat~1
  local when
  when=$(ago 60)
  GIT_COMMITTER_DATE="${when}" git -C "${tasks}" -c user.email="${me}" -c user.name=t \
    cherry-pick feat >/dev/null
  git -C "${tasks}" checkout -q main
  git -C "${tasks}" worktree add -q "${owner_dir}/tasks-worktree/feat" rebased
  touch -d '2000-01-01' "${owner_dir}/tasks-worktree/feat"

  new_repo "${owner_dir}/md" git@github.com:tro3373/md.git
  commit "${owner_dir}/md" $((2 * day)) "md one"
  git clone -q "${owner_dir}/md" "${owner_dir}/md_"
  git -C "${owner_dir}/md_" remote set-url origin git@github.com:tro3373/md.git
  git -C "${owner_dir}/md_" config user.email "${me}"
  commit "${owner_dir}/md_" $((5 * day)) "md two"

  new_repo "${fake_home}/src/corp/team/api" git@sub.github.com:Corp/api.git
  commit "${fake_home}/src/corp/team/api" $((6 * day)) "api"

  new_repo "${fake_home}/src/corp/idle" git@sub.github.com:Corp/idle.git
  commit "${fake_home}/src/corp/idle" $((60 * day)) "idle"
}

run_velocity() {
  HOME="${fake_home}" PATH="${fake_bin}:${PATH}" TZ=Asia/Tokyo VELOCITY_NOW="${now}" \
    "${bin_dir}/velocity" "$@"
}

test_table() {
  local expected
  expected=$(
    cat <<'EOF'
velocity 2026-11-26 19:00  commit           merge            pr
                              1d   7d  30d     1d   7d  30d     1d   7d  30d
~/.dot                         1    2    2      0    0    0      0    0    0
ghq/tro3373                    1    4    5      1    1    1      1    1    2
  md                           0    2    2      0    0    0      0    0    1
  tasks                        1    2    3      1    1    1      1    1    1
src/corp                       0    1    1      0    0    0      1    1    1
  team/api                     0    1    1      0    0    0      1    1    1
github:someone                 0    0    0      0    0    0      0    0    1
total                          2    7    8      1    1    1      2    2    4
EOF
  )
  check "置き場所の小計・repo・total を、24 時間・7 日・30 日で数える" "${expected}" "$(run_velocity)"
}

test_rejects_args() {
  local code=0
  run_velocity extra >/dev/null 2>&1 || code=$?
  check "引数を渡すと終了コード 2" 2 "${code}"
}

test_broken_gh_account_fails() {
  local auth="${fixtures}/auth.json" out code=0
  cp "${auth}" "${auth}.bak"
  jq '.hosts["github.com"][1].state = "error"' "${auth}.bak" >"${auth}"
  out=$(run_velocity 2>/dev/null) || code=$?
  mv "${auth}.bak" "${auth}"
  check "使えない gh の account があれば、表を出さずに失敗する" "1:" "${code}:${out}"
}

main() {
  set -euo pipefail
  local pass=0 fail=0
  local tmproot
  tmproot=$(mktemp -d)
  # shellcheck disable=SC2064
  trap "rm -rf '${tmproot}'" EXIT
  local fake_bin="${tmproot}/bin" fake_home="${tmproot}/home" fixtures="${tmproot}/fixtures"
  local owner_dir="${fake_home}/ghq/github.com/tro3373"
  local now
  now=$(TZ=Asia/Tokyo date -d '2026-11-26 19:00' +%s)
  # lint-ignore: uppercase git reads these names
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  install_fakes
  write_fixtures
  build_repos

  test_table
  test_rejects_args
  test_broken_gh_account_fails

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
