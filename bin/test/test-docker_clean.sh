#!/usr/bin/env bash

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

write_fixture() {
  cat >"${tmp}/df.json" <<EOF
{
  "Images": [
    {"ID": "sha256:${hex_a}", "Repository": "<none>", "Tag": "<none>", "Containers": "0", "Size": "100MB"},
    {"ID": "sha256:${hex_b}", "Repository": "<none>", "Tag": "<none>", "Containers": "1", "Size": "110MB"},
    {"ID": "sha256:${hex_c}", "Repository": "myapp", "Tag": "old", "Containers": "0", "Size": "1.2GB"},
    {"ID": "sha256:${hex_d}", "Repository": "myapp", "Tag": "live", "Containers": "2", "Size": "1.3GB"}
  ],
  "Volumes": [
    {"Name": "${hex_a}", "Labels": "com.docker.volume.anonymous=", "Links": "0", "Size": "80MB"},
    {"Name": "${hex_b}", "Labels": "com.docker.volume.anonymous=", "Links": "1", "Size": "81MB"},
    {"Name": "pgdata", "Labels": "", "Links": "0", "Size": "5MB"}
  ],
  "Containers": [
    {"ID": "c0ffee000001", "Names": "web-live", "Image": "myapp:live", "State": "running", "Status": "Up 1 hour", "Size": "1MB (virtual 1GB)"},
    {"ID": "c0ffee000002", "Names": "web-old", "Image": "myapp:old", "State": "exited", "Status": "Exited (0) 2 days ago", "Size": "0B (virtual 50MB)"},
    {"ID": "c0ffee000003", "Names": "web-new", "Image": "myapp:old", "State": "created", "Status": "Created", "Size": "0B (virtual 50MB)"}
  ],
  "BuildCache": []
}
EOF
  cat >"${tmp}/df-risky.json" <<EOF
{
  "Images": [{"ID": "sha256:${hex_c}", "Repository": "myapp", "Tag": "old", "Containers": "0", "Size": "1.2GB"}],
  "Volumes": [],
  "Containers": [],
  "BuildCache": []
}
EOF
}

install_fake_docker() {
  mkdir -p "${tmp}/docker-bin"
  cat >"${tmp}/docker-bin/docker" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  'system df -v --format {{json .}}') cat "${FAKE_DF}" ;;
  'system df --format {{json .}}')
    printf '%s\n' '{"Type":"Images","Reclaimable":"1GB (50%)"}' \
      "{\"Type\":\"Build Cache\",\"Reclaimable\":\"${FAKE_CACHE:-2.5GB}\"}"
    ;;
  inspect*) echo "INSPECT $2" ;;
  *) echo "$*" >>"${DOCKER_LOG}" ;;
esac
EOF
  chmod +x "${tmp}/docker-bin/docker"
}

