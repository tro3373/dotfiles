# setup に新しい app を追加する

`.dot` のアプリ導入は `apps/{name}/config` が単位。ここに関数を書くと `bin/setup` が拾って実行する。コードを読み直さずに新規追加できるようにまとめる。

## 最短手順

```sh
bin/newapp {name}      # apps/{name}/config の雛形を生成（生成後にvimで開くか聞かれる）
# → config の関数を埋める（下記）
bin/setup {name}       # デフォルトは dry-run。何が起きるか表示するだけ
bin/setup -e {name}    # -e/--exec で実際に実行
```

## config の仕組み

- `apps/{name}/config` は `bin/setup` が **source して関数を呼ぶライブラリ**。単体実行スクリプトではない。
- 中身は `#!/usr/bin/env bash` + 関数定義のみ。**`main()` は書かない**（editor/lint hook が「main が無い」と警告することがあるが、この形式では無視する。既存の全 config が同じ）。
- `bin/newapp` の雛形は全 OS 関数を `not_supported` / `no_settings` で埋めた状態。**やりたい所だけ中身を書く**。未定義の関数は `bin/lib/setup/default` のデフォルトにフォールバックする。

## 定義する関数

| 関数 | 役割 |
|---|---|
| `install_common` | 全OS共通のインストール。まずこれを書く |
| `install_arch` / `install_mac` / `install_ubuntu` / `install_wsl` / `install_msys` / `install_cygwin` / `install_redhat` | OS別に挙動を変えたいときだけ上書き |
| `setting_common` / `setting_{os}` | インストール後の設定（configファイル配置など） |
| `is_installed` | スキップ判定（default: `has_or_local_package "$app"`） |

非対応を明示するとき: `install_common() { not_supported; }` / `setting_common() { no_settings; }`

## べき等化の定番

```bash
install_common() {
  if has {cmd}; then
    return
  fi
  exe ...
}
```

## ヘルパー早見表（定義は `bin/lib/setup/funcs`）

| ヘルパー | 用途 |
|---|---|
| `exe 'cmd'` | 実行ラッパー。中身は `eval "$*"`。dry-run 時はログ表示のみで実行しない。パイプ可。`exe export FOO=1` も可（eval なので現在シェルに残る） |
| `has {cmd}` | `command -v`。べき等判定に使う |
| `is_dry` `is_arch` `is_mac` `is_wsl` `is_ubuntu` `is_redhat` `is_win` `is_arm` | 環境判定 |
| `install_via_os_default` | OS標準の pkg manager で入れる（pacman / brew / apt…） |
| `add_dependency_args {app}` | 先に別 app を入れさせてから戻る（例: `apps/bun` → asdf） |
| `go_install pkg@ver` / `npm_install` | 言語別インストール |
| `github` `github_user_local` `dl` `dl_untar` `dl_unzip` `dl_gh_release` | ダウンロード / GitHub リリース取得 |
| `make_link_dot2home` `make_lnk_with_bkup` `make_link_to_bin` | symlink 作成（バックアップ付き） |
| `add_path {dir}` `tee_to_works_zsh` `sudo_tee` `cat_you_need_to {file}` | 設定・PATH の書き込み |
| `log` `dlog`(debug) `elog`(error) `ilog` | ログ出力 |

## bin/setup の実行オプション

| コマンド | 動作 |
|---|---|
| `bin/setup {app}` | **デフォルト dry-run**（`dry_run=1`）。実行せず表示だけ |
| `bin/setup -e {app}` | `--exec`。実際に実行 |
| `bin/setup -f {app}` | `--force`。インストール済みでも強制実行 |
| `bin/setup -v {app}` | `--view`。config を vim で開く |
| `bin/setup -d {app}` | `--debug`。`dlog` を表示 |

## 実例（既存 config を見るのが早い）

- `apps/ghq/config` … `go_install` 1行 + gitconfig 追記
- `apps/bun/config` … `add_dependency_args asdf` で依存を解決してから asdf でインストール
- `apps/debtap/config` … arch 専用（他OSは `not_supported`）
- `apps/nix/config` … `has` でべき等化 + `exe 'curl … | sh …'`

## 落とし穴

1. **`main()` は書かない** — config はライブラリ。hook の main 警告は無視する。
2. **`~/.works.zsh` を消さない・直接汚さない** — マシン固有のローカル設定（PATH追加・秘密・completion）が入る `chmod 700` のファイル。多数の app config がここに追記する。PATH や env を永続化したいときは `add_path` / `tee_to_works_zsh` でここに足す。
3. **shell profile を直接いじらない** — PATH は `apps/zsh/.zsh/` 側で管理する（例: nix は `NIX_INSTALLER_NO_MODIFY_PROFILE=1` でインストーラに profile を触らせず、`90.additional.zsh` で `~/.nix-profile/etc/profile.d/nix.sh` を source して通す）。
