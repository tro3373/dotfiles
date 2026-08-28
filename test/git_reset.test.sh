#!/usr/bin/env bash

# bin/git_reset のユニットテスト (実 git 使用・viewer 不要)。
# 隔離した実 git リポジトリと一時 XDG_CONFIG_HOME を用意し、git_reset を
# サブプロセス実行して HEAD と marker(stack) の状態を検証する。
#
# 検証対象 (grr の fzf 選択は非対話形 `git_reset -r <hash>` 経由でテストする。
# fzf UI 自体は TTY 必須のため単体テスト対象外):
#   * gre N (push)  : HEAD~N までの commit を stack へ積み HEAD~N へ reset。複数 push できる。
#   * gre (base 選択): 引数なしはベース候補 (各ブランチとの分岐点) を fzf で選び、そこへ
#                      reset する。候補の並び・集約・件数表示を偽 fzf 経由で検証する。
#   * grr (-r <hash>): 選んだ stack エントリへ reset し、そこまで pop。任意段へ一気に
#                      redo できる (多段)。N 回 push → 段階的/一気の redo で完全復元。
#   * divergence    : gre 後に新コミットを作った状態で grr すると、現 HEAD が選択先の
#                      祖先でない (merge-base) ため警告して中断 (HEAD/stack 不変)。-f で強制。
#
#   test/git_reset.test.sh   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
gr_bin=$(cd "${script_dir}/../bin" && pwd)/git_reset

# desc / expected / actual を比較し、main の pass・fail カウンタを更新する。
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

# 隔離 repo (commit A B C D) と一時 XDG_CONFIG_HOME を作る。グローバル repo/xdg を設定。
new_repo() {
  repo="${tmproot}/repo"
  xdg="${tmproot}/config"
  rm -rf "${repo}" "${xdg}"
  mkdir -p "${repo}" "${xdg}"
  git -C "${repo}" init -q
  git -C "${repo}" config user.email t@t
  git -C "${repo}" config user.name t
  local c
  for c in A B C D; do
    echo "${c}" >"${repo}/f"
    git -C "${repo}" add -A
    git -C "${repo}" commit -qm "commit ${c}"
  done
}

# ${repo} で git を実行する。commit 日時を $1 分目に固定し、rev-list の既定 (commit
# date 降順) が同一秒のタイブレークに落ちないようにする。同一秒だと側枝より本流が
# 先に出てしまい、--first-parent の有無で差が出ずテストが無力化する。
git_at() {
  local n="$1" ts
  shift
  ts=$(printf '2026-01-01T00:%02d:00' "${n}")
  GIT_AUTHOR_DATE="${ts}" GIT_COMMITTER_DATE="${ts}" git -C "${repo}" "$@"
}
# ${repo}/$3 へ件名 $2 を書き、$1 分目の日時で commit する。
commit_at() {
  echo "$2" >"${repo}/$3"
  git -C "${repo}" add -A
  git_at "$1" commit -qm "$2"
}

# merge 入りの隔離 repo: A - B - M(merge side) - C。side は A から分岐し S1 - S2。
# first-parent 上は C, M, B, A で、S1/S2 は載らない。side (3,4分) を本流の B (2分)
# より新しくして、commit date 順に並べると S2 が B を追い越すようにする。
new_repo_with_merge() {
  repo="${tmproot}/mergerepo"
  xdg="${tmproot}/mergeconfig"
  rm -rf "${repo}" "${xdg}"
  mkdir -p "${repo}" "${xdg}"
  git -C "${repo}" init -q
  git -C "${repo}" config user.email t@t
  git -C "${repo}" config user.name t
  commit_at 1 'commit A' f
  commit_at 2 'commit B' f
  git -C "${repo}" checkout -q -b side 'HEAD~1'
  commit_at 3 'side S1' g # 本流は f を触るので競合しない
  commit_at 4 'side S2' g
  git -C "${repo}" checkout -q -
  git_at 5 merge -q --no-ff side -m 'merge side'
  commit_at 6 'commit C' f
}

# ベース候補の検証用 repo: A - B - C - D (現ブランチ)。base1/base2 は B、far は A を
# 指す。base1/base2 は分岐点が同一なので 1 行へ集約される想定。
new_repo_with_bases() {
  new_repo
  git -C "${repo}" branch base1 'HEAD~2'
  git -C "${repo}" branch base2 'HEAD~2'
  git -C "${repo}" branch far 'HEAD~3'
}

