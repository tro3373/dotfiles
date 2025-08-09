Vim Tips
=================================================================

## Function

### fnamemodify

```vim
echo(fnamemodify('/path/to/file', ':h'))
" => /path/to
```
- :h : headの略
- fnamemodify: ファイル名を変更する関数




bom
===============================================================================

- bom を消す

    ```vim
    :set nobomb
    ```

- bom を付ける

    ```vim
    :set bomb
    ```


checktime
===============================================================================
- 現在のバッファに関連付けられたファイルの最終変更時刻をチェック

autocmd!
===============================================================================
現在のグループをクリア
```
augroup checktime
  autocmd! " 現在のグループをクリア
  autocmd WinEnter,FocusGained,BufEnter * checktime
augroup END
```

<buffer> meanings
===============================================================================

- キーマッピングがローカルバッファに適用されることを意味
- そのキーマッピングは、定義されたバッファでのみ有効
- 他のバッファやファイルタイプで 同一キーを使用する際に、意図しない動作が発生することがない
- また、他のプラグインや設定が 同一キーにグローバルなキーマッピングを割り当てていても、現在のバッファのキーマッピングが優先される

# Regexp meanings

- `\k` は、任意の単語文字に一致する文字クラス
  単語文字は、英数字やアンダースコア _ などの文字を指す
  `\k` は `[0-9A-Za-z_]` と同じ意味

- `\W` は、単語文字以外の任意の文字に一致する文字クラス
  `\W` は `[^\k]` と同じ意味を持ちます。

# Replace selected by shell result

```
# select row by `V`
:!sh
```

# Execute buffer

```
:w !sh
```

# Case sensitive comparison

```
:let var = "text"
:echo var ==# "text"
"# => 1
:echo var ==# "TEXT"
"# => 0
```

# All paragraph into a single line

see help *edit-paragraph-join*

```
:g/./,/^$/join
```

# global

When the command is used recursively, it only works on one line.  Giving a
range is then not allowed. This is useful to find all lines that match a
pattern and do not match another pattern:

```vim
:g/found/v/notfound/{cmd}
```

To execute a non-Ex command, you can use the `:normal` command: >

```vim
:g/pat/normal {commands}
```

For ":v" and ":g!" the command is executed for each not
marked line.  If a line is deleted its mark disappears.

# Current filename, Current directory, etc...

Register `%` contains the name of the current file, and register `#` contains the name of the alternate file.

- In insert mode, type Ctrl-R then % to insert the name of the current file.
- In command mode (after typing a colon), type Ctrl-R then % to insert the name of the current file. The inserted name can then be edited to create a similar name.
- In normal mode, type "%p to put the name of the current file after the cursor (or "%P to insert the name before the cursor).

```vim
" directory/name of file (relative to the current working directory of /abc)
:echo @%                  " def/my.txt

" name of file ('tail')
:echo expand('%:t')       " my.txt

" full path
:echo expand('%:p')       " /abc/def/my.txt

" directory containing file ('head')
:echo expand('%:p:h')     " /abc/def

" First get the full path with :p (/abc/def/my.txt), then get the head of that with :h (/abc/def), then get the tail of that with :t (def)
:echo expand('%:p:h:t')   " def

" name of file less one extension ('root')
:echo expand('%:r')       " def/my

" name of file's extension ('extension')
:echo expand('%:e')       " txt

```

- The following commands insert lines consisting of the full path of the current and alternate files into the buffer
```
:put =expand('%:p')
:put =expand('#:p')
```

# Get EOF line number

```
line('$')
```

# Environment and Clipboard and Register

## Windows

- `*`, `+` is same.
- Use `set clipboard=unnamed`

## X11 system

- `*` : Selection(Primary)
- `+` : Cut buffer(Clipboard)
- Use `set clipboard=unnamedplus`

