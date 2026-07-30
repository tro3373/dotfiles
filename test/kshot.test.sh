#!/usr/bin/env bash

# bin/kshot のユニットテスト (adb だけ fake に差し替え)。
#
# magick / img2pdf / zip は本物を使う。kshot の中身はほぼ「magick に何をどう
# 渡すか」で、そこを fake にすると検証したい事が全部消えてしまう為。
#
# 担保したいのは 4 つ。
#
# screencap の stderr 捨て: Waydroid の Android は起動時に amdgpu.ids が無いと
#   stdout 側へ警告を吐く。exec-out はそれを PNG の頭に混ぜてしまい、撮れた
#   はずのファイルが全部壊れる。shell の中で捨てているかを見る (回帰テスト)。
#
# 終端判定: 「同じ画面が k 回続いたら終わり」で止まり、末尾に溜まった重複 k 枚を
#   捨てて本文だけ残すこと。ここがずれると本の最後が欠けるか、最終ページの
#   コピーが尻に付く。
#
# 比較領域: 上下 5% を落として比べていること。ステータスバーの時計は毎分変わる
#   ので、全画面で比べると永久に「変化あり」になり -n の上限まで撮り続ける。
#   fake は上端に毎ショット変わる点を描いて、それを再現する。
#
# 前面チェックと上限到達: Kindle 以外を撮り始めない事と、-n に当たった時に黙って
#   打ち切らず警告する事。どちらも「欠けた本が黙って出来る」を防ぐ為。
#
#   test/kshot.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kshot_bin=$(cd "${script_dir}/../bin" && pwd)/kshot

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

# 200x100 の偽スクリーン。黒地に白い矩形 (20,10)-(180,90) を置き、その内側 y=50 に
# ページ毎に動く目印を描く。FAKE_PAGES 枚を超えたら目印が動かなくなり「最終ページで
# ページ送りしても画面が変わらない」Kindle の挙動になる。
# FAKE_CLOCK=1 の時は上端 y=1..3 に毎ショット動く点を足す。これが時計の代役で、
# 比較領域が上端を含んでいると永久に終端へ辿り着かなくなる。
new_fakebin() {
  fakebin="${tmproot}/bin"
  LOG="${tmproot}/calls.log"
  CNT="${tmproot}/shots"
  mkdir -p "${fakebin}"

  cat >"${fakebin}/adb" <<'EOS'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${LOG}"
[[ $1 == -s ]] && shift 2
cmd=$1
shift
case ${cmd} in
  get-state) echo device ;;
  shell)
    case "$*" in
      "wm size") printf 'Physical size: 200x100\r\n' ;;
      dumpsys*)
        printf '  topResumedActivity=ActivityRecord{0 u0 %s/.Main} t1}\r\n' \
          "${FAKE_TOP:-com.amazon.kindle}"
        ;;
    esac
    ;;
  exec-out)
    n=$(<"${CNT}")
    n=$((n + 1))
    printf '%s' "${n}" >"${CNT}"
    p=${n}
    ((p > FAKE_PAGES)) && p=${FAKE_PAGES}
    args=(-size 200x100 xc:black
      -fill white -draw "rectangle 20,10 180,90"
      -fill black -draw "rectangle $((30 + p * 3)),45 $((36 + p * 3)),55")
    [[ ${FAKE_CLOCK:-} == 1 ]] &&
      args+=(-fill white -draw "rectangle $((n % 7)),1 $((n % 7 + 2)),3")
    # 実機の screencap は RGBA で来る。alpha を落とす後処理を試したいので偽物も
    # png32 (= 8bit RGBA 固定) で出す
    magick "${args[@]}" png32:-
    ;;
esac
exit 0
EOS

  chmod +x "${fakebin}/adb"
  export LOG CNT
}

# fakebin 経由で kshot を実行する。-w 0 は待ち時間を潰す為 (実機では描画待ちが要る)。
run_kshot() {
  : >"${LOG}"
  printf '0' >"${CNT}"
  PATH="${fakebin}:${PATH}" KSHOT_SERIAL=fake:5555 KSHOT_OUT="${tmproot}/out" \
    "${kshot_bin}" -w 0 "$@" >"${tmproot}/stdout" 2>"${tmproot}/stderr"
}

count_png() {
  local d="${tmproot}/out/$1/$2"
  [[ -d ${d} ]] || {
    echo 0
    return
  }
  find "${d}" -name '*.png' | wc -l
}

# --- screencap の呼び方 -----------------------------------------------------