# 偽 fzf を PATH 先頭に置く。stdin の行から env FAKE_FZF_PICK に一致する第1フィールド
# (lineno or 'HEAD') の行を 1 つ echo する。未設定/不一致なら中断扱い (exit 1)。
# --preview / --bind 等の引数は無視。実 fzf (TTY 必須) なしで対話パスを検証する。
setup_fake_fzf() {
  fakebin="${tmproot}/fakebin"
  mkdir -p "${fakebin}"
  cat >"${fakebin}/fzf" <<'FAKE'
#!/usr/bin/env bash
rows=$(cat)
[[ -n ${FAKE_FZF_ROWS:-} ]] && printf '%s\n' "$rows" >"$FAKE_FZF_ROWS"
pick=${FAKE_FZF_PICK:-}
[[ -z $pick ]] && exit 1
while IFS=$'\t' read -r f1 rest; do
  [[ $f1 == "$pick" ]] && { printf '%s\t%s\n' "$f1" "$rest"; exit 0; }
done <<<"$rows"
exit 1
FAKE
  chmod +x "${fakebin}/fzf"
  # 偽 trash: -c の掃除を検証するため、引数のファイルを FAKE_TRASH_DIR へ退避する
  # (実 trash 非依存)。
  cat >"${fakebin}/trash" <<'FAKETRASH'
#!/usr/bin/env bash
dest="${FAKE_TRASH_DIR:-/tmp/faketrash}"
mkdir -p "$dest"
for f in "$@"; do mv "$f" "$dest/" 2>/dev/null || true; done
FAKETRASH
  chmod +x "${fakebin}/trash"
}

# git_reset を repo 内・XDG 差し替え・偽 fzf を PATH 先頭にしてサブプロセス実行する。
gr() { (cd "${repo}" && PATH="${fakebin}:${PATH}" XDG_CONFIG_HOME="${xdg}" "${gr_bin}" "$@"); }
# gr のログを文字列で返す (どのエラー経路で落ちたかを assert する用)。ログは ink 経由で
# 出力先が変わるため stdout/stderr を両方拾う。非0終了でもテストを止めない。
gr_out() { gr "$@" 2>&1 || true; }

subj() { git -C "${repo}" log -1 --format=%s; } # HEAD のコミット件名
head_hash() { git -C "${repo}" rev-parse HEAD; }
rev() { git -C "${repo}" rev-parse "$1"; } # 任意 revision の hash
commit() { echo "$1" >"${repo}/f" && git -C "${repo}" add -A && git -C "${repo}" commit -qm "commit $1"; }

# stack は repo_dir/branch の nested-dir に置かれるので leaf file を find で拾う。
# 単一 branch のテストでは 1 ファイルなので先頭を返せば十分。
marker_file() {
  find "${xdg}/git_reset" -type f 2>/dev/null | head -n1
}
stack_size() {
  local m
  m=$(marker_file)
  [[ -n ${m} && -s ${m} ]] && grep -c '.' "${m}" || echo 0
}
# 指定 branch ($1, '/' 可) の stack 行数。ファイル無し/空なら 0。
stack_size_for() {
  local m
  m=$(find "${xdg}/git_reset" -type f -path "*/$1" 2>/dev/null | head -n1)
  [[ -n ${m} && -s ${m} ]] && grep -c '.' "${m}" || echo 0
}
stack_top() {
  local m
  m=$(marker_file)
  [[ -n ${m} && -s ${m} ]] && tail -n1 "${m}" || echo ""
}
# stack の各エントリを件名へ変換して file 行順で返す。repo を作り直すと hash が
# 変わる (committer date 依存) ため、repo 間の stack 比較は件名で行う。
stack_subjects() {
  local m h
  m=$(marker_file)
  [[ -n ${m} && -s ${m} ]] || return 0
  while IFS= read -r h; do
    [[ -z ${h} ]] && continue
    git -C "${repo}" log -1 --format=%s "${h}"
  done <"${m}"
}

# gre 1: HEAD が1つ前へ。元 HEAD が stack に1件積まれる。
test_gre_once_pushes_and_moves_back() {
  new_repo
  local before
  before=$(head_hash)
  gr 1 >/dev/null 2>&1
  check 'gre 1: HEAD が1つ前(C)へ' 'commit C' "$(subj)"
  check 'gre 1: stack 1件' '1' "$(stack_size)"
  check 'gre 1: stack top = 元HEAD(D)' "${before}" "$(stack_top)"
}

