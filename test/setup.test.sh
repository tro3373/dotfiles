#!/usr/bin/env bash

# bin/setup の nix と home-manager の導入のユニットテスト。
# curl と nix を偽物に差し替え、一時 HOME で bin/setup を実行し、
# nix の installer と home-manager の bootstrap が何回走るかを検証する。
#
#   test/setup.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && readonly script_dir
bin_dir=$(cd "${script_dir}/../bin" && pwd) && readonly bin_dir

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

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
