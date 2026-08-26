#!/usr/bin/env bash

# bin/adf2md のユニットテスト (実 jira 不要)。
#
# ADF ノードの JSON を stdin に流し、期待する markdown と突き合わせる。
# 対象ノードは実 Jira の実測 (`jq '.. | .type? // empty' | sort | uniq -c`) で
# 出てきたものを基準に選んでいる。
#
#   test/adf2md.test.sh   # 全テスト実行

# 期待値の markdown にはバッククォート (code / フェンス) がそのまま入る。
# shellcheck disable=SC2016
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
adf2md=$(cd "${script_dir}/../bin" && pwd)/adf2md

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

# stdin の ADF を doc ノードで包んで変換する (実データは常に doc が根)。
convert() {
  jq -c '{type: "doc", content: [.]}' | "${adf2md}"
}

# 1. paragraph は 1 行の段落になる
test_paragraph() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"paragraph","content":[{"type":"text","text":"hello"}]}
EOF
  )
  check 'paragraph が段落になる' 'hello' "${actual}"
}

# 2. text の mark が markdown の装飾になる
test_text_marks() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"paragraph","content":[
  {"type":"text","text":"b","marks":[{"type":"strong"}]},
  {"type":"text","text":"i","marks":[{"type":"em"}]},
  {"type":"text","text":"c","marks":[{"type":"code"}]},
  {"type":"text","text":"s","marks":[{"type":"strike"}]}]}
EOF
  )
  check 'strong/em/code/strike が変換される' '**b**_i_`c`~~s~~' "${actual}"
}

# 3. link mark は他の mark より外側に出る (URL がバッククォートの内側に入らない)
test_link_mark_wraps_outermost() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"paragraph","content":[
  {"type":"text","text":"docs","marks":[{"type":"link","attrs":{"href":"https://e.x/d"}},{"type":"code"}]}]}
EOF
  )
  check 'link は code の外側に付く' '[`docs`](https://e.x/d)' "${actual}"
}

# 4. hardBreak は markdown のハードブレーク (行末 2 スペース) になる
test_hard_break() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"paragraph","content":[
  {"type":"text","text":"a"},{"type":"hardBreak"},{"type":"text","text":"b"}]}
EOF
  )
  check 'hardBreak が行末 2 スペースになる' "$(printf 'a  \nb')" "${actual}"
}

# 5. codeBlock は言語名付きのフェンスになる (plain 出力では失われる情報)
test_code_block_keeps_language() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"codeBlock","attrs":{"language":"bash"},"content":[{"type":"text","text":"echo hello\necho world"}]}
EOF
  )
  check 'codeBlock が言語付きフェンスになる' \
    "$(printf '```bash\necho hello\necho world\n```')" "${actual}"
}

# 6. 言語指定なしの codeBlock も壊れない
test_code_block_without_language() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"codeBlock","content":[{"type":"text","text":"x"}]}
EOF
  )
  check '言語なし codeBlock がフェンスになる' "$(printf '```\nx\n```')" "${actual}"
}

# 7. heading は level 個の # になる
test_heading() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"heading","attrs":{"level":3},"content":[{"type":"text","text":"T"}]}
EOF
  )
  check 'heading が level 個の # になる' '### T' "${actual}"
}