# gre 1 を複数回: stack が上書きされず積み上がる。
test_gre_multiple_stacks() {
  new_repo
  gr 1 >/dev/null 2>&1 # push D -> HEAD=C
  gr 1 >/dev/null 2>&1 # push C -> HEAD=B
  check 'gre 1 x2: HEAD=B' 'commit B' "$(subj)"
  check 'gre 1 x2: stack 2件 (上書きされない)' '2' "$(stack_size)"
}

# gre N: N 個分まとめて undo。HEAD が N 個前へ移り、stack も N 件積まれる。
test_gre_count_undoes_n() {
  new_repo
  gr 3 >/dev/null 2>&1
  check 'gre 3: HEAD が3つ前(A)へ' 'commit A' "$(subj)"
  check 'gre 3: stack 3件' '3' "$(stack_size)"
}

# gre N は gre 1 を N 回打つのと等価。stack の中身・順序まで一致させる
# (1件ずつ積む設計の担保。まとめて1件積む実装になったらここが落ちる)。
test_gre_count_equals_repeated_gre() {
  new_repo
  gr 1 >/dev/null 2>&1
  gr 1 >/dev/null 2>&1
  gr 1 >/dev/null 2>&1
  local repeated_head repeated_stack
  repeated_head=$(subj)
  repeated_stack=$(stack_subjects)
  new_repo
  gr 3 >/dev/null 2>&1
  check 'gre 3: HEAD が gre 1 x3 と同じ' "${repeated_head}" "$(subj)"
  check 'gre 3: stack の中身/順序が gre 1 x3 と同じ' "${repeated_stack}" "$(stack_subjects)"
}

# gre N 後も段階 redo が効く (1件ずつ積むので任意の1段を選んで戻せる)。
test_gre_count_allows_stepwise_redo() {
  new_repo
  local hc
  hc=$(rev 'HEAD~1')   # C
  gr 3 >/dev/null 2>&1 # stack=[D,C,B], HEAD=A
  gr -r "${hc}" >/dev/null 2>&1
  check 'gre 3 後の段階 redo: HEAD=C' 'commit C' "$(subj)"
  check 'gre 3 後の段階 redo: stack 1件 (=[D])' '1' "$(stack_size)"
}

# 履歴より深い N は 1 件も reset せず非0終了 (部分適用を作らない)。
test_gre_count_exceeding_history_aborts() {
  new_repo
  local before rc
  before=$(head_hash)
  gr 5 >/dev/null 2>&1 # 履歴は A..D の 4件しかない
  rc=$?
  check 'gre 5(履歴4): 非0終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check 'gre 5(履歴4): HEAD 不変' "${before}" "$(head_hash)"
  check 'gre 5(履歴4): stack 作られない(0件)' '0' "$(stack_size)"
}

# merge 入り履歴でも first-parent 上の commit だけを積む。side branch の commit が
# 混ざると、grr で選んだとき divergence guard (祖先判定) を素通りして本流の commit が
# 無警告で消えるため、順序込みで固定する。
test_gre_count_follows_first_parent() {
  new_repo_with_merge
  gr 3 >/dev/null 2>&1
  check 'gre 3(merge有): HEAD=A' 'commit A' "$(subj)"
  check 'gre 3(merge有): stack は first-parent のみ' \
    "$(printf 'commit C\nmerge side\ncommit B')" "$(stack_subjects)"
}

# 0・非数値は count の検証で弾く。終了コードだけだと後続処理の巻き添え死でも green に
# なるため、validation のメッセージと「reset していないこと」を assert する。
test_gre_invalid_count_rejected() {
  new_repo
  local before arg out
  before=$(head_hash)
  for arg in 0 abc 1.5; do
    out=$(gr_out "${arg}")
    check "invalid count '${arg}': validation で弾く" '1' \
      "$([[ ${out} == *"Invalid count: ${arg}"* ]] && echo 1 || echo 0)"
    check "invalid count '${arg}': reset を実行しない" '0' \
      "$([[ ${out} == *'Executed:'* ]] && echo 1 || echo 0)"
  done
  check 'invalid count: HEAD 不変' "${before}" "$(head_hash)"
  check 'invalid count: stack 作られない(0件)' '0' "$(stack_size)"
}

