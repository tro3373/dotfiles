#!/usr/bin/env bash
#
# fix-exif-dates.sh
#   写真/動画の日時を一括補正する。基準(最古)ファイルの「正しい日時」を
#   1 つ決めれば、他の全ファイルは相対的な時刻差を保ったまま同じオフセット
#   で補正される(カメラの時計未設定で日付がずれた素材の救済用)。
#
#   補正対象は日時メタデータを持つファイルのみ:
#     - 動画 : QuickTime:CreateDate 等
#     - 画像 : EXIF AllDates
#     - あわせてファイル更新日時(mtime)も同じ日時に揃える
#
# 使い方:
#   ./fix-exif-dates.sh -t "2024-07-15 12:58:37"        # 基準日時を指定・ドライラン
#   ./fix-exif-dates.sh -t 2024-07-15                   # 日付のみ(時刻は基準ファイルの元時刻を流用)
#   ./fix-exif-dates.sh -t 2024-07-15 -d /path/to/media # 対象ディレクトリ指定
#   ./fix-exif-dates.sh -t 2024-07-15 --apply           # 実際に書き換え
#
# 前提: GNU date / stat (Linux, または coreutils 導入済み macOS)
# 依存: exiftool

readonly media_video_exts='mp4|mov|m4v|avi|mkv|mts|m2ts|lrv'
readonly media_image_exts='jpg|jpeg|png|heic|heif|tif|tiff|dng|gpr|thm|cr2|cr3|nef|arw|rw2|orf'

usage() {
  cat >&2 <<'USAGE'
Usage: fix-exif-dates.sh -t DT [options]

  -t, --date DT      基準(最古)ファイルの正しい日時 (必須)。
                     "YYYY-MM-DD HH:MM:SS" / "YYYY-MM-DD" (時刻は元の時刻を流用)。
  -d, --dir DIR      対象ディレクトリ (default: カレント)。
  -a, --apply        実際に書き換える (省略時はドライラン)。
  -h, --help         このヘルプを表示。
USAGE
}

die() {
  echo "==> Error: $*" >&2
  exit 1
}

parse_dt() {
  local raw="$1"
  local d="${raw%% *}" t="${raw#* }"
  date -d "${d//:/-} ${t}" +%s
}

fmt_exif() { date -d "@$1" "+%Y:%m:%d %H:%M:%S"; }
fmt_clock() { date -d "@$1" "+%H:%M:%S"; }
fmt_touch() { date -d "@$1" "+%Y%m%d%H%M.%S"; }

# 拡張子から video / image / skip を判定
classify_ext() {
  local ext="${1##*.}" result="skip"
  shopt -s nocasematch
  [[ ${ext} =~ ^(${media_video_exts})$ ]] && result="video"
  [[ ${ext} =~ ^(${media_image_exts})$ ]] && result="image"
  shopt -u nocasematch
  printf '%s' "${result}"
}

# ファイルから日時を1つ読む(なければ空文字)。DateTimeOriginal > CreateDate の優先度。
read_date() {
  exiftool -s3 -DateTimeOriginal -CreateDate -QuickTime:CreateDate -- "$1" 2>/dev/null |
    awk 'NF{print; exit}'
}

# --date の入力を "YYYY:MM:DD HH:MM:SS" 形式へ正規化(時刻省略時は ref_time)
normalize_target() {
  local raw="$1" datepart timepart="${ref_time}"
  datepart="${raw%% *}"
  [[ ${raw} == *" "* ]] && timepart="${raw#* }"
  printf '%s %s' "${datepart//-/:}" "${timepart}"
}

