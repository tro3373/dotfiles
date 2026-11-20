#!/usr/bin/env bash

# git_worktree のユニットテスト (実 git 使用・NW/fzf 不要)。
# 末尾の `main "$@"` を除いて source し、関数を直接呼ぶ。
#
# 検証対象:
#   * _do_remove_worktree: 現在地(initial_toplevel)の worktree を削除したときだけ
#       org root を stdout に出す (zsh wrapper gt が cd し直すための救済)。
#       現在地でない worktree 削除時・org root から削除時は stdout 空。
#
#   * get_org_git_root: git 管理外では cwd を repo root と誤認せず失敗する
#       (誤認すると main が <cwd>-worktree の空 dir を掘る)。worktree の
#       サブディレクトリからでも親リポの root を返す。
#
#   * _force_remove_leftover: worktree の置き場所の直下でなければ sudo を呼ばずに中止する。
#       sudo は chown だけを行い、削除は trash に渡す。
#
#   * create_default_ln_config: ignored ファイルが 1 件も無いリポでも
#       grep の非ゼロ終了で落ちず、空 config を書く。
#
#   * _merged_label: 親リポジトリの HEAD への取り込み状況を 印 / +N / 空欄 で返す。
#       作ってからコミットの無いブランチは取り込み済みに見せない。
#
#   * -a: <org>-worktree/<branch の / を - にした名前> に作り、そのパスだけを stdout に出す。
#
#   test/git_worktree   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)
gwt_bin=$(cd "${script_dir}/../bin" && pwd)/git_worktree
sandbox_bin=$(cd "${script_dir}/../bin" && pwd)/tmux-sandbox

# shellcheck disable=SC1090
source "$gwt_bin"

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

# 隔離 org repo と org-worktree/ を作る。グローバル org/org_wt/git_org_root_dir を設定。
new_repo() {
  local sub="$1"
  org="${tmproot}/${sub}/org"
  org_wt="${tmproot}/${sub}/org-worktree"
  mkdir -p "${org}"
  git -C "${org}" init -q
  git -C "${org}" config user.email t@t
  git -C "${org}" config user.name t
  echo init >"${org}/f"
  git -C "${org}" add -A
  git -C "${org}" commit -qm init
  git_org_root_dir=$(realpath "${org}")
}

# org-worktree/<name> に新規ブランチの worktree を追加し、その realpath を返す。
add_wt() {
  local name="$1"
  git -C "${org}" worktree add -q -b "${name}" "${org_wt}/${name}" >/dev/null 2>&1
  realpath "${org_wt}/${name}"
}

# 現在地 worktree を削除 => org root を stdout に出す (gt の cd 救済用)
test_remove_current_emits_org_root() {
  new_repo current
  local wt
  wt=$(add_wt feat-A)
  initial_toplevel="${wt}"
  local out
  out=$(cd "${org}" && _do_remove_worktree "${wt}" 2>/dev/null)
  check 'remove-current: org root を stdout 出力' "${git_org_root_dir}" "${out}"
  check 'remove-current: worktree dir 削除' '0' "$([[ -e ${wt} ]] && echo 1 || echo 0)"
}

# org root から削除 (= not worktree) => stdout 空
test_remove_from_root_emits_nothing() {
  new_repo fromroot
  local wt
  wt=$(add_wt feat-B)
  initial_toplevel="${git_org_root_dir}"
  local out
  out=$(cd "${org}" && _do_remove_worktree "${wt}" 2>/dev/null)
  check 'remove-from-root: stdout 空' '' "${out}"
  check 'remove-from-root: worktree dir 削除' '0' "$([[ -e ${wt} ]] && echo 1 || echo 0)"
}

# 現在地でない別 worktree を削除 => stdout 空・現在地は残存
test_remove_other_worktree_emits_nothing() {
  new_repo other
  local wt_c wt_d
  wt_c=$(add_wt feat-C)
  wt_d=$(add_wt feat-D)
  # shellcheck disable=SC2034  # source した _do_remove_worktree が参照する
  initial_toplevel="${wt_c}"
  local out
  out=$(cd "${org}" && _do_remove_worktree "${wt_d}" 2>/dev/null)
  check 'remove-other: stdout 空 (現在地でない)' '' "${out}"
  check 'remove-other: 対象 worktree 削除' '0' "$([[ -e ${wt_d} ]] && echo 1 || echo 0)"
  check 'remove-other: 現在地 worktree 残存' '1' "$([[ -e ${wt_c} ]] && echo 1 || echo 0)"
}