# 負数は count の regex ではなく option 判定 (-*) で弾かれる。経路が違うので分離する。
test_gre_negative_count_is_unknown_option() {
  new_repo
  local out
  out=$(gr_out -1)
  check 'gre -1: Unknown option で弾く' '1' \
    "$([[ ${out} == *'Unknown option: -1'* ]] && echo 1 || echo 0)"
  check 'gre -1: stack 作られない(0件)' '0' "$(stack_size)"
}

# 非フラグ引数が 2 個以上なら何もせず非0終了。後勝ち上書きだと `gre abc 3` の typo が
# 黙って 3 commit の undo になり、入力と挙動が無言で乖離するため。
test_extra_argument_rejected() {
  new_repo
  local before rc
  before=$(head_hash)
  gr abc 3 >/dev/null 2>&1
  rc=$?
  check 'extra arg: gre abc 3 は非0終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  gr 2 3 >/dev/null 2>&1
  rc=$?
  check 'extra arg: gre 2 3 は非0終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  gr -r "${before}" extra >/dev/null 2>&1
  rc=$?
  check 'extra arg: grr <hash> extra も非0終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check 'extra arg: HEAD 不変' "${before}" "$(head_hash)"
  check 'extra arg: stack 作られない(0件)' '0' "$(stack_size)"
}

# grr 1回 (top を選択): その stack エントリへ reset し pop。
test_grr_pops_and_restores() {
  new_repo
  local hd
  hd=$(head_hash)      # D
  gr 1 >/dev/null 2>&1 # HEAD=C, stack=[D]
  gr -r "${hd}" >/dev/null 2>&1
  check 'grr once: HEAD=D へ復元' 'commit D' "$(subj)"
  check 'grr once: stack 空' '0' "$(stack_size)"
}

# 多段 redo: gre x3 で深く undo した状態から、任意段 (最古) を選んで一気に redo。
test_multilevel_redo() {
  new_repo
  local hd
  hd=$(head_hash) # D
  gr 1 >/dev/null 2>&1
  gr 1 >/dev/null 2>&1
  gr 1 >/dev/null 2>&1 # push D,C,B -> HEAD=A, stack=[D,C,B]
  check 'multilevel: gre x3 で HEAD=A' 'commit A' "$(subj)"
  gr -r "${hd}" >/dev/null 2>&1 # 一気に D まで redo
  check 'multilevel: 任意段選択で HEAD=D' 'commit D' "$(subj)"
  check 'multilevel: stack 全 pop (空)' '0' "$(stack_size)"
}

# 段階 redo: B -> C -> D と1段ずつ選んで戻すと stack も1段ずつ減る。
test_stepwise_redo() {
  new_repo
  local hb hc hd
  hd=$(rev HEAD)
  hc=$(rev 'HEAD~1')
  hb=$(rev 'HEAD~2')
  gr 1 >/dev/null 2>&1
  gr 1 >/dev/null 2>&1
  gr 1 >/dev/null 2>&1 # stack=[D,C,B], HEAD=A
  gr -r "${hb}" >/dev/null 2>&1
  check 'stepwise: B へ' 'commit B' "$(subj)"
  check 'stepwise: stack 2 (=[D,C])' '2' "$(stack_size)"
  gr -r "${hc}" >/dev/null 2>&1
  check 'stepwise: C へ' 'commit C' "$(subj)"
  check 'stepwise: stack 1 (=[D])' '1' "$(stack_size)"
  gr -r "${hd}" >/dev/null 2>&1
  check 'stepwise: D へ' 'commit D' "$(subj)"
  check 'stepwise: stack 0' '0' "$(stack_size)"
}

# grr で stack 空ならエラー終了 (空チェックが先に走る)。
test_grr_empty_errors() {
  new_repo
  local rc
  gr -r "$(head_hash)" >/dev/null 2>&1
  rc=$?
  check 'grr empty: 非0終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
}

# divergence: gre 後に新コミットを作って grr -> 警告して中断、HEAD/stack 不変。
test_divergence_warns_and_aborts() {
  new_repo
  local hd
  hd=$(head_hash)      # D
  gr 1 >/dev/null 2>&1 # push D -> HEAD=C
  commit E             # HEAD=E; E は D の祖先でない => divergence
  local head_before rc
  head_before=$(head_hash)
  gr -r "${hd}" >/dev/null 2>&1
  rc=$?
  check 'divergence: 非0終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check 'divergence: HEAD 不変' "${head_before}" "$(head_hash)"
  check 'divergence: stack 不変(1件)' '1' "$(stack_size)"
}