# 8. bulletList のネストは 2 スペースで、間に空行を入れない (loose list 化を防ぐ)
test_bullet_list_nesting() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"bulletList","content":[
  {"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"one"}]}]},
  {"type":"listItem","content":[
    {"type":"paragraph","content":[{"type":"text","text":"two"}]},
    {"type":"bulletList","content":[
      {"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"nested"}]}]}]}]}]}
EOF
  )
  check 'bulletList の入れ子が 2 スペースで詰まる' \
    "$(printf -- '- one\n- two\n  - nested')" "${actual}"
}

# 9. orderedList は連番になり、継続行はマーカー幅だけ下がる
test_ordered_list_numbers_and_indent() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"orderedList","content":[
  {"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"first"}]}]},
  {"type":"listItem","content":[
    {"type":"paragraph","content":[{"type":"text","text":"second"}]},
    {"type":"codeBlock","attrs":{"language":"go"},"content":[{"type":"text","text":"x := 1"}]}]}]}
EOF
  )
  check 'orderedList が連番になり継続行が 3 スペース下がる' \
    "$(printf '1. first\n2. second\n\n   ```go\n   x := 1\n   ```')" "${actual}"
}

# 10. blockquote は全行に "> " が付く
test_blockquote() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"blockquote","content":[
  {"type":"paragraph","content":[{"type":"text","text":"a"}]},
  {"type":"paragraph","content":[{"type":"text","text":"b"}]}]}
EOF
  )
  check 'blockquote の全行に > が付く' "$(printf '> a\n> \n> b')" "${actual}"
}

# 11. mention は @表示名 になる (attrs.text に @ が付いていても二重にしない)
test_mention() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"paragraph","content":[
  {"type":"mention","attrs":{"text":"@Person A","id":"x"}},
  {"type":"text","text":"/"},
  {"type":"mention","attrs":{"text":"Person B","id":"y"}}]}
EOF
  )
  check 'mention が @ 付き 1 個になる' '@Person A/@Person B' "${actual}"
}

# 12. inlineCard は自動リンクになる
test_inline_card() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"paragraph","content":[{"type":"inlineCard","attrs":{"url":"https://e.x/c"}}]}
EOF
  )
  check 'inlineCard が自動リンクになる' '<https://e.x/c>' "${actual}"
}

# 13. table は 1 行目をヘッダにした markdown table になる
test_table() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"table","content":[
  {"type":"tableRow","content":[
    {"type":"tableHeader","content":[{"type":"paragraph","content":[{"type":"text","text":"h1"}]}]},
    {"type":"tableHeader","content":[{"type":"paragraph","content":[{"type":"text","text":"h2"}]}]}]},
  {"type":"tableRow","content":[
    {"type":"tableCell","content":[{"type":"paragraph","content":[{"type":"text","text":"a"}]}]},
    {"type":"tableCell","content":[{"type":"paragraph","content":[{"type":"text","text":"b"}]}]}]}]}
EOF
  )
  check 'table がヘッダ区切り付きで出る' \
    "$(printf '| h1 | h2 |\n| --- | --- |\n| a | b |')" "${actual}"
}

# 14. 未知ノードは自身の殻を捨てて子だけ出す (テキストを落とさない)
test_unknown_node_falls_back_to_children() {
  local actual
  actual=$(
    convert <<'EOF'
{"type":"expand","attrs":{"title":"t"},"content":[
  {"type":"paragraph","content":[{"type":"text","text":"inside"}]}]}
EOF
  )
  check '未知ノードは子だけ出力する' 'inside' "${actual}"
}

# 15. JSON null (description 未設定) は空出力
test_null_is_empty() {
  local actual
  actual=$(printf 'null' | "${adf2md}")
  check 'null は空出力' '' "${actual}"
}

# 16. doc 直下の複数ブロックは空行で区切られる
test_doc_blocks_are_separated_by_blank_line() {
  local actual
  actual=$(printf '%s' '{"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"a"}]},{"type":"paragraph","content":[{"type":"text","text":"b"}]}]}' | "${adf2md}")
  check 'doc 直下のブロックが空行で区切られる' "$(printf 'a\n\nb')" "${actual}"
}

main() {
  local pass=0 fail=0

  test_paragraph
  test_text_marks
  test_link_mark_wraps_outermost
  test_hard_break
  test_code_block_keeps_language
  test_code_block_without_language
  test_heading
  test_bullet_list_nesting
  test_ordered_list_numbers_and_indent
  test_blockquote
  test_mention
  test_inline_card
  test_table
  test_unknown_node_falls_back_to_children
  test_null_is_empty
  test_doc_blocks_are_separated_by_blank_line

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