install_fake_fzf() {
  mkdir -p "${tmp}/bin"
  cat >"${tmp}/bin/fzf" <<'EOF'
#!/usr/bin/env bash
header_lines=0
while [[ $# -gt 0 ]]; do
  [[ $1 == --header-lines ]] && header_lines="$2"
  shift
done
input=$(tail -n "+$((header_lines + 1))")
[[ -n ${FZF_LOG:-} ]] && printf '%s\n' "${input}" >"${FZF_LOG}"
[[ -n ${FZF_EXIT:-} ]] && exit "${FZF_EXIT}"
selected=$(printf '%s\n' "${input}" | grep -E "${FZF_PICK}")
[[ -z ${selected} ]] && exit 1
printf '%s\n' "${selected}"
EOF
  chmod +x "${tmp}/bin/fzf"
}

reset_log() {
  : >"${DOCKER_LOG}"
}

clean() {
  "${bin}" "$@" 2>/dev/null
}

docker_log() {
  paste -sd '|' "${DOCKER_LOG}"
}

offered() {
  FZF_PICK='^$' FZF_LOG="${tmp}/fzf.in" clean "$@" >/dev/null
  cut -f1-3 "${tmp}/fzf.in" | tr '\t' ' '
}

pick() {
  printf '%s\t%s\t%s\t' "$@"
}

test_safe_view() {
  check "既定: 🟢 だけ (dangling で未使用の image、無名で未使用の volume) を出す" \
    "safe image sha256:${hex_a}
safe volume ${hex_a}" "$(offered)"
}

test_all_view() {
  check "-a: 🟢 の後ろに ⚠️ を container・image・volume・cache の順で出す。使用中・running は出ない" \
    "safe image sha256:${hex_a}
safe volume ${hex_a}
risky container c0ffee000002
risky container c0ffee000003
risky image myapp:old
risky volume pgdata
risky cache build-cache" "$(offered -a)"
}

test_no_cache_row() {
  check "build cache の Reclaimable が 0B なら cache の行は出ない" \
    "" "$(FAKE_CACHE=0B offered -a | grep ' cache ' || true)"
}

test_display() {
  offered -a >/dev/null
  check "表示: 状態と種類の絵文字・種類名・名前・size・理由。64 桁の hex と image ID は 12 桁に縮める" \
    "🟢 🖼️ image ${hex_a:0:12} 100MB dangling
🟢 💾 volume ${hex_a:0:12} 80MB 無名
⚠️ 📦 container web-old 0B exited
⚠️ 📦 container web-new 0B created
⚠️ 🖼️ image myapp:old 1.2GB tag 付き・未使用
⚠️ 💾 volume pgdata 5MB 名前付き
⚠️ 🧹 cache build cache 2.5GB 未使用の cache" "$(
      cut -f4 "${tmp}/fzf.in" | sed 's/\x1b\[[0-9]*m//g' | tr -s ' '
    )"
}

test_nothing_picked() {
  reset_log
  check "何も選ばなければ何も消さず正常終了" "0:" "$(
    FZF_PICK='^$' clean >/dev/null
    echo "$?:$(docker_log)"
  )"
}

test_delete_safe() {
  reset_log
  FZF_PICK="$(pick safe image "sha256:${hex_a}")|$(pick safe volume "${hex_a}")" clean </dev/null >/dev/null
  check "🟢 は確認なしで消す" "rmi sha256:${hex_a}|volume rm ${hex_a}" "$(docker_log)"
}

test_delete_risky() {
  reset_log
  check "⚠️ は y 以外で消さず終了コード 1" "1:" "$(
    FZF_PICK="$(pick risky image myapp:old)" clean -a <<<n >/dev/null
    echo "$?:$(docker_log)"
  )"

  reset_log
  FZF_PICK="$(pick risky cache build-cache)|$(pick risky volume pgdata)|$(pick risky image myapp:old)|$(pick risky container c0ffee000002)|$(pick risky container c0ffee000003)" \
    clean -a <<<y >/dev/null
  check "⚠️ は y で消す。container・image・volume・cache の順" \
    "rm c0ffee000002 c0ffee000003|rmi myapp:old|volume rm pgdata|builder prune -f" "$(docker_log)"
}

test_apply() {
  reset_log
  check "--apply: 🟢 だけを消し、消すものを表示する" \
    "0:rmi sha256:${hex_a}|volume rm ${hex_a}:2" "$(
      local out status=0
      out=$("${bin}" --apply 2>/dev/null </dev/null) || status=$?
      echo "${status}:$(docker_log):$(grep -c '🟢' <<<"${out}")"
    )"
}

test_apply_nothing() {
  reset_log
  check "--apply: 🟢 が無ければ消さずに知らせて終了コード 0" "0:1:" "$(
    local out status=0
    out=$(FAKE_DF="${tmp}/df-risky.json" "${bin}" --apply 2>/dev/null </dev/null) || status=$?
    echo "${status}:$(grep -c '消してよいものは無い' <<<"${out}"):$(docker_log)"
  )"
}

test_fzf_exit() {
  reset_log
  check "fzf を Esc で抜けたら (130) 何も消さず正常終了" "0:" "$(
    FZF_EXIT=130 clean >/dev/null
    echo "$?:$(docker_log)"
  )"
  check "fzf のエラー (2) は何も消さず終了コード 2" "2:" "$(
    FZF_EXIT=2 clean >/dev/null || echo -n "$?"
    echo ":$(docker_log)"
  )"
}

test_unknown_option() {
  check "未知のオプションは終了コード 2" "2" "$(
    clean -x >/dev/null || echo "$?"
  )"
}