# grr -f: divergence でも強制 reset して pop。
test_grr_force_overrides_divergence() {
  new_repo
  local hd
  hd=$(head_hash)
  gr 1 >/dev/null 2>&1 # push D -> HEAD=C
  commit E             # HEAD=E
  gr -r -f "${hd}" >/dev/null 2>&1
  check 'grr -f: HEAD=D へ強制復元' 'commit D' "$(subj)"
  check 'grr -f: stack 空' '0' "$(stack_size)"
}

# フラグ位置非依存: -f -r <hash> の順 (force が先) でも強制 restore できる。
test_flag_order_independent() {
  new_repo
  local hd
  hd=$(head_hash)
  gr 1 >/dev/null 2>&1 # push D -> HEAD=C
  commit E             # HEAD=E (divergence)
  gr -f -r "${hd}" >/dev/null 2>&1
  check 'flag order: -f -r <hash> でも強制復元 (HEAD=D)' 'commit D' "$(subj)"
  check 'flag order: stack 空' '0' "$(stack_size)"
}

# root commit (親なし) で gre 1 すると phantom stack を作らず非0終了。
test_root_commit_push_guarded() {
  repo="${tmproot}/rootrepo"
  xdg="${tmproot}/rootcfg"
  rm -rf "${repo}" "${xdg}"
  mkdir -p "${repo}" "${xdg}"
  git -C "${repo}" init -q
  git -C "${repo}" config user.email t@t
  git -C "${repo}" config user.name t
  commit A # 単一コミット (root)
  local rc
  gr 1 >/dev/null 2>&1
  rc=$?
  check 'root commit: gre 1 非0終了' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check 'root commit: phantom stack なし(0件)' '0' "$(stack_size)"
}

# 無効/壊れた stack エントリ (旧形式 marker の残骸など) を選んでも fail-safe:
# 実在しないコミットは reset せず非0終了し、stack も壊さない。
test_invalid_entry_fails_safe() {
  new_repo
  gr 1 >/dev/null 2>&1 # marker 作成 (stack=[D]), HEAD=C
  local mfile before rc
  mfile=$(marker_file)
  printf '%s\n' 'not-a-commit' >>"${mfile}" # stack=[D, not-a-commit]
  before=$(stack_size)
  gr -r 'not-a-commit' >/dev/null 2>&1
  rc=$?
  check 'invalid entry: grr 非0終了 (fail-safe)' '1' "$([[ ${rc} -ne 0 ]] && echo 1 || echo 0)"
  check 'invalid entry: stack 破壊されない' "${before}" "$(stack_size)"
}

# fzf 経由 (偽 fzf で top=lineno1 を選択): build_rows + 選択パース + restore を通す。
test_fzf_select_restores() {
  new_repo
  gr 1 >/dev/null 2>&1 # stack=[D], HEAD=C; top の lineno=1
  FAKE_FZF_PICK=1 gr -r >/dev/null 2>&1
  check 'fzf select: HEAD=D へ復元' 'commit D' "$(subj)"
  check 'fzf select: stack 空' '0' "$(stack_size)"
}

# fzf 一覧の並び順: 最新コミットが最上行、現在 HEAD が最下行 (git log 風)。
test_fzf_order_newest_on_top() {
  new_repo
  local hd rowsfile
  hd=$(head_hash) # D = 最新コミット (最初に undo される = stack line1)
  gr 1 >/dev/null 2>&1
  gr 1 >/dev/null 2>&1 # stack=[D,C], HEAD=B
  rowsfile="${tmproot}/rows.txt"
  FAKE_FZF_PICK=HEAD FAKE_FZF_ROWS="${rowsfile}" gr -r >/dev/null 2>&1
  check 'order: 1行目 = 最新コミット D が上' "${hd}" "$(sed -n '1p' "${rowsfile}" | cut -f2)"
  check 'order: 最終行 = 現在 HEAD' 'HEAD' "$(tail -n1 "${rowsfile}" | cut -f1)"
}