# untracked ファイルが残っていても --force で消し切り、sudo へ落ちない。
# (force 無しの git worktree remove は untracked 1 件で必ず fatal になる)
test_remove_untracked_does_not_need_sudo() {
  new_repo untracked
  local wt
  wt=$(add_wt feat-F)
  mkdir -p "${wt}/build"
  echo garbage >"${wt}/build/out.o"
  # shellcheck disable=SC2034  # source した _do_remove_worktree が参照する
  initial_toplevel="${git_org_root_dir}"
  local sudo_called=0
  (
    # shellcheck disable=SC2329  # source した _do_remove_worktree が呼ぶ
    _force_remove_leftover() { echo CALLED >"${tmproot}/untracked.called"; }
    cd "${org}" && _do_remove_worktree "${wt}"
  ) >/dev/null 2>&1
  [[ -e "${tmproot}/untracked.called" ]] && sudo_called=1
  check 'untracked: sudo フォールバックへ落ちない' '0' "${sudo_called}"
  check 'untracked: worktree dir 削除' '0' "$([[ -e ${wt} ]] && echo 1 || echo 0)"
}

# git が実体を消せず外から片付けたケースでも、admin metadata を残さない。
# 残すと removed/<branch> が "used by worktree" で git branch -d できなくなる。
test_remove_leftover_leaves_no_stale_entry() {
  new_repo leftover
  local wt
  wt=$(add_wt feat-G)
  # root 所有ディレクトリの代わりに「消せないディレクトリ」を作る
  # (親ディレクトリの w を落とすと配下の entry を削除できない = git の削除が失敗する)
  mkdir -p "${wt}/data/sub"
  echo x >"${wt}/data/sub/f"
  chmod 500 "${wt}/data"
  # shellcheck disable=SC2034  # source した _do_remove_worktree が参照する
  initial_toplevel="${git_org_root_dir}"
  (
    # sudo rm 相当。確認プロンプトを挟まず権限を戻して消す
    # shellcheck disable=SC2329  # source した _do_remove_worktree が呼ぶ
    _force_remove_leftover() { chmod -R u+w "$1" && rm -rf "$1"; }
    cd "${org}" && _do_remove_worktree "${wt}"
  ) >/dev/null 2>&1
  check 'leftover: worktree dir 削除' '0' "$([[ -e ${wt} ]] && echo 1 || echo 0)"
  check 'leftover: prunable entry が残らない' '0' \
    "$(git -C "${org}" worktree list | grep -c prunable || true)"
  check 'leftover: removed/<branch> を削除できる' '0' \
    "$(git -C "${org}" branch -d removed/feat-G >/dev/null 2>&1 && echo 0 || echo 1)"
}

# 置き場所の外のパスには sudo を一切呼ばずに中止する。
test_force_remove_refuses_outside_worktree_root() {
  new_repo outside
  local outside="${tmproot}/outside/victim"
  mkdir -p "${outside}" "${org_wt}"
  # shellcheck disable=SC2034  # source した _is_under_worktree_root が参照する
  git_worktree_dir="${org_wt}"
  (
    # shellcheck disable=SC2329  # source した _force_remove_leftover が呼ぶ
    sudo() { echo CALLED >"${tmproot}/outside.sudo"; }
    # shellcheck disable=SC2329
    trash() { echo CALLED >"${tmproot}/outside.trash"; }
    echo | _force_remove_leftover "${outside}"
  ) >/dev/null 2>&1
  check 'outside: sudo を呼ばない' '0' "$([[ -e ${tmproot}/outside.sudo ]] && echo 1 || echo 0)"
  check 'outside: trash を呼ばない' '0' "$([[ -e ${tmproot}/outside.trash ]] && echo 1 || echo 0)"
  check 'outside: 対象が残る' '1' "$([[ -e ${outside} ]] && echo 1 || echo 0)"

  # 置き場所の中を指す symlink でも、解決先が外なら通さない
  ln -s "${outside}" "${org_wt}/link"
  check 'outside: 外を指す symlink は置き場所の直下と見なさない' '1' \
    "$(_is_under_worktree_root "${org_wt}/link" && echo 0 || echo 1)"
}

