=================================================================
# Vim Tips

### abc を含む行を削除する
```
:g/abc/d
```
### abc を含まない行を削除する
```
:v/abc/d
```

`:r! ls` でコマンド実行結果を貼り付けする！！！！！
gf      : open file name under cursor (SUPER)
J/gJで行を連結

<C-R>"  : インサートモードから貼り付け！
ga      : display hex, ascii value of character under cursor
g8      : display hex value of utf-8 character under cursor
CTRL-R=5*5    : insert 25 into text
=             : (re)indent the text on the current line or on the area selected (SUPER)
=%            : (re)indent the current braces { ... }
G=gg          : auto (re)indent entire document
:e!           : return to unmodified file

CTRL-R CTRL-W   : pull word under the cursor into a command line or search
CTRL-R CTRL-A   : pull whole word including punctuation
CTRL-R -        : pull small register
CTRL-R [0-9a-z] : pull named registers
CTRL-R %        : pull file name (also #)
Retrieving last command line command for copy & pasting into text
<c-r>:
Retrieving last Search Command for copy & pasting into text
<c-r>/
<C-X><C-F> :insert name of a file in current directory



## 移動
- ノーマルモードでz<enter>(またはzt)とタイプすると、現在カーソルのある行が画面の一番上になるように画面がスクロールします。
  同様に、z.で中央、z-で一番下にスクロールします。
- H/M/Lでカーソルをウインドウ内の上/中/下に移動させる


## grep置換

```
:args **/*.rb
:argdo %s/tel/phone/gc | update
```

- 上の例では次のようなgrep置換を実施します。
- 拡張子が.rbになっているファイルを対象にする(`:args **/*.rb`)
- "tel"を"phone"に置換する(/tel/phone/g)
- 置換する際に一つずつ確認を入れる(/gcのc)
- 置換が終わったらファイルを保存する(| update)

## 折りたたみ
`zf/<space>` で指定した範囲を折りたたむ/開く

## 検索
 VIM検索ワード
- [:alpha:]	アルファベット
- [:alnum:]	アルファベットとアラビア数字
- [:blank:]	スペースとタブ文字
- [:space:]	ホワイトスペース文字
- [:digit:]	10進数
- [:xdigit:]	16進数
- [:graph:]	スペースを除いた印字可能な文字
- [:print:]	スペースを含めた印字可能な文字
- [:upper:]	アルファベットの大文字
- [:lower:]	アルファベットの小文字
- [:punct:]	句読点文字
- [:cntrl:]	制御文字
- [:return:]	<CR> 文字
- [:tab:]	<Tab> 文字
- [:escape:]	<Esc> 文字
- [:backspace:]	<BS> 文字

