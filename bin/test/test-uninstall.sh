#!/usr/bin/env bash

# bin/uninstall のユニットテスト。
# os / pacman / sudo を偽物に差し替え、pacman へ渡る削除の引数を検証する。
#
#   bin/test/test-uninstall.sh   # 全テスト実行

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
  mkdir -p "${fake_bin}"
  cat >"${fake_bin}/os" <<'EOF'
#!/usr/bin/env bash
echo arch
EOF
  cat >"${fake_bin}/sudo" <<'EOF'
#!/usr/bin/env bash
exec "$@"
EOF
  cat >"${fake_bin}/pacman" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  -Q) cat "${FAKE_INSTALLED}" ;;
  -Rsp) shift 3 && printf '%s 1.0\n' "$@" ;;
  *) echo "$*" >>"${FAKE_REMOVED}" ;;
esac
EOF
  chmod +x "${fake_bin}"/*
  cat >"${FAKE_INSTALLED}" <<'EOF'
bruno-bin 4.2.1-1
slack-desktop 4.41.0-1
libbruno 1.0-1
vim 9.1-1
EOF
}

# 削除ログを空にして uninstall を実行し、終了コードを status に入れる。
run_uninstall() {
  : >"${FAKE_REMOVED}"
  status=0
  PATH="${fake_bin}:${bin_dir}:${PATH}" "${bin_dir}/uninstall" "$@" >/dev/null 2>&1 || status=$?
}

removed() { cat "${FAKE_REMOVED}"; }

test_patterns() {
  run_uninstall --apply slack </dev/null
  check "部分一致した package を消す" "-Rns --noconfirm slack-desktop" "$(removed)"

  run_uninstall --apply bruno </dev/null
  check "1 pattern が複数 package に一致" "-Rns --noconfirm bruno-bin libbruno" "$(removed)"

  run_uninstall --apply slack vim </dev/null
  check "複数 pattern" "-Rns --noconfirm slack-desktop vim" "$(removed)"

  run_uninstall --apply bruno bin </dev/null
  check "重なる pattern は重複させない" "-Rns --noconfirm bruno-bin libbruno" "$(removed)"

  run_uninstall --apply SLACK </dev/null
  check "大文字小文字を区別しない" "-Rns --noconfirm slack-desktop" "$(removed)"
}

test_no_match() {
  run_uninstall --apply slack nosuchpkg </dev/null
  check "一致しない pattern があれば失敗" "1" "${status}"
  check "一致しない pattern があれば何も消さない" "" "$(removed)"

  run_uninstall --apply 4.41 </dev/null
  check "version には一致させない" "1" "${status}"
}

test_confirm() {
  run_uninstall slack <<<""
  check "Enter で消す" "-Rns --noconfirm slack-desktop" "$(removed)"

  run_uninstall slack <<<"n"
  check "Enter 以外の入力は消さない" "" "$(removed)"
  check "Enter 以外の入力は失敗" "1" "${status}"

  run_uninstall slack </dev/null
  check "入力が無ければ消さない" "" "$(removed)"
}

test_options() {
  run_uninstall --bogus slack </dev/null
  check "未知の option は失敗" "1" "${status}"
  check "未知の option は何も消さない" "" "$(removed)"
}

main() {
  local pass=0 fail=0 status=0
  local tmproot
  tmproot=$(mktemp -d)
  # shellcheck disable=SC2064 # local 変数のため trap 定義時に展開する
  trap "rm -rf '${tmproot}'" EXIT
  local fake_bin="${tmproot}/bin"
  # lint-ignore: uppercase 偽 pacman へ渡す環境変数
  export FAKE_INSTALLED="${tmproot}/installed" FAKE_REMOVED="${tmproot}/removed"
  install_fakes

  test_patterns
  test_no_match
  test_confirm
  test_options

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