# 置き場所の直下なら、sudo は chown だけを行い、削除は trash に渡す。
test_force_remove_chowns_then_trashes() {
  new_repo inside
  local target="${org_wt}/feat-H"
  mkdir -p "${target}"
  # shellcheck disable=SC2034  # source した _is_under_worktree_root が参照する
  git_worktree_dir="${org_wt}"
  (
    # shellcheck disable=SC2329  # source した _force_remove_leftover が呼ぶ
    sudo() { echo "$1" >>"${tmproot}/inside.sudo"; }
    # shellcheck disable=SC2329
    trash() { echo "$1" >"${tmproot}/inside.trash"; }
    echo | _force_remove_leftover "${target}"
  ) >/dev/null 2>&1
  check 'inside: sudo は chown だけ' 'chown' "$(cat "${tmproot}/inside.sudo" 2>/dev/null)"
  check 'inside: trash に対象を渡す' "${target}" "$(cat "${tmproot}/inside.trash" 2>/dev/null)"
}

# branch を設定して _fzf_worktrees を呼び、fzf へ渡った引数列を返す。
# fzf は引数記録スタブに差し替える (stdin の一覧は捨て、受け取った引数を 1 行 1 個で
# 返す)。スタブも branch 代入もサブシェル body に閉じるので他テストへ漏れない。
capture_fzf_args() (
  # shellcheck disable=SC2329  # source した _fzf_worktrees が呼ぶ
  fzf() {
    cat >/dev/null
    printf '%s\n' "$@"
  }
  # shellcheck disable=SC2034  # source した _fzf_worktrees が参照する
  branch="$1"
  shift
  echo dummy | _fzf_worktrees "$@"
)

# 引数列に flag が含まれるか (1/0)
has_arg() { grep -qFx -- "$2" <<<"$1" && echo 1 || echo 0; }

# 引数列から flag の次の行 (= その値) を取り出す。未指定なら空。
arg_value() { grep -A1 -Fx -- "$2" <<<"$1" | tail -n1; }

# ブランチ名を渡す => 絞り込みクエリと 1 件自動確定が付く。
# クエリは worktree ディレクトリ名に合わせスラッシュをハイフンへ変換する。
test_fzf_args_with_branch() {
  local args
  args=$(capture_fzf_args 'feature/foo' --no-multi '--prompt=test: ')
  check 'with-branch: --query はハイフン化した名前' 'feature-foo' "$(arg_value "${args}" --query)"
  check 'with-branch: --select-1 を渡す' '1' "$(has_arg "${args}" --select-1)"
  check 'with-branch: --exact を渡す (曖昧一致で誤確定させない)' '1' "$(has_arg "${args}" --exact)"
  check 'with-branch: --no-extended を渡す (! ^ $ を演算子にしない)' '1' "$(has_arg "${args}" --no-extended)"
  check 'with-branch: --nth=-1 を渡す (パス列だけを照合)' '1' "$(has_arg "${args}" --nth=-1)"
  check 'with-branch: --exit-0 は渡さない' '0' "$(has_arg "${args}" --exit-0)"
  check 'with-branch: 呼び出し側の --no-multi が届く' '1' "$(has_arg "${args}" --no-multi)"
  check 'with-branch: 呼び出し側の --prompt が届く' '1' "$(has_arg "${args}" '--prompt=test: ')"
}

# ブランチ名なし => 従来どおり必ず一覧を出す (自動確定させない)。
test_fzf_args_without_branch() {
  local args
  args=$(capture_fzf_args '' --multi)
  check 'no-branch: --query は渡さない' '0' "$(has_arg "${args}" --query)"
  check 'no-branch: --select-1 は渡さない' '0' "$(has_arg "${args}" --select-1)"
  check 'no-branch: --exit-0 は渡さない' '0' "$(has_arg "${args}" --exit-0)"
  check 'no-branch: --exact は渡さない (対話時は fuzzy のまま)' '0' "$(has_arg "${args}" --exact)"
  check 'no-branch: --nth=-1 は渡さない' '0' "$(has_arg "${args}" --nth=-1)"
  check 'no-branch: 呼び出し側の --multi が届く' '1' "$(has_arg "${args}" --multi)"
}