# 対象(日時メタ有り)ファイルを走査し g_files / g_kinds / g_epochs を構築
scan_files() {
  local file base kind date

  while IFS= read -r -d '' file; do
    base="${file#./}"
    kind=$(classify_ext "${base}")
    [[ ${kind} == "skip" ]] && continue

    date=$(read_date "${file}")
    [[ -z ${date} ]] && continue

    g_files+=("${base}")
    g_kinds+=("${kind}")
    g_epochs+=("$(parse_dt "${date}")")
  done < <(find . -maxdepth 1 -type f -print0 | sort -z)

  [[ ${#g_files[@]} -gt 0 ]] || die "日時メタデータを持つメディアファイルが見つからない: ${target_dir}"
}

# 最古の日時を持つファイルを基準に決める
find_reference() {
  local i

  ref_index=0
  for ((i = 1; i < ${#g_files[@]}; i++)); do
    ((g_epochs[i] < g_epochs[ref_index])) && ref_index="${i}"
  done

  ref_file="${g_files[$ref_index]}"
  ref_epoch="${g_epochs[$ref_index]}"
  ref_time=$(fmt_clock "${ref_epoch}")
}

# 補正後の目標日時からオフセットを計算する
resolve_offset() {
  target_str=$(normalize_target "${opt_date}")
  target_epoch=$(parse_dt "${target_str}") || die "日時の形式が不正: ${opt_date}"
  offset=$((target_epoch - ref_epoch))
}

print_plan() {
  local i old new

  printf '==> 対象ディレクトリ: %s\n' "${target_dir}" >&2
  printf '==> 基準ファイル    : %s\n' "${ref_file}" >&2
  printf '==> 現在の基準日時  : %s\n' "$(fmt_exif "${ref_epoch}")" >&2
  printf '==> 補正後の基準日時: %s\n' "${target_str}" >&2
  printf '==> オフセット      : %s 秒 (約 %s 日)\n' "${offset}" "$((offset / 86400))" >&2
  printf '==> モード          : %s\n' "${mode_label}" >&2
  printf '%s\n' '------------------------------------------------------------' >&2
  for ((i = 0; i < ${#g_files[@]}; i++)); do
    old=$(fmt_exif "${g_epochs[$i]}")
    new=$(fmt_exif "$((g_epochs[i] + offset))")
    printf '  %-16s %s -> %s\n' "${g_files[$i]}" "${old}" "${new}" >&2
  done
  printf '%s\n' '------------------------------------------------------------' >&2
}

# 内部メタデータを書き込む(動画/画像でタグ集合を分ける)
write_meta() {
  local file="$1" kind="$2" new="$3"

  if [[ ${kind} == "video" ]]; then
    exiftool -q -overwrite_original \
      -QuickTime:CreateDate="${new}" -QuickTime:ModifyDate="${new}" \
      -TrackCreateDate="${new}" -TrackModifyDate="${new}" \
      -MediaCreateDate="${new}" -MediaModifyDate="${new}" -- "${file}"
    return
  fi
  exiftool -q -overwrite_original -AllDates="${new}" -- "${file}"
}

apply_changes() {
  local i newep new

  for ((i = 0; i < ${#g_files[@]}; i++)); do
    newep=$((g_epochs[i] + offset))
    new=$(fmt_exif "${newep}")
    write_meta "${g_files[$i]}" "${g_kinds[$i]}" "${new}" ||
      die "メタ書き込み失敗: ${g_files[$i]}"
    # exiftool 書き込みで mtime が現在時刻になるため、必ず後から補正する
    touch -t "$(fmt_touch "${newep}")" -- "${g_files[$i]}"
  done
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t | --date)
        [[ -n ${2:-} ]] || die "-t には日時が必要。"
        opt_date="$2"
        shift 2
        ;;
      -d | --dir)
        [[ -n ${2:-} ]] || die "-d にはディレクトリが必要。"
        opt_dir="$2"
        shift 2
        ;;
      -a | --apply)
        opt_apply=1
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        usage
        die "不明なオプション: $1"
        ;;
    esac
  done
  [[ -n ${opt_date} ]] || {
    usage
    die "-t / --date は必須。"
  }
}

main() {
  set -euo pipefail

  local opt_dir="" opt_date="" opt_apply=0
  local target_dir mode_label
  local ref_index ref_epoch ref_file ref_time
  local target_str target_epoch offset
  local g_files=() g_kinds=() g_epochs=()

  parse_args "$@"

  command -v exiftool >/dev/null 2>&1 || die "exiftool が無い。'brew install exiftool' を実行して。"

  target_dir="${opt_dir:-.}"
  [[ -d ${target_dir} ]] || die "ディレクトリが無い: ${target_dir}"
  cd "${target_dir}"
  target_dir="$(pwd)"

  mode_label="DRY-RUN (確認のみ)"
  ((opt_apply)) && mode_label="APPLY (実書き換え)"

  scan_files
  find_reference
  resolve_offset
  print_plan

  if ((!opt_apply)); then
    printf '==> ドライラン終了。適用するには -a / --apply を付けて再実行。\n' >&2
    return 0
  fi

  apply_changes
  printf '==> 完了。\n' >&2
}

main "$@"
