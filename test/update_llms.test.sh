#!/usr/bin/env bash

# bin/update_llms のユニットテスト (claude を fake に差し替え、NW 不要)。
#
# 担保したいのは:
#   * settings.json で有効なのに plugins にも ignores にも無いものを warn する。
#     無効なもの・ignores にあるもの・ビルトイン (@builtin) は warn しない。
#   * 最後に、実際に更新されたものだけを一覧で出す。
#     claude の出力は 1 件ずつ流れて「更新されたか」を見落とすため。
#
#   test/update_llms.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && readonly script_dir
target_bin=$(cd "${script_dir}/../bin" && pwd)/update_llms && readonly target_bin

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

contains() { grep -qF -- "$2" <<<"$1" && echo 1 || echo 0; }

# claude の偽物。plugin update の対象が FAKE_UPDATED_PLUGIN なら更新あり、それ以外は最新の文言を出す。
write_fake_bins() {
  fakebin="${tmproot}/bin"
  mkdir -p "${fakebin}"
  cat >"${fakebin}/claude" <<'FAKE'
#!/usr/bin/env bash
[[ $1 == plugin && $2 == update ]] || exit 0
plugin="${*: -1}"
if [[ $plugin == "${FAKE_UPDATED_PLUGIN:-}" ]]; then
  echo "✔ Plugin \"$plugin\" updated from 1.0.0 to 1.1.0 for scope user. Restart to apply changes."
  exit 0
fi
echo "✔ ${plugin%@*} is already at the latest version (1.0.0)."
FAKE
  chmod +x "${fakebin}/claude"
}

write_settings() {
  mkdir -p "${tmproot}/home/.claude"
  cat >"${tmproot}/home/.claude/settings.json" <<'JSON'
{
  "enabledPlugins": {
    "codex@openai-codex": true,
    "untracked@somewhere": true,
    "disabled@somewhere": false,
    "cc-plugin-you-should-know@builtin": true
  }
}
JSON
}

# update_llms を実行し、stdout + stderr を ${out} へ。ink を外すため PATH は fake と最低限に絞る。
run_update_llms() {
  out=$(HOME="${tmproot}/home" PATH="${fakebin}:/usr/bin:/bin" "${target_bin}" 2>&1)
}

# 1. 有効で未登録のものだけを warn する。
test_warn_uncovered() {
  FAKE_UPDATED_PLUGIN='' run_update_llms
  check 'warn: untracked enabled plugin' '1' "$(contains "${out}" 'untracked@somewhere is enabled but not auto-updated')"
  check 'warn: not for disabled plugin' '0' "$(contains "${out}" 'disabled@somewhere')"
  check 'warn: not for builtin plugin' '0' "$(contains "${out}" 'cc-plugin-you-should-know@builtin is enabled')"
  check 'warn: not for tracked plugin' '0' "$(contains "${out}" 'codex@openai-codex is enabled')"
}

# 2. 更新が無ければ「No updates.」を出す。
test_report_no_updates() {
  FAKE_UPDATED_PLUGIN='' run_update_llms
  check 'report: no updates' '1' "$(contains "${out}" '==> No updates.')"
}

# 3. 更新されたものだけを最後に一覧で出す。
test_report_updated() {
  FAKE_UPDATED_PLUGIN='stripe@claude-plugins-official' run_update_llms
  local summary
  summary=$(sed -n '/==> Updated:/,$p' <<<"${out}")
  check 'report: updated plugin listed' '1' "$(contains "${summary}" 'Plugin "stripe@claude-plugins-official" updated from 1.0.0 to 1.1.0')"
  check 'report: up-to-date plugin not listed' '0' "$(contains "${summary}" 'already at the latest')"
}

main() {
  set -uo pipefail
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0
  write_fake_bins
  write_settings

  test_warn_uncovered
  test_report_no_updates
  test_report_updated

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
