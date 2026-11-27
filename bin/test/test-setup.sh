#!/usr/bin/env bash

# bin/setup のユニットテスト。
# curl・nix・ghq を偽物に差し替え、一時 HOME で bin/setup を実行する。
# - nix の installer と home-manager の bootstrap が何回走るか
# - ghq の下に ~/.dot への symlink が張られるか

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

install_fakes() {
  mkdir -p "${fake_bin}" "${FAKE_NIX_BIN}"
  echo "export PATH=\"${FAKE_NIX_BIN}:\$PATH\"" >"${FAKE_NIX_SH}"
  cat >"${fake_bin}/os" <<'EOF'
#!/usr/bin/env bash
echo arch
EOF
  cat >"${fake_bin}/curl" <<'EOF'
#!/usr/bin/env bash
echo installer >>"${FAKE_LOG}"
cat <<SCRIPT
mkdir -p "\$HOME/.nix-profile/etc/profile.d"
cp "${FAKE_NIX_SH}" "\$HOME/.nix-profile/etc/profile.d/nix.sh"
SCRIPT
EOF
  cat >"${FAKE_NIX_BIN}/nix" <<'EOF'
#!/usr/bin/env bash
echo "nix $1" >>"${FAKE_LOG}"
EOF
  chmod +x "${fake_bin}"/* "${FAKE_NIX_BIN}"/*
}

reset_home() {
  rm -rf "${fake_home}" && mkdir -p "${fake_home}"
  : >"${FAKE_LOG}"
}

place_nix_sh() {
  mkdir -p "${fake_home}/.nix-profile/etc/profile.d"
  cp "${FAKE_NIX_SH}" "${fake_home}/.nix-profile/etc/profile.d/nix.sh"
}

run_setup() {
  status=0
  HOME="${fake_home}" PATH="${extra_path:+${extra_path}:}${base_path}" "${bin_dir}/setup" -e "$@" >"${tmproot}/out" 2>&1 || status=$?
}

ran() { paste -sd, "${FAKE_LOG}"; }

test_fresh() {
  reset_home
  run_setup home-manager
  check "nix が無ければ入れてから bootstrap する" "0 installer,nix run" "${status} $(ran)"
}

test_installed_off_path() {
  reset_home
  place_nix_sh
  run_setup home-manager
  check "nix.sh があれば installer を走らせずに bootstrap する" "0 nix run" "${status} $(ran)"

  reset_home
  place_nix_sh
  run_setup nix
  check "nix.sh があれば nix の installer を走らせない" "0 " "${status} $(ran)"
}

test_on_path() {
  reset_home
  extra_path="${FAKE_NIX_BIN}" run_setup nix
  check "nix が PATH にあれば installer を走らせない" "0 " "${status} $(ran)"
}

test_nix_sh_without_nix() {
  reset_home
  mkdir -p "${fake_home}/.nix-profile/etc/profile.d"
  : >"${fake_home}/.nix-profile/etc/profile.d/nix.sh"
  run_setup home-manager
  check "nix.sh が nix を PATH に載せなければ失敗で終わる" "1 " "${status} $(ran)"
}

test_nix_then_home_manager() {
  reset_home
  run_setup nix home-manager
  check "nix の後に並べた home-manager は同じ実行で bootstrap する" "0 installer,nix run" "${status} $(ran)"
}

install_fake_ghq() {
  printf '#!/usr/bin/env bash\n' >"${fake_bin}/ghq"
  chmod +x "${fake_bin}/ghq"
}

ghq_links() {
  local owner_dir="${fake_home}/ghq/github.com/tro3373"
  printf '%s,%s' "$(readlink "${owner_dir}/dotfiles")" "$(readlink "${owner_dir}/dotfiles-worktree")"
}

dir_entries() { find "$1" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort | paste -sd,; }

test_ghq_links_dot() {
  install_fake_ghq

  reset_home
  mkdir -p "${fake_home}/.dot" "${fake_home}/.dot-worktree"
  run_setup ghq
  check "ghq の下に ~/.dot と ~/.dot-worktree への symlink を張る" \
    "0 ${fake_home}/.dot,${fake_home}/.dot-worktree" "${status} $(ghq_links)"

  run_setup ghq
  check "2 回目の setup で symlink を張り直さず、link 先の中にも作らない" \
    "0 ${fake_home}/.dot,${fake_home}/.dot-worktree [][]" \
    "${status} $(ghq_links) [$(dir_entries "${fake_home}/.dot")][$(dir_entries "${fake_home}/.dot-worktree")]"
}

test_ghq_adds_roots_once() {
  reset_home
  run_setup ghq
  run_setup ghq
  check "ghq の root を ~/.gitconfig に 1 回だけ足す" \
    "0 1" "${status} $(grep -c 'root = ~/ghq' "${fake_home}/.gitconfig")"
}

test_ghq_keeps_existing_checkout() {
  reset_home
  local owner_dir="${fake_home}/ghq/github.com/tro3373"
  mkdir -p "${owner_dir}/dotfiles/unreadable"
  touch "${owner_dir}/dotfiles/kept"
  chmod 000 "${owner_dir}/dotfiles/unreadable"
  run_setup ghq
  chmod 700 "${owner_dir}/dotfiles/unreadable"
  check "ghq の下に実体の checkout があれば、中にも隣にも何も作らない" \
    "0 [dotfiles][kept,unreadable] 1" \
    "${status} [$(dir_entries "${owner_dir}")][$(dir_entries "${owner_dir}/dotfiles")] $(grep -c '^\[ghq\]' "${fake_home}/.gitconfig")"
}

test_ghq_keeps_unreadable_dir() {
  reset_home
  local owner_dir="${fake_home}/ghq/github.com/tro3373"
  mkdir -p "${owner_dir}/dotfiles-worktree/unreadable"
  chmod 000 "${owner_dir}/dotfiles-worktree/unreadable"
  run_setup ghq
  chmod 700 "${owner_dir}/dotfiles-worktree/unreadable"
  check "読めないディレクトリを含む既存の物の中に symlink を作らない" \
    "0 [unreadable]" "${status} [$(dir_entries "${owner_dir}/dotfiles-worktree")]"
}

install_fake_fastfetch() {
  mkdir -p "${ff_dir}/bin"
  printf '#!/bin/sh\necho FF\n' >"${ff_dir}/bin/fastfetch"
  chmod +x "${ff_dir}/bin/fastfetch"
}

gen_fastfetch_profile() {
  ff_n=$((ff_n + 1))
  local profile="${ff_dir}/fastfetch-${ff_n}.sh"
  # shellcheck source=/dev/null
  (source "${bin_dir}/../apps/fastfetch/config" && cat_fastfetch_shell) |
    sed "s#/tmp/fastfetched#${ff_dir}/flag-${ff_n}#g" >"${profile}"
  printf '%s' "${profile}"
}

source_profile_twice() {
  local tmux="$1" path="$2" after="$3"
  shift 3
  local profile
  profile=$(gen_fastfetch_profile)
  env -u TMUX ${tmux:+"TMUX=${tmux}"} PATH="${path}" \
    "$@" -c ". '${profile}'; . '${profile}'; ${after}" 2>&1 </dev/null |
    grep -v -e 'job control' -e 'terminal process group' | paste -sd,
}

test_fastfetch_profile() {
  local ff_dir="${tmproot}/fastfetch" ff_n=0
  install_fake_fastfetch
  local with_ff="${ff_dir}/bin:/usr/bin:/bin" no_ff="${ff_dir}/empty"
  local bash_i=(/usr/bin/bash --norc --noprofile -i)
  check "login 時の fastfetch: interactive でない shell では出さない" \
    "end" "$(source_profile_twice "" "${with_ff}" 'echo end' bash --norc --noprofile)"
  check "login 時の fastfetch: tmux の外では読むたびに出す" \
    "FF,FF,end" "$(source_profile_twice "" "${with_ff}" 'echo end' "${bash_i[@]}")"
  check "login 時の fastfetch: tmux の中では 1 回だけ出す" \
    "FF,end" "$(source_profile_twice x "${with_ff}" 'echo end' "${bash_i[@]}")"
  check "login 時の fastfetch: fastfetch が無ければ何も出さない" \
    "end" "$(source_profile_twice "" "${no_ff}" 'echo end' "${bash_i[@]}")"
  check "login 時の fastfetch: zsh で 2 回読んでも error を出さない" \
    "FF,FF,end" "$(source_profile_twice "" "${with_ff}" 'echo end' zsh -f -i)"
  check "login 時の fastfetch: 読んだ shell に関数も readonly 変数も残さない" \
    "FF,FF,end" "$(source_profile_twice "" "${with_ff}" 'declare -F; declare -pr | grep fastfetched; echo end' "${bash_i[@]}")"
}

main() {
  local pass=0 fail=0 status=0
  local tmproot
  tmproot=$(mktemp -d)
  # shellcheck disable=SC2064
  trap "rm -rf '${tmproot}'" EXIT
  local fake_bin="${tmproot}/bin" fake_home="${tmproot}/home dir"
  local base_path="${fake_bin}:${bin_dir}:/usr/bin:/bin"
  # lint-ignore: uppercase 偽の curl と nix へ渡す環境変数
  export FAKE_LOG="${tmproot}/log" FAKE_NIX_BIN="${tmproot}/nix-bin" FAKE_NIX_SH="${tmproot}/nix.sh"
  install_fakes

  test_fresh
  test_installed_off_path
  test_on_path
  test_nix_sh_without_nix
  test_nix_then_home_manager
  test_ghq_links_dot
  test_ghq_adds_roots_once
  test_ghq_keeps_existing_checkout
  test_ghq_keeps_unreadable_dir
  test_fastfetch_profile

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
