=================================================================
# Vim Tips

## Command Mode
```vim
" カレントファイルのファイル名に拡張子をつけて保存
:w %.bk
" カレントファイルの拡張子を取り除く(%<)
:echo %<
" カレントファイルのヘッダファイルを開く
:e %<.h
" カレントディレクトリをファイルのディレクトリに変更する
:cd %:h
" 今開いているファイルのディレクトリのパス(%:h)
```

### abc を含む行を削除する
```
:g/abc/d
```
### abc を含まない行を削除する
```
:v/abc/d
```

### vim 確認しながら置換
```
:%s//hogehoge/c
```

`:r! ls` でコマンド実行結果を貼り付けする！！！！！
gf      : open file name under cursor (SUPER)
J/gJで行を連結
```
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

## OS 分岐
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


## Vim の基本
### 変数の設定
```vim
" ^= で既存の設定の先頭、+= で最後に設定を追加
:set runtimepath^=$HOME/.vim
:set runtimepath+=$HOME/.vim/after
```

### .vimrc,_vimrc のロード順序
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


### $VIM,$HOMEのパスの確認方法
:echo $HOME
:echo $VIM

### setting sample
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


### viminfo
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

# Plugin Tips

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