> Under Windows, the * and + registers are equivalent. For X11 systems, though, they differ.
> For X11 systems, * is the selection, and + is the cut buffer (like clipboard).
[Accessing the system clipboard | Vim Tips Wiki | Fandom](https://vim.fandom.com/wiki/Accessing_the_system_clipboard)

## Replace and Repeat

```
%s@^\(  \)\+@\=repeat("\t",len(submatch(0))/2)@g
```


## vim neosnippet
### Ref
- [NeoSnippetのsnippetファイルの設定](https://adragoona.hatenablog.com/entry/20130929/1380437722)
### Tips
```
snippet [name]
abbr [abbreviation]
alias [aliases]
regexp [pattern]
options [options]
  if ${1:conditions}
    ${2}
  endif
```

- name: 展開トリガーとなるキーワード
- abbr: 保管のポップアップに表示される説明文要約
- alias: 別名
- regexp: [pattern] にマッチした場合のみ展開
- options:
    - word: 単語区切りで name キーワードを探す
    - head: 行頭に書かれた name のみに適用される
    - indent: snippet展開後にindentを適用する
- place holder
    - ${number:text}: numberがジャンプ順、textが初期値
    - ${number:#text}: 入力しなければtextは消える(コメントに近い)
    - ${number:TARGET}: visualモードで選択中のテキストをここに挿入できる。
      この機能を使うためには、(neosnippet_expand_target)で
      snippetを展開するようkey mappingしないとだめ
    - ${number}:ただのジャンプ先のみの指定
    - $number: ジャンプ先ではなく、入力と同値を設定する場合に使用
    - ${0}: 最後にジャンプする場所

## vim diff
1. Vimを起動してそのままdiffを取りたい内容を貼り付け
2. :vnew(または:new)で新しいバッファを開く
3. 1.のバッファと比べたい内容を貼り付け
4. 3.のバッファでdiffthis
5. 1.のバッファでdiffthis

## vimfiler
j       カーソルを下に移動。末尾行では先頭行に移動
k       カーソルを上に移動。先頭行では末尾行に移動
gg      カーソルを先頭行に移動
G       カーソルを末尾行に移動
l       カーソルのディレクトリを開く
h       ひとつ上のディレクトリを開く
L       ドライブの切替
~       ホームディレクトリを開く
\       ルートディレクトリを開く
.       隠しファイル、フォルダの表示
C-L     ディレクトリの更新
t       カーソル上のディレクトリの１階層下をツリー形式で表示。ツリー表示を解除
T       カーソル上のディレクトリをツリー形式で表示。ツリー表示を解除
C-j     ディレクトリの履歴を表示
C-g     ファイル名を表示する
S       ファイルの並び替え
TAB     別のvimfilerウィンドウへカーソルを移動する。ウィンドウが1つの場合は2つ目のvimfilerウィンドウを開く
q       vimfilerを隠す(バッファに残る)
Q       vimfilerを閉じる(バッファに残らない)
e       カーソル上のファイルを編集
E       カーソル上のファイルを縦分割して編集
v       カーソル上のファイルをプレビューする
Space   カーソル上のファイルにマークをつける・マークをはずす
c       マークしたファイルをコピー
m       マークしたファイルを移動
d       マークしたファイルを削除
r       マークしたファイルの名前を変更
K       新規ディレクトリを作成
N       新規ファイルを作成
*       すべてのファイルにマークをつける・マークをはずす
U       すべてのファイルのマークをはずす
a       カーソル上のファイルに対して、様々なアクションを選択して実行
H       vimshellを開く
ge      vimfiler上のカレントディレクトリを、システムのエクスプローラで開く
x       カーソル上のファイルを、システムに関連付けされたアプリケーション(コマンド)で実行する
gr      grepコマンドを実行
gf      findコマンドを実行
yy      ファイルのフルパスをyank(コピー)
?       vimfilerのキーマップ一覧を開く

## 最短マッチ
- 行頭からカンマまでの最短一致
```vim
/^.\{-},
```

## highlight
`highlight {group-name} {key}={arg}`
グループについては、 `:help highlight-groups` で確認できる

| gVim  |vim     |対象   |
|:------|:-------|:------|
| gui   |cterm   |字書体 |
| guifg |ctermfg |字色   |
| guibg |ctermbg |景色   |




## .vimrc,_vimrc のロード順序
- ユーザー vimrc は以下の順で検索される
    - Windows
        - $HOME/_vimrc
        - $HOME/.vimrc
        - $VIM/_vimrc
        - $VIM/.vimrc
    - Linux
        - $HOME/.vimrc
        - $HOME/_vimrc

    - msys
        - => Linuxあつかいだよ

注意点は、ファイルが見つかった時点でそれ以降のファイルは読み込まれなくなるということです。
例えば Windows で上記の4つのファイルがすべて存在していたとき、初めの $HOME/_vimrc だけが読み込まれます。
他のファイルで上書きできるわけではありません。

優先度
高
　　$VIM/vimrc(サイトローカルな設定読み込みを記述部分)
　　$VIM/vimrc_local.vim
　　$VIM/vimrc(残りの部分)
　　$VIM/vimrc_local.vim : ユーザ優先設定
　　$HOME/vimrc（ここに格納された場合$VIMのは読み込まれない）
　　$VIM/vimrc
低


## $VIM,$HOMEのパスの確認方法
:echo $HOME
:echo $VIM

## setting sample
set gfn=Osaka－Mobile:h10:cSHIFTJIS
set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,] "カーソルを行頭、行末で止まらないようにする
scriptencoding utf-8 "これ入れないと下記が反映されない

augroup highlightZenkakuSpace "全角スペースを赤色にする
  autocmd!
  autocmd VimEnter,ColorScheme * highlight ZenkakuSpace term=underline ctermbg=Red guibg=Red
  autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
augroup END

set hidden    "ファイル変更中でも他のファイルを開けるようにする
set autoread    "ファイル内容が変更されると自動読み込みする

"Encode
"下記の指定は環境によって文字化けする可能性があるので適宜変更する
set encoding=UTF-8 "文字コードをUTF-8にする
set fileencoding=UTF-8 "文字コードをUTF-8にする
set termencoding=UTF-8 "文字コードをUTF-8にする


## viminfo
```vim
" viminfoファイルの出力先を変更する
" viminfoファイルの出力先も変更できます。
" viminfoファイルの出力先は、「viminfo」オプションの「n」フラグで指定します。

:set viminfo={他のフラグ...},n{ファイルパス}

" 今のviminfoの設定に追加するとしたら、このように設定
:set viminfo+=n{ファイルパス}
"「viminfo」オプションの「n」フラグは、全フラグ中、最後に指定しなければなりません。
"そうしないと、「n」フラグ以降に指定したフラグがファイルパスの一部として解釈され、エラーが発生します。

" この設定はvimエディタの設定ファイルに書きます。
" Windowsの場合のviminfoファイルの指定の例。
:set viminfo+=n~/vimfiles/tmp/viminfo.txt
:set viminfo+=nC:/Temp/viminfo.txt

" Mac OSXの場合のviminfoファイルの指定の例。
:set viminfo+=n~/.vim/tmp/viminfo.txt
:set viminfo+=n/tmp/viminfo.txt
"viminfoファイルを作成しない
"「viminfo」オプションに何のフラグも設定しなければ、 viminfoファイルの作成、および、読込は行わなくなります。
"vimエディタの設定ファイルで次のように指定してください。

" viminfoファイルを作成しない
:set viminfo=
```

## リロード
```vim
:e
Ctrl+l
```

## 折りたたみ/展開
```vim
(領域選択して)zf  折りたたみ
(折りたたみ行で)Space    折りたたみ展開
zfa{    カーソル位置の{}をたたむ
zo  折りたたみを展開
`zf/<space>` で指定した範囲を折りたたむ/開く

zi	折り畳みの有効無効の切り替え
zf	折り畳みを作成する
za	折り畳みの開け閉め
zd	折り畳みを削除する
時々使うコマンド

zA	折り畳みの開け閉め（再帰）
zD	折り畳みを削除する（再帰）
zE	全ての折り畳みを削除
zR	全ての折り畳みを開く
zM	全ての折り畳みを閉じる
折り畳みの種類の切り替えとか

set fdc=0	折り畳みカラム幅の設定
set fdm=manual	手動
set fdm=marker	マーカー
set fdm=indent	インデント
```

## 変数の設定
```vim
" ^= で既存の設定の先頭、+= で最後に設定を追加
:set runtimepath^=$HOME/.vim
:set runtimepath+=$HOME/.vim/after
```

## コマンドモード
```vim
" 現在の highlight 設定の表示
:highlight
" 最後にhighlight設定を行ったファイルの特定
:verbose highlight Statement

" カレントファイルのファイル名に拡張子をつけて保存
:w %.bk
" カレントファイルの拡張子を取り除く(%<)
:echo %<
" カレントファイルのヘッダファイルを開く
:e %<.h
" カレントディレクトリをファイルのディレクトリに変更する
" 今開いているファイルのディレクトリのパス(%:h)
:cd %:h

" 置換
" abc を含む行を削除する
:g/abc/d
" abc を含まない行を削除する
:v/abc/d
" vim 確認しながら置換
:%s//hogehoge/c

" コマンド実行結果を貼り付け
:r! ls
```

```vim
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
```

## 移動
- ノーマルモードでz<enter>(またはzt)とタイプすると、
  現在カーソルのある行が画面の一番上になるように画面がスクロールします。
  同様に、z.で中央、z-で一番下にスクロールします。
- H/M/Lでカーソルをウインドウ内の上/中/下に移動させる


## grep置換

```vim
:args **/*.rb
:argdo %s/tel/phone/gc | update
```

- 上の例では次のようなgrep置換を実施します。
- 拡張子が.rbになっているファイルを対象にする(`:args **/*.rb`)
- "tel"を"phone"に置換する(/tel/phone/g)
- 置換する際に一つずつ確認を入れる(/gcのc)
- 置換が終わったらファイルを保存する(| update)

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


VimScript
=================================================================
## ファイルの存在チェック
```vim
" ディレクトリが存在するかどうか
isdirectory({dir})
" ファイルが読み込み可能かどうか
"ファイルの存在チェックもするので、fileread() で読めるかをチェックしたいならこちらの方が確実。
filereadable({file})
" ファイルが書き込み可能かどうか
" filereadable() と同様。
filewritable({file})
" ファイルが実行可能かどうか
" system() を使う場合はこれで事前にチェックしておくと吉。
" 追記: 実際は実行可能なコマンドがあるかのチェックなので、$PATH とかも調べられます。ファイル自体を調べたい場合はフルパスで指定すること。
executable({file})
" ファイルもしくはディレクトリが存在するかどうか
glob({file})
```

## script内で定義した変数を使って実行
```vim
" `tabe local_variable` では `local_variable` ファイルを開こうとする為、exe を使用する
exe 'tabe' local_variable
```
## 正規表現を使う
```vim
" 最後が`/`で終わる場合 の判定
if path !~ '[/\\]$'
  " 文字列足しこみ
  let path .= '/'
endif
```
# 日付文字列操作
```vim
:let now = localtime()
:echo now
"# => 1203574847
:echo strftime("%Y/%m/%d %H:%M:%S", now)
"# => 2008/02/21 15:20:47
```

## OS 分岐
```vim
if has("mac")
" mac用の設定
elseif has("unix")
" unix固有の設定
elseif has("win64")
" 64bit_windows固有の設定
elseif has("win32unix")
" Cygwin固有の設定
elseif has("win32")
" 32bit_windows固有の設定
endif
```


Plugin Tips
=================================================================

## Surround vim
- [surround.vim](http://vimblog.hatenablog.com/entry/vim_plugin_surround_vim)

- Surround selected word: `S'`
- Delete surround: `ds'`
- Change surround: `cs'"`

## GitGutter
- [issue](https://github.com/airblade/vim-gitgutter/issues/150)
```vim
" Debug for gitgutter
:GitGutterDebug
" change shellslash via shell variable
set shellslash
if &shell =~ 'cmd.exe'
    set noshellslash
else
    set shellslash
endif
```
