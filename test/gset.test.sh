#!/usr/bin/env bash

# bin/gset のユニットテスト (実 dconf を触らない)。
#
# 一時 schema を --schemadir で読ませ、保存先は keyfile backend の一時ファイルにする。
#
#   test/gset.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
gset=$(cd "${script_dir}/../bin" && pwd)/gset
schema=org.example.gset-test

# desc / expected / actual を比較し、呼び出し元 main の pass・fail カウンタを更新する。
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

# 一時 schema と keyfile backend を用意し、テストごとに保存値を空へ戻す。
setup() {
  rm -rf "${tmp}/config"
  # lint-ignore: uppercase gsettings keyfile backend が読む環境変数
  export XDG_CONFIG_HOME="${tmp}/config"
}

g() { "${gset}" -s "${tmp}/schemas" "$@" 2>/dev/null; }

# 1. --schemadir で標準外の schema を set / get できる
test_schemadir_set() {
  setup
  g set "${schema}" pos 2
  check 'schemadir の schema へ set できる' '2' "$(g get "${schema}" pos)"
}

# 2. add は要素が無ければ末尾へ足す
test_add_appends() {
  setup
  g set "${schema}" items "['a']"
  g add "${schema}" items b
  check 'add で末尾へ足す' "['a', 'b']" "$(g get "${schema}" items)"
}

# 3. add は空リストにも足せる
test_add_to_empty() {
  setup
  g add "${schema}" items a
  check '空リストへ add できる' "['a']" "$(g get "${schema}" items)"
}

# 4. add は既にある要素を重複させない
test_add_idempotent() {
  setup
  g set "${schema}" items "['a', 'b']"
  g add "${schema}" items a
  check '既存要素は足さない' "['a', 'b']" "$(g get "${schema}" items)"
}

# 5. dry-run は変更せず、schemadir 付きの gsettings コマンドを表示する
test_add_dry_run() {
  setup
  local actual
  actual=$(g -n add "${schema}" items a)
  check 'dry-run は gsettings コマンドを表示する' \
    "gsettings --schemadir ${tmp}/schemas set ${schema} items ['a']" "${actual}"
  check 'dry-run は値を変えない' '@as []' "$(g get "${schema}" items)"
}

main() {
  set -uo pipefail
  local pass=0 fail=0
  tmp=$(mktemp -d)
  trap 'rm -rf "${tmp}"' EXIT
  # lint-ignore: uppercase gsettings が読む環境変数
  export GSETTINGS_BACKEND=keyfile
  mkdir -p "${tmp}/schemas"
  cat >"${tmp}/schemas/${schema}.gschema.xml" <<EOF
<schemalist>
  <schema id="${schema}" path="/org/example/gset-test/">
    <key type="i" name="pos"><default>0</default></key>
    <key type="as" name="items"><default>[]</default></key>
  </schema>
</schemalist>
EOF
  glib-compile-schemas "${tmp}/schemas"

  test_schemadir_set
  test_add_appends
  test_add_to_empty
  test_add_idempotent
  test_add_dry_run

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