# fzf で HEAD 行を選ぶと no-op (終了0・HEAD/stack 不変)。
test_fzf_select_head_is_noop() {
  new_repo
  gr 1 >/dev/null 2>&1 # stack=[D], HEAD=C
  local hc rc
  hc=$(head_hash)
  FAKE_FZF_PICK=HEAD gr -r >/dev/null 2>&1
  rc=$?
  check 'fzf HEAD 選択: 終了0 (no-op)' '0' "$([[ ${rc} -eq 0 ]] && echo 0 || echo 1)"
  check 'fzf HEAD 選択: HEAD 不変' "${hc}" "$(head_hash)"
  check 'fzf HEAD 選択: stack 不変(1件)' '1' "$(stack_size)"
}

# prune-on-gre: gre 後に分岐コミットを作り再度 gre すると、死んだ redo (旧 top) は
# 破棄され、stack は積み上がらず分岐後 HEAD のみになる (肥大化防止)。
test_prune_on_divergent_gre() {
  new_repo
  gr 1 >/dev/null 2>&1 # push D -> HEAD=C, stack=[D]
  commit E             # HEAD=E (D の兄弟=分岐), stack 上の D は dead
  local he
  he=$(head_hash)      # E
  gr 1 >/dev/null 2>&1 # prune で D 破棄 -> push E -> HEAD=C, stack=[E]
  check 'prune: 分岐後 gre で stack 積み上がらず1件' '1' "$(stack_size)"
  check 'prune: top = 分岐後HEAD(E) のみ' "${he}" "$(stack_top)"
}

# branch-keyed: branch ごとに stack ファイルが分かれ、switch しても混ざらない。
# feature/x で '/' 入り branch 名が nested-dir になることも確認する。
test_branch_keyed_separate_stacks() {
  new_repo
  local defbr
  defbr=$(git -C "${repo}" symbolic-ref --short HEAD)
  gr 1 >/dev/null 2>&1 # push on defbr; stack(defbr)=1, HEAD=C
  check 'branch-key: defbr stack 1件' '1' "$(stack_size_for "${defbr}")"
  git -C "${repo}" checkout -q -b feature/x # at C
  check 'branch-key: 新branchは空stack' '0' "$(stack_size_for feature/x)"
  gr 1 >/dev/null 2>&1 # push on feature/x
  check 'branch-key: feature/x stack 1件' '1' "$(stack_size_for feature/x)"
  check 'branch-key: defbr stack 保持1件 (混ざらない)' '1' "$(stack_size_for "${defbr}")"
}

# -c: 死んだ branch の stack を fzf --multi で選んで trash。現存 branch は候補外。
test_clean_removes_dead_branch_stack() {
  new_repo
  local defbr
  defbr=$(git -C "${repo}" symbolic-ref --short HEAD)
  git -C "${repo}" checkout -q -b feature/x
  gr 1 >/dev/null 2>&1                     # feature/x に stack 作成 (gre の mixed reset で working tree が dirty)
  git -C "${repo}" checkout -qf "${defbr}" # -f: dirty tree を捨てて defbr へ戻る
  git -C "${repo}" branch -qD feature/x    # feature/x を消す -> stack 孤児化
  check 'clean: 掃除前 feature/x stack 1件' '1' "$(stack_size_for feature/x)"
  FAKE_TRASH_DIR="${tmproot}/trashed" FAKE_FZF_PICK='feature/x' gr -c >/dev/null 2>&1
  check 'clean: feature/x stack 掃除された(0件)' '0' "$(stack_size_for feature/x)"
}

# 引数なし gre: ベース候補を fzf で選び、その分岐点まで一気に reset する。
test_gre_picks_base() {
  new_repo_with_bases
  local hb
  hb=$(rev 'HEAD~2') # B = base1/base2 の分岐点
  FAKE_FZF_PICK="${hb}" gr >/dev/null 2>&1
  check 'base pick: HEAD=B へ' 'commit B' "$(subj)"
  check 'base pick: stack 2件 (D,C)' '2' "$(stack_size)"
  check 'base pick: stack top = 元HEAD(D)' "$(printf 'commit D\ncommit C')" "$(stack_subjects)"
}

# 候補行は近い (件数が少ない) 順。fzf の既定 layout は画面下から描くので 1 行目が
# プロンプト直上 = カーソル初期位置になり、一番近い分岐点が無操作で選べる。
test_base_rows_nearest_first() {
  new_repo_with_bases
  local rowsfile
  rowsfile="${tmproot}/baserows.txt"
  FAKE_FZF_PICK=none FAKE_FZF_ROWS="${rowsfile}" gr >/dev/null 2>&1
  check 'base rows: 1行目 = 一番近い分岐点(B)' "$(rev 'HEAD~2')" "$(sed -n '1p' "${rowsfile}" | cut -f1)"
  check 'base rows: 2行目 = より遠い分岐点(A)' "$(rev 'HEAD~3')" "$(sed -n '2p' "${rowsfile}" | cut -f1)"
}

