#!/usr/bin/env bash

# apps/nvim/nvim/lua/filetypes.lua の拡張子判定上書きのテスト (実 nvim headless)。
#
# nvim 組み込み (runtime/lua/vim/filetype.lua) は `.gs` を GrADS スクリプト
# (filetype=grads) と判定する。扱うのは GAS (Google Apps Script) のみなので
# javascript へ固定する。その上書きが効いているかを確認する。
#
# filetypes.lua は依存ゼロの純設定なので、--clean な nvim に dofile して
# 単体で検証する (lazy.nvim / mason 等を起動しない)。
#
# 検証対象 (要件):
#   * *.gs を開くと filetype=javascript
#   * プロジェクトマーカー無しの任意ディレクトリでも javascript
#   * .js / .ts 等の既存拡張子判定は変わらない
#   * 上書き前の nvim 既定は grads (対比。上書きが効いている証拠)
#
# 対象外: .gs バッファへの ts_ls attach (lazy/mason 起動が必要なため実機手動確認)
#
#   test/nvim-gs-filetype.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ftconf=$(cd "${script_dir}/../apps/nvim/nvim/lua" && pwd)/filetypes.lua

tmproot=$(mktemp -d)
trap 'rm -rf "${tmproot}"' EXIT
probe="${tmproot}/probe.txt"

pass=0
fail=0

# desc / expected / actual を比較し、pass・fail カウンタを更新する。
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

# filetypes.lua を読み込んでから対象ファイルを開き、filetype を probe に書き出す。
driver="${tmproot}/driver.lua"
cat >"${driver}" <<'LUA'
if vim.env.gs_ftconf ~= "" then
  dofile(vim.env.gs_ftconf)
end
vim.cmd.edit(vim.fn.fnameescape(vim.env.gs_file))
vim.fn.writefile({ vim.bo.filetype }, vim.env.gs_out)
vim.cmd("qa!")
LUA

# $1=対象ファイル, $2=filetypes.lua パス (空なら上書き無しの nvim 既定)。
# 判定された filetype を返す。nvim 自体が落ちた場合は NVIM_ERROR を返し、
# 「判定結果が空」と区別できるようにする ($(detect) は check の引数位置で
# 評価されるため set -e では検知できない)。
detect() {
  : >"${probe}"
  if ! gs_ftconf="$2" gs_file="$1" gs_out="${probe}" \
    nvim --headless --clean -l "${driver}" >/dev/null 2>&1; then
    printf 'NVIM_ERROR'
    return
  fi
  sed -n 1p "${probe}" 2>/dev/null
}

main() {
  set -euo pipefail

  # GAS のコード片。中身では判定しない (拡張子のみで判定する) ことの確認も兼ねる。
  local gas="${tmproot}/code.gs"
  printf 'function myFunction() {\n  Logger.log("hi");\n}\n' >"${gas}"

  # 1. 上書き無し (nvim 既定) => grads。上書きが必要な理由の裏付け
  check 'nvim 既定では .gs は grads' \
    'grads' "$(detect "${gas}" '')"

  # 2. filetypes.lua 適用 => javascript
  check '.gs を開くと filetype=javascript' \
    'javascript' "$(detect "${gas}" "${ftconf}")"

  # 3. プロジェクトマーカー (appsscript.json / .clasp.json) 無しの
  #    無関係なディレクトリでも javascript
  local plain="${tmproot}/no_marker/nested"
  mkdir -p "${plain}"
  printf 'var a = 1;\n' >"${plain}/script.gs"
  check 'マーカー無しディレクトリの .gs も javascript' \
    'javascript' "$(detect "${plain}/script.gs" "${ftconf}")"

  # 4. 空ファイルでも拡張子だけで javascript (中身依存でない)
  local empty="${tmproot}/empty.gs"
  : >"${empty}"
  check '空の .gs も javascript' \
    'javascript' "$(detect "${empty}" "${ftconf}")"

  # 5. init.lua から require されている。ここが外れると他ケースが全て pass の
  #    まま実 nvim では grads に戻る。実 config 起動は lazy.nvim / mason 依存で
  #    重いため、require 行の有無で配線を守る。
  local init="${script_dir}/../apps/nvim/nvim/init.lua"
  local wired='missing'
  grep -q '^require("filetypes")' "${init}" && wired='required'
  check 'init.lua が filetypes を require' 'required' "${wired}"

  # 6. 旧 au_ft_map (base.lua) からの移行。旧マッピング対象が移行後も同じ
  #    filetype に解決される。builtin と同結果の 9 件は組み込みに委譲し
  #    (filetypes.lua に書かない)、builtin と異なる 5 件のみ filetypes.lua が
  #    上書きする。`.js` / `.ts` の非退行もここで一緒に担保する。
  #    `.jade` は除外: 旧指定 markdown は実 config で vim-pug の ftdetect に
  #    常に上書きされる死に設定だったため移行せず vim-pug (=> pug) に委譲。
  #    プラグイン依存で --clean では再現できないため実機確認とする。
  local -a legacy_maps=(
    "a.js:javascript" "a.ejs:html" "a.py:python" "a.rb:ruby" "a.erb:ruby"
    "Gemfile:ruby" "a.coffee:coffee" "a.ts:typescript" "a.md:markdown"
    "a.gyp:json" "a.cson:json" "a.yml:yaml" "a.yaml:yaml"
    "Jenkinsfile:groovy"
  )
  local mapdir="${tmproot}/legacy"
  mkdir -p "${mapdir}"
  local pair name want
  for pair in "${legacy_maps[@]}"; do
    name=${pair%%:*}
    want=${pair##*:}
    printf '\n' >"${mapdir}/${name}"
    check "旧マッピング ${name} => ${want}" \
      "${want}" "$(detect "${mapdir}/${name}" "${ftconf}")"
  done

  # 7. base.lua は au_ft_map を使わない (移行完了の回帰ガード)
  local base="${script_dir}/../apps/nvim/nvim/lua/base.lua"
  local legacy_base='present'
  grep -q 'au_ft_map' "${base}" || legacy_base='removed'
  check 'base.lua が au_ft_map を使わない' 'removed' "${legacy_base}"

  # 8. 未使用になった au_ft_map ヘルパを global.lua から削除済み
  local glob="${script_dir}/../apps/nvim/nvim/lua/global.lua"
  local legacy_helper='present'
  grep -q 'au_ft_map' "${glob}" || legacy_helper='removed'
  check 'global.lua の au_ft_map 定義を削除' 'removed' "${legacy_helper}"

  echo
  echo "pass=${pass} fail=${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
