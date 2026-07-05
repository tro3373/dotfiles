#!/usr/bin/env bash
#
# uninstall.sh
#
# 目的: single-user Nix を完全に削除してクリーンな状態に戻す。
#       apps/nix/config は公式インストーラの single-user 版。これはその対の削除スクリプト。
#
# ============================================================================
# !!! 破壊的操作 !!!  実行前に必ず全文を読むこと。/nix を削除する。
# !!! 中身を確認してから自分で走らせること。
# ============================================================================
#
# --- 前提 (single-user インストール) ---
#   * /nix はカレントユーザー所有 => sudo 不要で削除できる想定
#   * daemon なし (nixbld ユーザー / /etc/nix / nix-daemon の systemd unit が無い)
#   * shell profile は未改変 (config が NIX_INSTALLER_NO_MODIFY_PROFILE=1 で入れ、
#     PATH は apps/zsh/.zsh/90.additional.zsh 側で通す方針)
#   ※ daemon(multi-user) 構成には非対応。痕跡を検出したら main で中断する。
# ---------------------------------------------------------------------------

has() { command -v "${1}" >&/dev/null; }
hass() { for _arg in "$@"; do has "$_arg" || die "==> No $_arg command exist."; done; }
_ink() { if has ink; then ink "$@"; else cat - 1>&2; fi; }
#_log() { echo "$(date +"%Y-%m-%d %H:%M:%S") $(test ! -t 0 && cat -) ${@:2}" | _ink "$1"; }
# shellcheck disable=SC2145
_log() { echo "$(date +"%Y-%m-%d %H:%M:%S") ${@:2}" | _ink "$1"; }
log() { _log white "$*"; }
info() { _log cyan "$*"; }
warn() { _log yellow "$*"; }
die() { _log red "$*" && exit 1; }

# --- 削除ヘルパー -----------------------------------------------------------
# 方針: 通常は rm ではなく trash を優先 (誤削除防止)。
#       ただし /nix は巨大 (数十GB規模) で、trash に送ると容量が一時的に倍増して
#       非現実的なので /nix だけは意図的に rm を使う (main 内の該当行を参照)。
rmpath() {
  if command -v trash >/dev/null 2>&1; then
    trash "$@"
    return
  fi
  rm -rf "$@"
}

# daemon(multi-user) 構成の痕跡があるか判定する。
# nixbld ユーザー / /etc/nix / nix-daemon の systemd unit のいずれかがあれば真。
is_daemon_install() {
  getent passwd | grep -q '^nixbld' && return 0
  [[ -d /etc/nix ]] && return 0
  compgen -G '/etc/systemd/system/*nix-daemon*' >/dev/null && return 0
  return 1
}

# ホーム配下の Nix メタデータを削除 (symlink や小ディレクトリなので trash 経由)。
remove_home_metadata() {
  rmpath ~/.nix-profile 2>/dev/null || true
  rmpath ~/.nix-channels 2>/dev/null || true
  rmpath ~/.nix-defexpr 2>/dev/null || true
  rmpath ~/.local/state/nix 2>/dev/null || true
  rmpath ~/.cache/nix 2>/dev/null || true
  rmpath ~/.config/nix 2>/dev/null || true
  rmpath ~/.config/nixpkgs 2>/dev/null || true
}

# /nix が消えたか報告する。
report_nix_dir() {
  if [[ -e /nix ]]; then
    warn "NG: /nix still remains"
    return
  fi
  info "OK: /nix removed"
}

# PATH から nix が消えたか報告する。
# 現在のシェルは PATH をキャッシュしているので `nix` がまだ引けることがある。
# hash -r でキャッシュを捨ててから確認する (新しいシェルを開けば確実に消える)。
report_nix_cmd() {
  hash -r 2>/dev/null || true
  if command -v nix >/dev/null 2>&1; then
    warn "Note: nix still resolves in the current shell (cached). Open a new shell to clear it."
    return
  fi
  info "OK: nix is gone from PATH"
}

main() {
  set -euo pipefail

  # --- ガード: これは single-user 専用。daemon 構成なら中断 ------------------
  # multi-user(daemon) で入っていると nixbld ユーザーや systemd unit が残り、
  # 単純な削除では壊れる。その痕跡があれば安全のため止める。
  if is_daemon_install; then
    die "detected daemon(multi-user) installation. This script is for single-user only."
  fi

  # --- 最終確認 -------------------------------------------------------------
  echo "About to remove single-user Nix:"
  echo "  - /nix (about $(du -sh /nix 2>/dev/null | cut -f1))"
  echo "  - ~/.nix-profile ~/.nix-channels ~/.nix-defexpr"
  echo "  - ~/.local/state/nix ~/.cache/nix"
  echo "  - ~/.config/nix ~/.config/nixpkgs (if present)"
  local ans
  read -r -p "Really proceed? [yes/N] " ans
  [[ ${ans} == "yes" ]] || {
    echo "Aborted."
    exit 0
  }

  # --- 1. 念のため動いている Nix プロセスを止める ---------------------------
  # single-user なので daemon はいない想定だが、残プロセスがあれば掃除する。
  pkill -u "${USER}" -f 'nix-daemon' 2>/dev/null || true

  # --- 2. ホーム配下の Nix メタデータを削除 ---------------------------------
  remove_home_metadata

  # --- 3. /nix ストア本体を削除 (意図的に rm) -------------------------------
  # 巨大なため trash 不可。/nix はカレントユーザー所有なので sudo 不要のはず。
  # もし "Permission denied" が出たら、この行を `sudo rm -rf /nix` に変えて再実行。
  sudo rm -rf /nix

  # --- 4. shell rc の掃除について -------------------------------------------
  # この dotfiles は shell rc に nix の source 行を書かず、
  # apps/zsh/.zsh/90.additional.zsh 側で PATH を通すので rc 編集は不要。
  # もし手動で rc に nix 行を足していたら、次のような行を削除すること (自動では触らない):
  #   . "$HOME/.nix-profile/etc/profile.d/nix.sh"

  # --- 5. 検証 --------------------------------------------------------------
  info "---- verify ----"
  report_nix_dir
  report_nix_cmd
  info "Cleanup complete."
}

main "$@"

# ============================================================================
# 削除後に入れ直す (実行は別途、手動で):
#
#   # 通常は config どおり (公式インストーラ / single-user) で入れ直す:
#   bin/setup -e nix
#
# --- 参考: daemon(multi-user) 版に切り替えたい場合 ---------------------------
#   # Determinate Systems インストーラ (daemon デフォルト / uninstaller 同梱 /
#   # flakes & nix-command デフォルト有効)。素の upstream Nix が欲しい場合は
#   # 対話プロンプトで "upstream Nix" を選ぶこと (--no-confirm だと確認を飛ばす)。
#   # ※ この場合 apps/nix/config と apps/zsh/.zsh/90.additional.zsh の見直しも要る。
#   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
#     | sh -s -- install
#
#   # 入れた後のアンインストールはこれ一発:
#   #   /nix/nix-installer uninstall
#
# --- 参考: 公式インストーラで daemon を使いたい場合 (アンインストーラは無い) ---
#   sh <(curl -L https://nixos.org/nix/install) --daemon
# ============================================================================