# 分岐点が同じブランチは 1 行へ集約し、名前は全部並べる。別行にしても reset 先も件数も
# 同じ行が並ぶだけで、選ぶ手掛かりにならないため。
test_base_rows_group_same_base() {
  new_repo_with_bases
  local rowsfile line
  rowsfile="${tmproot}/baserows2.txt"
  FAKE_FZF_PICK=none FAKE_FZF_ROWS="${rowsfile}" gr >/dev/null 2>&1
  line=$(sed -n '1p' "${rowsfile}")
  check 'base rows: 同一分岐点は1行' '1' "$(grep -c "$(rev 'HEAD~2')" "${rowsfile}")"
  check 'base rows: 集約行に branch 名を全部出す' '1' \
    "$([[ ${line} == *'base1, base2'* ]] && echo 1 || echo 0)"
}

# merge を含むと first-parent 件数 (= stack の段数) と総コミット数がずれる。両方出さないと
# 「N 件戻る」と読んだ数だけ grr できず食い違う。
test_base_rows_show_merge_total() {
  new_repo_with_merge
  git -C "${repo}" branch base_a 'HEAD~3' # A。A..C は first-parent 3件 / 総数 5件 (S1,S2 込み)
  local rowsfile
  rowsfile="${tmproot}/mergerows.txt"
  FAKE_FZF_PICK=none FAKE_FZF_ROWS="${rowsfile}" gr >/dev/null 2>&1
  check 'base rows: merge 込み総数を併記' '1' \
    "$(grep -c '3 commit(s) (5 w/ merges).*base_a' "${rowsfile}")"
}

# 現ブランチしか無い repo では候補が 0 件。fzf を開かず、件数指定を案内して終了する。
test_base_no_candidates_errors() {
  new_repo
  local before out
  before=$(head_hash)
  out=$(gr_out)
  check 'no candidates: 案内して非0終了' '1' \
    "$([[ ${out} == *'No base branch candidates'* ]] && echo 1 || echo 0)"
  check 'no candidates: HEAD 不変' "${before}" "$(head_hash)"
  check 'no candidates: stack 作られない(0件)' '0' "$(stack_size)"
}

# fzf を中断 (選択なし) したら何もしない。終了0で HEAD/stack 不変。
test_base_pick_abort_is_noop() {
  new_repo_with_bases
  local before rc
  before=$(head_hash)
  gr >/dev/null 2>&1 # FAKE_FZF_PICK 未設定 = 偽 fzf が中断扱いで exit 1
  rc=$?
  check 'base pick abort: 終了0 (no-op)' '0' "$([[ ${rc} -eq 0 ]] && echo 0 || echo 1)"
  check 'base pick abort: HEAD 不変' "${before}" "$(head_hash)"
  check 'base pick abort: stack 作られない(0件)' '0' "$(stack_size)"
}

main() {
  set -uo pipefail
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  setup_fake_fzf
  local pass=0 fail=0

  test_gre_once_pushes_and_moves_back
  test_gre_picks_base
  test_base_rows_nearest_first
  test_base_rows_group_same_base
  test_base_rows_show_merge_total
  test_base_no_candidates_errors
  test_base_pick_abort_is_noop
  test_gre_multiple_stacks
  test_gre_count_undoes_n
  test_gre_count_equals_repeated_gre
  test_gre_count_allows_stepwise_redo
  test_gre_count_exceeding_history_aborts
  test_gre_count_follows_first_parent
  test_gre_invalid_count_rejected
  test_gre_negative_count_is_unknown_option
  test_extra_argument_rejected
  test_grr_pops_and_restores
  test_multilevel_redo
  test_stepwise_redo
  test_fzf_select_restores
  test_fzf_order_newest_on_top
  test_fzf_select_head_is_noop
  test_grr_empty_errors
  test_divergence_warns_and_aborts
  test_grr_force_overrides_divergence
  test_flag_order_independent
  test_root_commit_push_guarded
  test_invalid_entry_fails_safe
  test_prune_on_divergent_gre
  test_branch_keyed_separate_stacks
  test_clean_removes_dead_branch_stack

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
