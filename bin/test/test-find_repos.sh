#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && readonly script_dir
bin_dir=$(cd "${script_dir}/.." && pwd) && readonly bin_dir

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

install_fake_ghq() {
  mkdir -p "${fake_bin}"
  cat >"${fake_bin}/ghq" <<EOF
#!/usr/bin/env bash
printf '%s\n' "${owner_dir}/dotfiles" "${owner_dir}/other"
EOF
  chmod +x "${fake_bin}/ghq"
}

found() {
  HOME="${fake_home}" PATH="${fake_bin}:/usr/bin:/bin" "${bin_dir}/find_repos" "$@" | sort | paste -sd,
}

found_in_order() {
  HOME="${fake_home}" PATH="${fake_bin}:/usr/bin:/bin" "${bin_dir}/find_repos" "$@" | paste -sd,
}

new_commit_repo() {
  git init -q -b main "$1"
  git -C "$1" -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m init
}

test_symlinked_dot_listed_once() {
  mkdir -p "${fake_home}/.dot" "${owner_dir}/other"
  ln -s "${fake_home}/.dot" "${owner_dir}/dotfiles"
  check "ghq の下の symlink が ~/.dot を指すとき、~/.dot の 1 行だけを出す" \
    "${fake_home}/.dot,${owner_dir}/other" "$(found)"
}

test_mo_listed() {
  mkdir -p "${fake_home}/.mo"
  check "HOME に .mo があれば ~/.mo を出す" \
    "${fake_home}/.dot,${fake_home}/.mo,${owner_dir}/other" "$(found)"
}

test_every_src_repo_listed() {
  mkdir -p "${fake_home}/src/a/.git" "${fake_home}/src/b/c/.git"
  check "HOME の src の下の repo をすべて出し、ghq の 1 件目も落とさない" \
    "${fake_home}/.dot,${fake_home}/.mo,${owner_dir}/other,${fake_home}/src/a,${fake_home}/src/b/c" "$(found)"
}

test_symlinked_src_followed() {
  local real="${tmproot}/real-src"
  mkdir -p "${real}/d/.git"
  mv "${fake_home}/src" "${tmproot}/src.bak"
  ln -s "${real}" "${fake_home}/src"
  local listed
  listed=$(found)
  unlink "${fake_home}/src"
  mv "${tmproot}/src.bak" "${fake_home}/src"
  check "HOME の src が symlink でも、その下の repo を出す" "${fake_home}/src/d" \
    "$(tr , '\n' <<<"${listed}" | grep '/src/')"
}

# 別の HOME と ghq の stub で、worktree・bare repo・git でない dir を並べる
setup_main_env() {
  fake_home="${tmproot}/main-home"
  fake_bin="${tmproot}/main-bin"
  repo_a="${fake_home}/src/a"
  repo_b="${fake_home}/src/b"
  worktree="${fake_home}/ghq/wt"
  bare="${fake_home}/ghq/bare.git"
  plain="${fake_home}/.dot"
  mkdir -p "${fake_bin}" "${plain}" "${fake_home}/ghq"
  new_commit_repo "${repo_a}"
  new_commit_repo "${repo_b}"
  git -C "${repo_a}" worktree add -q "${worktree}"
  git init -q --bare "${bare}"
  cat >"${fake_bin}/ghq" <<EOF
#!/usr/bin/env bash
printf '%s\n' "${worktree}" "${bare}"
EOF
  chmod +x "${fake_bin}/ghq"
  touch -d '2020-01-01' "${repo_a}"
  touch -d '2005-01-01' "${repo_b}"
  touch -d '2001-01-01' "${worktree}"
}

test_without_main_worktree_listed() {
  check "--main が無ければ、worktree と git でない dir もそのまま出す" \
    "${plain},${bare},${worktree},${repo_a},${repo_b}" "$(found)"
}

test_main_folds_worktree() {
  check "--main は worktree を main checkout に畳んで 1 行にし、git でない dir を落とし、bare repo は dir 自身を出す" \
    "${bare},${repo_a},${repo_b}" "$(found --main)"
}

test_main_orders_by_main_checkout_mtime() {
  check "--main の並びは、畳んだ先の main checkout の mtime で決まる" \
    "${repo_b},${repo_a},${bare}" "$(found_in_order --main)"
}

test_unknown_arg_exits_2() {
  local status=0
  HOME="${fake_home}" PATH="${fake_bin}:/usr/bin:/bin" "${bin_dir}/find_repos" --bogus >/dev/null 2>&1 || status=$?
  check "未知の引数は exit 2" 2 "${status}"
}

test_main_env() {
  local fake_home fake_bin repo_a repo_b worktree bare plain
  setup_main_env
  test_without_main_worktree_listed
  test_main_folds_worktree
  test_main_orders_by_main_checkout_mtime
  test_unknown_arg_exits_2
}

main() {
  local pass=0 fail=0
  local tmproot
  tmproot=$(mktemp -d)
  # shellcheck disable=SC2064
  trap "rm -rf '${tmproot}'" EXIT
  local fake_bin="${tmproot}/bin" fake_home="${tmproot}/home dir"
  local owner_dir="${fake_home}/ghq/github.com/tro3373"
  install_fake_ghq

  test_symlinked_dot_listed_once
  test_mo_listed
  test_every_src_repo_listed
  test_symlinked_src_followed
  test_main_env

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
