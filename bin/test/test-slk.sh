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

install_fake_curl() {
  mkdir -p "${fake_bin}"
  cat >"${fake_bin}/curl" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"${tmproot}/curl.args"
cat >"${tmproot}/posted"
echo '{"ok":true}'
EOF
  chmod +x "${fake_bin}/curl"
}

send() {
  : >"${tmproot}/posted"
  : >"${tmproot}/curl.args"
  HOME="${tmproot}" PATH="${fake_bin}:${PATH}" "${bin_dir}/slk" -t token -c C0000 "$@" >/dev/null
}

test_code_wraps_message() {
  printf 'a\nb\n' | send -co
  check '-co は本文を ``` で囲んで送る' $'```\na\nb\n```' "$(cat "${tmproot}/posted")"
}

test_code_long_message_stays_post() {
  seq 20 | send -co -nu
  check "-co -nu は 10 行を超えても file にせず、chat.postMessage の 1 件で送る" 1 \
    "$(grep -c 'chat.postMessage' "${tmproot}/curl.args")"
  check "-co -nu の本文は、囲みの 2 行と 20 行" 22 "$(wc -l <"${tmproot}/posted")"
}

test_plain_message_unchanged() {
  printf 'a\n' | send
  check "-co なしは本文をそのまま送る" 'a' "$(cat "${tmproot}/posted")"
}

main() {
  set -euo pipefail
  local pass=0 fail=0
  local tmproot
  tmproot=$(mktemp -d)
  # shellcheck disable=SC2064
  trap "rm -rf '${tmproot}'" EXIT
  local fake_bin="${tmproot}/bin"
  install_fake_curl

  test_code_wraps_message
  test_code_long_message_stays_post
  test_plain_message_unchanged

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