# 1. exec-out の中で stderr を捨てている事。捨て忘れると Waydroid の警告が PNG の
#    頭に混ざって全ページ壊れる。壊れた PNG は magick が読めず落ちるだけなので、
#    撮り方そのものを引数で見る。
test_screencap_drops_stderr() {
  export FAKE_PAGES=3
  run_kshot a1

  check 'screencap を呼んでいる' '5' "$(grep -c -- 'exec-out' "${LOG}")"
  check 'stderr を捨てずに呼んだ screencap は無い' '0' \
    "$(grep -- 'exec-out' "${LOG}" | grep -vc -- 'screencap -p 2>/dev/null')"
}

# --- 終端判定 ---------------------------------------------------------------

# 2. 同じ画面が 2 回続いたら止め、末尾の重複 2 枚を捨てて本文 4 枚だけ残す。
test_stops_at_duplicate_and_drops_them() {
  export FAKE_PAGES=4
  run_kshot a2

  check '本文 4 ページだけ残る' '4' "$(count_png a2 raw)"
  check '重複を捨てても撮影自体は成功扱い' '0' "$?"
}

# 3. -k は重複の許容回数。3 にしても捨てる枚数が追随し、本文は 4 枚のまま。
#    ここが固定だと -k を上げた分だけ最終ページのコピーが尻に残る。
test_stop_after_is_honored() {
  export FAKE_PAGES=4
  run_kshot -k 3 a3

  check '-k 3 でも本文は 4 ページ' '4' "$(count_png a3 raw)"
}

# 4. 上端が毎ショット変わっても終端に辿り着く。比較領域が全画面だと時計で永久に
#    差が出続け、-n の上限 (ここでは 12) まで撮り切ってしまう。
test_ignores_changing_status_bar() {
  export FAKE_PAGES=4 FAKE_CLOCK=1
  run_kshot -n 12 a4
  unset FAKE_CLOCK

  check '時計が動いても 4 ページで止まる' '4' "$(count_png a4 raw)"
}

# 5. -n に当たったら黙って打ち切らず警告する。撮り切れていない本を「完了」と
#    見せるのが一番まずい。
test_warns_on_max_pages() {
  export FAKE_PAGES=99
  run_kshot -n 3 a5

  check '上限到達を警告する' '1' \
    "$(grep -c 'hit -n 3' "${tmproot}/stderr")"
  check '上限までは撮る' '3' "$(count_png a5 raw)"
  # 上限で抜けた時だけループ変数が本文の枚数より 1 多くなる。報告がずれると
  # 「何ページ撮れたのか」を信じられなくなる
  check '報告した枚数が実ファイルと合う' '1' \
    "$(grep -c 'captured 3 pages' "${tmproot}/stderr")"
}

# --- ページ送りの向き -------------------------------------------------------

# 6. 既定は左開き (英語書籍) 向きで、画面を右から左へ払う。200x100 の偽スクリーン
#    なので 4/5=160 から 1/5=40 へ。
test_swipe_defaults_to_ltr() {
  export FAKE_PAGES=3
  run_kshot b1

  check 'ページ送りを実際に打っている' '4' "$(grep -c -- 'shell input swipe' "${LOG}")"
  check '既定と違う向きに払った swipe は無い' '0' \
    "$(grep -- 'shell input swipe' "${LOG}" | grep -vc -- 'swipe 160 50 40 50 100')"
}

# 7. -R は向きを反転する。縦書きの日本語書籍は右開きで、既定の向きだと 1 ページ目
#    から一歩も動かない (実機で確認済み)。向きの取り違えは「数ページの本」が
#    黙って出来る形で表面化するので、ここは固定しておく。
test_rtl_reverses_direction() {
  export FAKE_PAGES=3
  run_kshot -R b2

  check '-R では全ての swipe が左->右' '0' \
    "$(grep -- 'shell input swipe' "${LOG}" | grep -vc -- 'swipe 40 50 160 50 100')"
  check '-R では既定の向きを一度も使わない' '0' \
    "$(grep -c -- 'shell input swipe 160 50' "${LOG}")"
}

# 8. -p tap も同じ向きの規則に従う。突く端が逆だと前のページへ戻ってしまう。
test_tap_follows_direction() {
  export FAKE_PAGES=3
  run_kshot -p tap b3
  check '既定の tap は右端だけ' '0' \
    "$(grep -- 'shell input tap' "${LOG}" | grep -vc -- 'tap 190 50')"
  check 'tap を選ぶと swipe しない' '0' "$(grep -c -- 'shell input swipe' "${LOG}")"

  run_kshot -p tap -R b4
  check '-R の tap は左端だけ' '0' \
    "$(grep -- 'shell input tap' "${LOG}" | grep -vc -- 'tap 10 50')"
}

