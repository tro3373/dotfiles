# `=` と `:=` と `?=`

- `:=` : 即時評価
- `=`  : 遅延評価
- `?=` : 未定義の場合に設定

## `recursive expansion` (再帰的展開)

```
foo = $(bar)
bar = $(ugh)
ugh = Huh?
foo ?= hoge

all:;echo $(foo)
```

will echo `Huh?`: `$(foo)` expands to `$(bar)` which expands to `$(ugh)` which finally expands to `Huh?`.

[GNU make - How to Use Variables](https://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_6.html#SEC59)