open_real_fzf() {
  tmux kill-session -t dc 2>/dev/null || true
  tmux -f /dev/null new-session -d -s dc -x 160 -y 40 \
    "env -u FZF_DEFAULT_OPTS -u FZF_DEFAULT_OPTS_FILE PATH='${real_path}' FAKE_DF='${FAKE_DF}' DOCKER_LOG='${DOCKER_LOG}' '${bin}'"
  wait_screen 'Enter: 消す'
}

keys() {
  tmux send-keys -t dc "$@"
}

screen() {
  tmux capture-pane -p -t dc 2>/dev/null
}

wait_until() {
  local _
  for _ in $(seq 50); do
    "$@" && return 0
    sleep 0.1
  done
  return 1
}

screen_has() {
  screen | grep -qF -- "$1"
}

screen_lacks() {
  ! screen_has "$1"
}

pane_closed() {
  ! tmux has-session -t dc 2>/dev/null
}

wait_screen() {
  wait_until screen_has "$1"
}

shown() {
  wait_screen "$1" && echo 1 || echo 0
}

gone() {
  wait_until screen_lacks "$1" && echo 1 || echo 0
}

closed() {
  wait_until pane_closed && echo 1 || echo 0
}

test_real_fzf_toggle() {
  reset_log
  open_real_fzf
  check "実 fzf: 既定は 🟢 だけで開く" "1:1" "$(shown '消してよいものだけを表示中'):$(gone pgdata)"
  check "実 fzf: preview に先頭の行の docker inspect が出る" "1" "$(shown "INSPECT sha256:${hex_a}")"
  keys a
  check "実 fzf: a で全件に切り替わり ⚠️ が出る" "1:1" "$(shown '全件を表示中'):$(shown pgdata)"
  keys a
  check "実 fzf: もう一度 a で 🟢 だけに戻る" "1:1" "$(shown '消してよいものだけを表示中'):$(gone pgdata)"
  keys Escape
  check "実 fzf: Esc で何も消さずに終わる" "1:" "$(closed):$(docker_log)"
}

test_real_fzf_filter() {
  reset_log
  open_real_fzf
  keys a
  wait_screen pgdata
  keys /
  keys -l pgdata
  check "実 fzf: / の後は a を打っても切り替わらず、絞り込みになる" \
    "1:1" "$(gone 'build cache'):$(shown pgdata)"
  keys Escape
  check "実 fzf: 絞り込み中の Esc は終了せず、絞り込む前の一覧に戻る" "1" "$(shown 'build cache')"
  keys Escape
  check "実 fzf: 絞り込みの外の Esc は終了する" "1:" "$(closed):$(docker_log)"
}

test_real_fzf_enter() {
  reset_log
  open_real_fzf
  keys Enter
  check "実 fzf: Enter でカーソル位置の 🟢 を確認なしで消す" "1:rmi sha256:${hex_a}" "$(closed):$(docker_log)"
}

test_real_fzf() {
  test_real_fzf_toggle
  test_real_fzf_filter
  test_real_fzf_enter
}

main() {
  set -euo pipefail
  local pass=0 fail=0 tmp bin bin_dir real_path
  local hex_a hex_b hex_c hex_d
  hex_a=$(printf 'a1%.0s' {1..32})
  hex_b=$(printf 'b2%.0s' {1..32})
  hex_c=$(printf 'c3%.0s' {1..32})
  hex_d=$(printf 'd4%.0s' {1..32})
  bin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if ! "${bin_dir}/tmux-sandbox" --inside; then
    exec "${bin_dir}/tmux-sandbox" "${BASH_SOURCE[0]}" "$@"
  fi
  bin="${bin_dir}/docker_clean"
  tmp=$(mktemp -d)
  # shellcheck disable=SC2064 # local 変数なので定義時に展開する
  trap "rm -rf '${tmp}'" EXIT
  write_fixture
  install_fake_docker
  install_fake_fzf
  # lint-ignore: uppercase 偽の docker が読む環境変数
  export FAKE_DF="${tmp}/df.json" DOCKER_LOG="${tmp}/docker.log"
  real_path="${tmp}/docker-bin:${PATH}"
  # lint-ignore: uppercase PATH は環境変数
  PATH="${tmp}/bin:${real_path}"
  test_safe_view
  test_all_view
  test_no_cache_row
  test_display
  test_nothing_picked
  test_delete_safe
  test_delete_risky
  test_apply
  test_apply_nothing
  test_fzf_exit
  test_unknown_option
  test_real_fzf
  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}
main "$@"