# git 管理外で get_org_git_root => 失敗し、cwd を repo root として返さない。
# elog スタブは return だけ (exit しない)。本体が自前で exit することを検証する。
test_org_root_outside_repo_fails() {
  local outside="${tmproot}/outside/dir"
  mkdir -p "${outside}"
  local out status=0
  out=$(
    # shellcheck disable=SC2329  # source した get_org_git_root が呼ぶ
    elog() { return 1; }
    cd "${outside}" && get_org_git_root
  ) || status=1
  check 'outside-repo: get_org_git_root が失敗する' '1' "${status}"
  check 'outside-repo: cwd を repo root として返さない' '' "${out}"
}

# worktree のサブディレクトリからでも親リポの root を返す (掘り下げ回帰)
test_org_root_from_worktree_subdir() {
  new_repo orgroot
  local wt
  wt=$(add_wt feat-E)
  mkdir -p "${wt}/deep/sub"
  local out
  out=$(cd "${wt}/deep/sub" && get_org_git_root)
  check 'worktree-subdir: 親リポの root を返す' "${git_org_root_dir}" "${out}"
}

# ignored ファイルが 1 件も無いリポでも create_default_ln_config が落ちない。
# 本番と同じ set -eo pipefail 下で呼ぶ (grep の非ゼロ終了が致命になる条件)。
test_default_ln_config_without_ignored() {
  new_repo noignored
  local config="${tmproot}/noignored/config" status=0
  (
    set -eo pipefail
    cd "${org}" || exit 1
    # shellcheck disable=SC2034  # source した create_default_ln_config が参照する
    ln_config="${config}"
    create_default_ln_config
  ) || status=1
  check 'no-ignored: create_default_ln_config が成功する' '0' "${status}"
  check 'no-ignored: 空の config を書く' '0' "$(wc -l <"${config}" | tr -d ' ')"
}

# 取り込み済み => 印 / 未取り込み => +N / 親リポ自身・コミット無し・detached => 空欄 (NBSP)
test_merged_label() {
  new_repo merged
  local fin open fresh det
  fin=$(add_wt feat-done)
  open=$(add_wt feat-open)
  fresh=$(add_wt feat-fresh)
  git -C "${fin}" commit -q --allow-empty -m d1
  git -C "${open}" commit -q --allow-empty -m o1
  git -C "${open}" commit -q --allow-empty -m o2
  git -C "${org}" merge -q feat-done
  git -C "${org}" commit -q --allow-empty -m after
  git -C "${org}" worktree add -q --detach "${org_wt}/det" >/dev/null 2>&1
  det=$(realpath "${org_wt}/det")
  check 'merged-label: 取り込み済みは印' $'\uf419' "$(_merged_label "${fin}")"
  check 'merged-label: 未取り込みはコミット数' '+2' "$(_merged_label "${open}")"
  check 'merged-label: コミット無しは取り込み済みに見せない' $'\u00a0' "$(_merged_label "${fresh}")"
  check 'merged-label: detached HEAD は対象外' $'\u00a0' "$(_merged_label "${det}")"
  check 'merged-label: 親リポジトリ自身は対象外' $'\u00a0' "$(_merged_label "${org}")"
}

# -a: <org>-worktree/<branch の / を - にした名前> に作り、そのパスだけを stdout に出す。
# fzf は存在確認だけに使われるので、空の fake で足りる。
test_add_places_worktree_by_branch() {
  new_repo addpath
  local fakebin="${tmproot}/addpath/fakebin" out
  mkdir -p "${fakebin}"
  printf '#!/bin/sh\n' >"${fakebin}/fzf"
  chmod +x "${fakebin}/fzf"
  out=$(cd "${org}" && PATH="${fakebin}:${PATH}" "${gwt_bin}" -a feature/foo 2>/dev/null)
  check 'add: <org>-worktree/<branch の / を - にした名前> に作る' \
    "$(realpath -m "${org_wt}")/feature-foo" "${out}"
  check 'add: そのパスに worktree の実体がある' \
    '1' "$([[ -e ${org_wt}/feature-foo/.git ]] && echo 1 || echo 0)"
}

tmux_fresh_server() {
  "${sandbox_bin}" --inside || exit 1
  tmux kill-server 2>/dev/null
  return 0
}

tmux_session() {
  tmux new-session -d -s "$1" -c "$2" 'sleep 600'
}

remove_from_org() {
  (cd "${org}" && _do_remove_worktree "$1" >/dev/null 2>&1)
}

tmux_has() {
  tmux has-session -t "=$1" 2>/dev/null && echo 1 || echo 0
}