# 9. 知らない -p は撮り始める前に落とす。数十分かけた撮影の後で気付くのは遅い。
test_rejects_unknown_turn_method() {
  export FAKE_PAGES=3
  run_kshot -p fling b5
  local rc=$?

  check '不正な -p は非ゼロ終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check '不正な -p では adb を触らない' '0' "$(grep -c 'exec-out' "${LOG}")"
}

# --- 前面チェック -----------------------------------------------------------

# 10. Kindle が前面に無ければ撮らない。ライブラリ画面やホーム画面を延々撮って
#    しまうのを防ぐ。
test_refuses_when_kindle_not_foreground() {
  export FAKE_PAGES=4 FAKE_TOP=com.example.other
  run_kshot a6
  local rc=$?
  unset FAKE_TOP

  check '前面が Kindle でなければ非ゼロ終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check '前面が Kindle でなければ 1 枚も撮らない' '0' "$(count_png a6 raw)"
}

# 11. raw が既にあれば上書きしない。撮り直しの取り違えで数十分かけた撮影を
#    潰さない為。
test_refuses_to_overwrite_existing_raw() {
  export FAKE_PAGES=3
  run_kshot a7
  local before
  before=$(count_png a7 raw)
  run_kshot a7
  local rc=$?

  check '既存 raw があれば非ゼロ終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check '既存 raw は残る' "${before}" "$(count_png a7 raw)"
}

# --- 後処理 -----------------------------------------------------------------

# 12. トリムは全ページ共通の矩形で切る。ページ毎に trim すると寸法がばらつき、
#    PDF がページ毎に伸縮する。
test_trims_all_pages_to_one_size() {
  export FAKE_PAGES=4
  run_kshot a8

  local sizes
  sizes=$(magick identify -format '%wx%h\n' "${tmproot}/out/a8/png"/*.png | sort -u)
  check '全ページ同一寸法' '1' "$(echo "${sizes}" | wc -l)"
  check '黒枠が落ちて白矩形だけ残る' '161x81' "${sizes}"
  # screencap は全面不透明の alpha を持って来る。残したまま PDF にすると
  # img2pdf が soft mask を別に作って無駄に膨らむ。生側の確認も入れておかないと
  # 「そもそも alpha が無かった」で素通りする空テストになる
  # %[channels] は白黒だけの画像を gray と書くので alpha の有無は %A で見る
  check '生画像は alpha を持っている' 'Blend' \
    "$(magick identify -format '%A' "${tmproot}/out/a8/raw/page_0001.png")"
  check 'トリム後は alpha を落としてある' '0' \
    "$(magick identify -format '%A\n' "${tmproot}/out/a8/png"/*.png |
      grep -vc '^Undefined$')"
}

# 13. PDF と zip が実際に出来る。zip は本 1 冊分の PNG をまとめたもの。
test_emits_pdf_and_zip() {
  export FAKE_PAGES=4
  run_kshot a9

  check 'PDF が出来る' '1' "$([[ -s ${tmproot}/out/a9/a9.pdf ]] && echo 1 || echo 0)"
  check 'zip に本文 4 枚入る' '4' \
    "$(unzip -Z1 "${tmproot}/out/a9/a9.zip" | grep -c '\.png$')"
}

# 14. -r は撮影を飛ばして後処理だけやり直す。トリムし直しの度に本を撮り直させない為。
test_redo_skips_capture() {
  export FAKE_PAGES=4
  run_kshot a10
  rm -rf "${tmproot}/out/a10/png"
  run_kshot -r a10

  check '-r では screencap しない' '0' "$(grep -c 'exec-out' "${LOG}")"
  check '-r で png を作り直す' '4' "$(count_png a10 png)"
}

main() {
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  pass=0
  fail=0
  new_fakebin

  test_screencap_drops_stderr
  test_stops_at_duplicate_and_drops_them
  test_stop_after_is_honored
  test_ignores_changing_status_bar
  test_warns_on_max_pages
  test_swipe_defaults_to_ltr
  test_rtl_reverses_direction
  test_tap_follows_direction
  test_rejects_unknown_turn_method
  test_refuses_when_kindle_not_foreground
  test_refuses_to_overwrite_existing_raw
  test_trims_all_pages_to_one_size
  test_emits_pdf_and_zip
  test_redo_skips_capture

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
