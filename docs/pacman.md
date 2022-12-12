# pacman

## `--needed` option

グループの中にインストール済みのパッケージがある場合でも、
グループに合わせて再インストールされるが、それを無視するオプション

## Refs
- [はじめてのpacmanパッケージ管理ガイド](https://dev.classmethod.jp/articles/package-management-use-pacman/)
- [pacmanのオプションSyuについてほんの少し調べたこと](http://sotoattanito.hatenablog.com/entry/2016/09/24/133931)

## Package Update

```
pacman -Syyu --noconfirm
```

### options

- S: sync
    - sync option(local and remote repos sync)
- y: refresh
    - target is package list!
    - update local package list same as remote package list
- yy: refresh force
    - target is package list!
    - forces package list refresh even if it's up-to-date.
- u: upgrades
    - target is package
    - update local package same as remote package
- uu: upgrades enable downgrade!
    - if change the use repository test to safe,
      sometime the package version will be downgrade.
      when that, specify this option.


## Package Remove

```
# remove only the package
pacman -R <package name>
# remove with dependencies packages
pacman -Rs <package name>
```

## Package Search

```
# remote repository keyword search
pacman -Ss <keyword>
# remote repository package info
pacman -Si <package name>
# local(installed) keyword search
pacman -Qs <keyword>
# local(installed) package info
pacman -Qi <package name>
```

## Show installed files the package setuped

```
pacman -Ql <package name>
```

## Show setup package name from file

```
pacman -Qo /path/to/the/file
```
