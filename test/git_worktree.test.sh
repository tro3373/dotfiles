#!/usr/bin/env bash

# git_worktree のユニットテスト (実 git 使用・NW/fzf 不要)。
# 末尾の `main "$@"` を除いて source し、関数を直接呼ぶ。
#
# 検証対象:
#   * _do_remove_worktree: 現在地(initial_toplevel)の worktree を削除したときだけ
#       org root を stdout に出す (zsh wrapper gt が cd し直すための救済)。
#       現在地でない worktree 削除時・org root から削除時は stdout 空。
#
#   * _fzf_worktrees: 位置引数のブランチ名を fzf の絞り込みクエリへ変換する。
#       引数ありのときだけ --query/--select-1 を足す (list/merge/remove 共通)。
#
#   test/git_worktree   # 全テスト実行

script_dir=$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)
gwt_bin=$(cd "${script_dir}/../bin" && pwd)/git_worktree

# shellcheck disable=SC1090
source "$gwt_bin"

# tasks コマンドの副作用を避けるため no-op で差し替える
tasks() { return 0; }

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

# branch を設定して _fzf_worktrees を呼び、fzf へ渡った引数列を返す。
# fzf は引数記録スタブに差し替える (stdin の一覧は捨て、受け取った引数を 1 行 1 個で
# 返す)。スタブも branch 代入もサブシェル body に閉じるので他テストへ漏れない。
capture_fzf_args() (
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

main() {
  set -uo pipefail
  tmproot=$(mktemp -d)
  trap 'rm -rf "${tmproot}"' EXIT
  local pass=0 fail=0

  test_remove_current_emits_org_root
  test_remove_from_root_emits_nothing
  test_remove_other_worktree_emits_nothing
  test_fzf_args_with_branch
  test_fzf_args_without_branch

  printf '\n%d passed, %d failed\n' "${pass}" "${fail}"
  [[ ${fail} -eq 0 ]]
}

main "$@"
