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
  HOME="${fake_home}" PATH="${fake_bin}:/usr/bin:/bin" "${bin_dir}/find_repos" | sort | paste -sd,
}

test_symlinked_dot_listed_once() {
  mkdir -p "${fake_home}/.dot" "${owner_dir}/other"
  ln -s "${fake_home}/.dot" "${owner_dir}/dotfiles"
  check "ghq の下の symlink が ~/.dot を指すとき、~/.dot の 1 行だけを出す" \
    "${fake_home}/.dot,${owner_dir}/other" "$(found)"
}

test_mo_listed() {
  mkdir -p "${fake_home}/.mo"
  check "~/.mo があれば出す" \
    "${fake_home}/.dot,${fake_home}/.mo,${owner_dir}/other" "$(found)"
}

test_every_src_repo_listed() {
  mkdir -p "${fake_home}/src/a/.git" "${fake_home}/src/b/c/.git"
  check "~/src の下の repo をすべて出し、ghq の 1 件目も落とさない" \
    "${fake_home}/.dot,${fake_home}/.mo,${owner_dir}/other,${fake_home}/src/a,${fake_home}/src/b/c" "$(found)"
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

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
