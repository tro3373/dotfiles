# git tips.

## worktree

### 概要
`git worktree`は1つのGitリポジトリで複数の作業ツリーを管理するコマンド。
ブランチごとに独立したディレクトリで並行作業が可能で、リポジトリのクローンを省略する。

### 基本コマンド

#### 1. 新しい作業ツリーの作成
```bash
git worktree add <path> <branch>
```
- `<path>`に`<branch>`の作業ツリーを作成。
- ブランチのファイルが`<path>`に即座に展開される（ブランチが空でない限り）。
- 例: `git worktree add ../feature feature` → `../feature`に`feature`ブランチのファイルが展開。

#### 2. 新ブランチ作成と作業ツリーの割り当て
```bash
git worktree add -b <new-branch> <path> [<base-branch>]
```
- `<base-branch>`（省略時は現在のブランチ）を基点に`<new-branch>`を作成。
- `<path>`に`<new-branch>`の作業ツリーを展開。
- 例: `git worktree add -b new-feature ../new-feature main` → `main`から`new-feature`を作成し、`../new-feature`に展開。

#### 3. 作業ツリーの一覧表示
```bash
git worktree list
```
- 全作業ツリーと対応ブランチを表示。

#### 4. 作業ツリーの削除
```bash
git worktree remove <path>
```
- 指定した作業ツリーを削除。未コミットの変更がある場合は`--force`が必要。

#### 5. 作業ツリーのクリーンアップ
```bash
git worktree prune
```
- 無効な作業ツリーの参照を削除。

### コミットとプッシュの挙動
- **コミット**: 作業ツリーでコミットすると、リポジトリ全体の履歴（`.git`）に反映される。他の作業ツリー（例: `main`）から`git log --all`で確認可能。
- **プッシュ**: `git push origin <branch>`は現在の作業ツリーのブランチをリモートに送信。他のブランチや作業ツリーに影響しない。
- 例: `../feature`で`git commit`後、`git push origin feature` → リモートの`feature`ブランチが更新。

### 使用例
1. `git worktree add ../feature feature`: `feature`ブランチの作業ツリーを`../feature`に作成。
2. `../feature`で編集・コミット: リポジトリ履歴に反映され、`main`から確認可能。
3. `git worktree add -b bugfix ../bugfix main`: `main`から`bugfix`ブランチを作成し、`../bugfix`に展開。
4. `git push origin bugfix`: `bugfix`ブランチをリモートに送信。
5. `git worktree remove ../feature`: 作業ツリーを削除。

### 注意点
- 同一ブランチを複数作業ツリーでチェックアウト不可。
- 作業ツリーはブランチのファイル展開済みで、空でない（ブランチが空でない限り）。
- ディスク容量は`.git`共有で節約されるが、作業ツリーのファイルはコピーされる。
- Git 2.5以降で利用可能。


## 直前のコミットメッセージをエディタで開く

```
git commit -c ORIG_HEAD
```

## Gitの設定をリポジトリにより自動で切り替える

.gitconfig

```
[ghq]
  root = ~/src
[includeIf "gitdir:~/src/github.com/sample/"]
  path = ~/.config/git/sample.gitconfig
```

~/.config/git/sample.gitconfig

```
[user]
  email = sample@sample.com
  signingkey = XXXXXXXXXXXXXXXXX
```

## Chnange date
```
git rebase -i HEAD~数字
git commit --amend --date="Wed Jan 10 23:59:59 2018 +0900"
git rebase --continue
git rebase HEAD~数字 --committer-date-is-author-date
```

## Show diff with ignore all white spaces.

```sh
git diff -w
# git diff -b
# git diff --ignore-space-change
```

## Add submodule

```sh
git submodule add git@github.com:account/repos.git path/to/repos
```

## Delete submodule

```sh
git submodule deinit path/to/submodule
git rm path/to/submodule

# If you use git version under v1.8.5
# and execute bellow too.
#   git config -f .gitmodules --remove-section submodule.path/to/submodule
```

## Add permission

```sh
# add executable
git update-index --add --chmod=+x [filename]
# del executable
git update-index --add --chmod=-x [filename]
```

## Exclude file already managed by git

```sh
git update-index --assume-unchanged [filename]
git update-index --no-assume-unchanged [filename]
git update-index --skip-worktree [filename]
git update-index --no-skip-worktree [filename]

```

## Patches from another repository

```
# repo1
git format-patch <COMMIT_ID_FROM>..<COMMIT_ID_TO> -o path/to/patch
# repo2
git am --directory=android/frameworks/base path/to/patch
```
