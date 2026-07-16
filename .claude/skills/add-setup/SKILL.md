---
name: add-setup
description: bin/setup 出来る app を追加する
disable-model-invocation: true
user-invocable: true
model: opus
effort: xhigh # 努力レベル
---

# .dot に新しい app を追加する

`.dot` のアプリ導入は `apps/{name}/config` が単位。
ここに関数を書くと `bin/setup` が拾って実行する。
コードを読み直さずに新規追加できるようにまとめる。

## 最短手順

```sh
bin/newapp {name}      # apps/{name}/config の雛形を生成（生成後にvimで開くか聞かれる）
# → config の関数を埋める（下記）
bin/setup {name}       # デフォルトは dry-run。何が起きるか表示するだけ
bin/setup -e {name}    # -e/--exec で実際に実行
```

雛形を手で作る場合も同じ構造でよい。
`bin/newapp` は全 OS 関数を `not_supported` / `no_settings` で埋めた雛形を出すだけなので、必須ではない。

## config の仕組み

- `apps/{name}/config` は `bin/setup` が **source して関数を呼ぶライブラリ**。
  - 単体実行スクリプトではない。
- 中身は `#!/usr/bin/env bash` + 関数定義のみ。**`main()` は書かない**。
  - editor/lint hook が「main が無い」と警告することがあるが、この形式では無視する（既存の全 config が同じ形）。
- `bin/newapp` の雛形は全 OS 関数を `not_supported` / `no_settings` で埋めた状態。
  - **やりたい所だけ中身を書く**。
  - 未定義の関数は `bin/lib/setup/default` のデフォルトにフォールバックする。

## 定義する関数

| 関数 | 役割 |
|---|---|
| `install_common` | 全OS共通のインストール。まずこれを書く |
| `install_arch` / `install_mac` / `install_ubuntu` / `install_wsl` / `install_msys` / `install_cygwin` / `install_redhat` | OS別に挙動を変えたいときだけ上書き |
| `setting_common` / `setting_{os}` | インストール後の設定（configファイル配置など） |
| `is_installed` | スキップ判定（default: `has_or_local_package "$app"`）。**install名 ≠ 実行コマンド名なら上書き**（後述） |

非対応を明示するとき: `install_common() { not_supported; }` / `setting_common() { no_settings; }`

### dispatch の挙動（重要）

`bin/setup` は現在の OS に対応する関数を先に呼び、未定義なら共通版に落とす:

- install: `install_{os}` を試し、未定義（default にフォールバック）なら `install_common` を呼ぶ
- setting: `setting_{os}` を試し、未定義なら `setting_common` を呼ぶ

つまり **arch/mac だけ `install_*` を書き、共通の設定配置は `setting_common` に置く**のが定番（`setting_arch` を書かなくても `setting_common` が走る）。

### `is_installed`（スキップ判定）— install名 ≠ 実行コマンド名 に注意

`bin/setup` は **ディレクトリ名 = app名 = 実行コマンド名** を暗黙の前提にしている。
default の `is_installed` は `has_or_local_package "$app"`、つまり **app名を実行コマンドとみなして** 導入済みかを判定する。

インストールするパッケージ名と実行コマンド名がズレる app は、default では判定を外す。
その場合は config で `is_installed` を上書きし、実行コマンド名で判定する:

```bash
# apps/hunkdiff/config — install=hunkdiff / 実行コマンド=hunk のケース
install_common() { npm_install hunkdiff; }
is_installed()   { has hunk; }
```

- 実行コマンド名 = ディレクトリ名 のとき（例: `apps/hunk` で実行コマンドも `hunk`）は default のままでよい。上書き不要。
- 実行コマンドを持たない GUI アプリ等はパスの存在で判定する（例: `is_installed() { [[ -e /Applications/Foo.app ]]; }`）。

既存の上書き例:

| app（=ディレクトリ名） | 実行コマンド | is_installed |
|---|---|---|
| `aria2` | `aria2c` | `is_installed() { has aria2c; }` |
| `fcitx5-mozc` | `fcitx5` | `is_installed() { has fcitx5; }` |
| `postgres` | `psql` | `is_installed() { has psql; }` |

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
| `def_install {pkg}` / `install_via_os_default` | OS標準の pkg manager で入れる（pacman/yay / brew / apt…） |
| `add_dependency_args {app}` | 先に別 app を入れさせてから戻る（例: `apps/bun` → asdf） |
| `go_install pkg@ver` / `npm_install` | 言語別インストール |
| `github` `github_user_local` `dl` `dl_untar` `dl_unzip` `dl_gh_release` | ダウンロード / GitHub リリース取得 |
| `make_link_dot2home` `make_lnk_with_bkup` `make_link_to_bin` | symlink 作成（バックアップ付き） |
| `add_path {dir}` `tee_to_works_zsh` `sudo_tee` `cat_you_need_to {file}` | 設定・PATH の書き込み |
| `log` `dlog`(debug) `elog`(error) `ilog` | ログ出力 |

config 内で `$app_dir`（= `apps/{name}`）を参照するときは shellcheck が変数未定義と誤検知するので、その行の前に `# shellcheck disable=SC2154` を付ける。

## bin/setup の実行オプション

| コマンド | 動作 |
|---|---|
| `bin/setup {app}` | **デフォルト dry-run**（`dry_run=1`）。実行せず表示だけ |
| `bin/setup -e {app}` | `--exec`。実際に実行 |
| `bin/setup -f {app}` | `--force`。インストール済みでも強制実行 |
| `bin/setup -v {app}` | `--view`。config を vim で開く |
| `bin/setup -d {app}` | `--debug`。`dlog` を表示 |

**新規追加後は必ず `bin/setup {app}`（dry-run）で、意図した install コマンドと symlink が出るか確認してから `-e` する。**

## 実例（既存 config を見るのが早い）

- `apps/ghq/config` … `go_install` 1行 + gitconfig 追記
- `apps/wezterm/config` … arch=`def_install` / mac=`brew --cask` / `make_lnk_with_bkup` で `~/.config/wezterm` に配置。config を `~/.config` へ symlink する app の手本
- `apps/bun/config` … `add_dependency_args asdf` で依存を解決してから asdf でインストール
- `apps/debtap/config` … arch 専用（他OSは `not_supported`）
- `apps/nix/config` … `has` でべき等化 + `exe 'curl … | sh …'`

## 落とし穴

1. **`main()` は書かない** — config はライブラリ。hook の main 警告は無視する。
2. **`~/.works.zsh` を消さない・直接汚さない** — マシン固有のローカル設定（PATH追加・秘密・completion）が入る `chmod 700` のファイル。多数の app config がここに追記する。PATH や env を永続化したいときは `add_path` / `tee_to_works_zsh` でここに足す。
3. **shell profile を直接いじらない** — PATH は `apps/zsh/.zsh/` 側で管理する（例: nix は `NIX_INSTALLER_NO_MODIFY_PROFILE=1` でインストーラに profile を触らせず、`90.additional.zsh` で `~/.nix-profile/etc/profile.d/nix.sh` を source して通す）。
4. **ディレクトリ名 = 実行コマンド名 を暗黙前提にしている** — 違うなら `is_installed` を上書きしないと導入済み判定を外す（「定義する関数」の `is_installed` 節を参照）。