test_remove_kills_tmux_sessions() {
  new_repo tmuxs
  tmux_fresh_server
  local wt wt_ab sub
  wt=$(add_wt feat-A)
  wt_ab=$(add_wt feat-AB)
  sub="${wt}/sub"
  mkdir -p "${sub}"
  tmux_session only-in "${wt}"
  tmux_session nested "${sub}"
  tmux_session mixed "${wt}"
  tmux new-window -t mixed -c "${org}" 'sleep 600'
  tmux_session other-ab "${wt_ab}"
  initial_toplevel="${org}"
  remove_from_org "${wt}/"
  check 'tmux: worktree 内だけの session は消える' '0' "$(tmux_has only-in)"
  check 'tmux: worktree のサブディレクトリだけの session は消える' '0' "$(tmux_has nested)"
  check 'tmux: 外の pane を含む session は残る' '1' "$(tmux_has mixed)"
  check 'tmux: prefix が同じ別 worktree の session は残る' '1' "$(tmux_has other-ab)"
}

test_remove_keeps_running_tmux_session() {
  new_repo tmuxcur
  tmux_fresh_server
  local wt pane socket
  wt=$(add_wt feat-A)
  tmux_session runner "${wt}"
  tmux_session victim "${wt}"
  pane=$(tmux list-panes -t '=runner' -F '#{pane_id}')
  socket=$(tmux display -p '#{socket_path}')
  initial_toplevel="${org}"
  local out err="${tmproot}/tmuxcur.err"
  out=$(cd "${org}" && TMUX="${socket},0,0" TMUX_PANE="${pane}" _do_remove_worktree "${wt}/" 2>"${err}")
  check 'tmux: kill しても stdout は空 (gt が cd 先として読む)' '' "${out}"
  check 'tmux: 実行中の session を残す警告を出す' '1' "$(grep -c "Keeping tmux session 'runner'" "${err}")"
  check 'tmux: 実行中の session は残る' '1' "$(tmux_has runner)"
  check 'tmux: 実行中でない session は消える' '0' "$(tmux_has victim)"
}

test_remove_without_tmux_server() {
  new_repo notmux
  tmux_fresh_server
  local wt rc
  wt=$(add_wt feat-A)
  (
    set -e
    export initial_toplevel="${org}"
    remove_from_org "${wt}/"
  )
  rc=$?
  check 'tmux: server が無くても remove が成功する' '0' "${rc}"
  check 'tmux: server が無くても worktree は消える' '0' "$([[ -e ${wt} ]] && echo 1 || echo 0)"
}

test_remove_loop_leaves_stdin_for_confirm() {
  new_repo loopstdin
  add_wt a >/dev/null
  add_wt b >/dev/null
  local log="${tmproot}/loopstdin.log"
  (
    cd "${org}" || exit 1
    export git_worktree_dir="${org_wt}"
    # shellcheck disable=SC2329  # _remove_worktree が呼ぶ
    _list_root_and_worktree_directories() { printf 't m l %s\n' "${org_wt}/a" "${org_wt}/b"; }
    # shellcheck disable=SC2329
    _fzf_worktrees() { cat; }
    # shellcheck disable=SC2329
    _do_remove_worktree() {
      local got=
      read -r got || true
      echo "${1##*/}:${got}" >>"${log}"
    }
    _remove_worktree </dev/null
  )
  check 'remove loop: 確認の read が選択の行を読まない' $'a:\nb:' "$(cat "${log}")"
}

main() {
  set -uo pipefail
  if ! "${sandbox_bin}" --inside; then
    exec "${sandbox_bin}" "${BASH_SOURCE[0]}" "$@"
  fi
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0

  test_remove_current_emits_org_root
  test_remove_from_root_emits_nothing
  test_remove_other_worktree_emits_nothing
  test_remove_untracked_does_not_need_sudo
  test_remove_leftover_leaves_no_stale_entry
  test_force_remove_refuses_outside_worktree_root
  test_force_remove_chowns_then_trashes
  test_fzf_args_with_branch
  test_fzf_args_without_branch
  test_org_root_outside_repo_fails
  test_org_root_from_worktree_subdir
  test_default_ln_config_without_ignored
  test_merged_label
  test_add_places_worktree_by_branch
  test_remove_kills_tmux_sessions
  test_remove_keeps_running_tmux_session
  test_remove_without_tmux_server
  test_remove_loop_leaves_stdin_for_confirm

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
