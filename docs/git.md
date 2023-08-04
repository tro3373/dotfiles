# git tips.

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
