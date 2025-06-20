# Sample .bashrc color PS1

```bash
col() {
  red="1;31m"
  blue="1;34m"
  green="1;32m"
  cyan="1;36m"
  gray="0;37m"
  case "$(hostname)" in
    *huba01) echo $red ;;
    *huba02) echo $blue ;;
    *huba03) echo $green ;;
    *bsta01) echo $cyan ;;
    *) echo $gray ;;
  esac
}
open="\033["
close="${open}0m"
PS1="[\t \u@${open}$(col)\h${close}@AWS \W]\$ "
```

# Parameter Expansion

```bash
var=HeyThere
echo ${var,,}
heythere
```

```bash
${var^}     #Heythere
${var^^}    #HEYTHERE
${var,}     #heyThere
${var,,}    #heythere
```


# bash chips

## Priority of process

```bash
# プロセス優先度最低、ディスクI/O優先度最低
ionice -c 2 -n 7 nice -n 19 <command>
```

### ionice
- -c            | --class               : I/O スケジューリングのクラスを指定する(0~3. 1が最優先)
                                        :   0: none, 1: realtime, 2: best-effort, 3: idle
- -n            | --classdata           : クラス1と2の中で優先度を0~7でいていする(0が最優先)
- -p プロセスID | --pid プロセスID      : 対象とするプロセスのID（空白区切りで複数指定可能）
- -t            | --ignore              : クラスや優先度がセットできない場合もコマンドを実行する

### nice
- -n 優先度     | --adjustment=優先度   : 優先度（-20～19）を指定する

## pipe vim

```bash
# vimで編集後、 stty sane しないと表示が崩れる
find . -name '*.java' -type f |xargs vim

# こういう場合は以下で実行する
find . -name '*.java' -type f |xargs -o vim
find . -name '*.java' -type f -exec vim {}+
# または pipeを受け取るshell内では以下のように標準入力を明示する
vim $@ </dev/tty
```

## pipe while は信用できない

- main func 内で直の while ループ内で配列に追加すると問題なく追加できるが、
  pipe を一段でもかますと追加できない

## test コマンド

```bash
test コマンドのオプションの意味
-p	名前付きパイプであれば真
-t	端末にてオープンされていれば真
```

## プロセス置換

```bash
# 実行結果をdiffする
diff <(cat file1) <(cat file1 |grep hogehoge)
# command1の結果をcommand2とcommand3に渡す
command1 | tee >(command2) | command3
# command1の結果(カラー付き)を標準出力、標準エラー出力しながら、ファイルにも書き込むが、そのときはカラーをOFFる
# @see vim snippet innnk_off
command1 |& tee >(cat - | ink_off >>example_log_file)

# 標準エラー出力の行頭に[ERROR]を付けて標準出力に出力する
command 2> >(awk '{print "[ERROR]", $0}')
```

## 標準入力

```bash
diff <(cat file1) <(cat file1 |grep hogehoge)

# ファイルの内容を変数へ格納する
VAR2=$(<file)
# 変数の値をファイルとしてコマンドへ渡す
command <<< $VAR1
```

## 基本

\$? ==> 直前のコマンドの実行結果

$$
$! ==> シェルが最後に起動したバックグラウンドプロセスのプロセスID
!$ ==> 前回実行コマンドの最後の引数を取得

    less /a/b/c
    vim !$

!! ==> 前回実行コマンドの全体を取得

    service httpd restart
    sudo !!

$- ==> シェルの起動時のフラグの一覧
$_ ==> 実行シェル(./hoge.sh => ./hoge.sh, bash hoge.sh => /bin/bash)

$# ==> 引数の数
$0 ==> スクリプト自体
$* ==> 引数変数$1、$2、$3...をスペースで区切ってすべて表示(IFSに値をセットしておくと、区切り文字を変更)
$@ ==> IFSに影響しない$*
${#args[@]} ==> 配列の数

```bash
## "@", "*" 違いサンプル
asterisk() { for i in "$*"; do echo $i done }
asterisk 123 abc
# ==> 123 abc
at() { for i in "$@"; do echo $i done }
at 123 abc
# ==> 123
#     abc
```

${VAR:-expression}   ==> 値がセットされていない(NULL)場合、   :-以降の式を評価結果を返す。
${VAR:+expression}   ==> 値がセットされている(NONE-NULL)場合、:+以降の式を評価結果を返す。
${VAR:=expression}   ==> 値がセットされていない(NULL)場合、   :=以降の式を評価結果を返し変数に代入。
${VAR:?[expression]} ==> 値がセットされていない(NULL)場合、    式が標準エラーに出力。


{ commands ; }, ( commands ) ==> サブシェルでコマンドを実行
umask [nnn]                  ==> 作成されるファイルのデフォルトのパーミッションを8進数のマスクで設定
trap [command sig]...        ==> 割り込み発生時にコマンドを実行
exec command                 ==> コマンドを実行
:                            ==> 何もしない
. filename                   ==> ファイルを読み込む


-e filename     ==> ファイルが存在していれば真
-d filename     ==> ディレクトリであれば真
-f filename     ==> 通常ファイルであれば真
-h filename     ==> シンボリックリンクであれば真
-r filename     ==> 読むことが可能なファイルであれば真
-w filename     ==> 書き込み可能なファイルであれば真
-s filename     ==> file が 0 より大きければ真
-n string       ==> 文字列の長さが 0 でなければ真
-z string       ==> 文字列の長さが 0 であれば真
string          ==> 文字列で空でなければ真
s1 = s2         ==> 文字列s1 と文字列s2 が同じであれば真
s1 != s2        ==> 文字列s1 と文字列s2 が異なれば真
n1 -eq n2       ==> 数値n1 と数値n2 が同じであれば真
n1 -ne n2       ==> 数値n1 と数値n2 が異なれば真
n1 -gt n2       ==> 数値n1 が数値n2 より大きければ真
n1 -ge n2       ==> 数値n1 が数値n2 以上であれば真
n1 -lt n2       ==> 数値n1 が数値n2 より小さければ真
n1 -le n2       ==> 数値n1 が数値n2 以下であれば真
! expression    ==> 評価した式が偽であれば真
expr1 -a expr2  ==> 式expr1 と式expr2 が真であれば真
expr1 -o expr2  ==> 式expr1 と式expr2 のいずれかが真であれば真


< filename      ==> ファイルの内容を標準入力に渡す
> filename      ==> 標準出力をファイルに書き込む
>> filename     ==> 標準出力をファイルに追加する
<<word          ==> 指定したワードで始まる行まで標準入力に渡す
<&digit         ==> 指定したデスクリプタを標準入力として扱う
>&digit         ==> 指定したデスクリプタを標準出力として扱う
- 以下は標準エラー出力を標準出力として扱いファイルに記録する
　　command 2>&1 > filename
- 以下は標準出力を標準エラー出力として扱う
　　echo "I'm sorry Dave, I'm afraid I can't do that." 1>&2
<&-             ==> 標準入力を閉じる
>&-             ==> 標準出力を閉じる
&>              ==> 標準出力と標準エラー出力の両方をリダイレクト
>&              ==> 同義

    ls /home/bin /home/user1 &> hoge.log
    ls /home/bin /home/user1 >& hoge.log
    ls /home/bin /home/user1 > hoge.log 2>&1
    ls /home/user1 | tee hoge.log

command1 | command2  ==> コマンド１の標準出力をコマンド２の標準入力に渡す
command1 && command2 ==> コマンド１が正常終了すればコマンド２を実行
command1 || command2 ==> コマンド１が正常終了でなければコマンド２を実行
command1 |& command2 ==> コマンド１の標準出力と標準エラー出力の両方をコマンド２へパイプ
    - [bash - How can I pipe stderr, and not stdout? - Stack Overflow](https://stackoverflow.com/questions/2342826/how-can-i-pipe-stderr-and-not-stdout)

```bash
# ファイル名を取得
basename '/a/b/c.d.e'
# c.d.e
# ファイル名を取得(拡張子なし)
basename '/a/b/c.d.e' .e
# c.d

# スクリプトファイルのディレクトリを取得
dirname '/a/b/c.d.e'
# /a/b
# スクリプトファイルのディレクトリを取得
BASEDIR=$(cd $(/usr/bin/dirname $0); pwd)
```

# source されるスクリプトを考慮した ファイルの存在するディレクトリ
app_dir="$(cd -- "$(dirname -- "${BASH_SOURCE}}")"; pwd)"

## 文字操作
var=12345; echo ${var:1:3}
==> 234
var=12345; echo ${#var}
==> 5
==> 文字数を取得
${変数名^^} →大文字に変換
${変数名,,} →小文字に変換
${変数名#パターン} → 前方一致でのマッチ部分削除(最短マッチ)
${変数名##パターン} → 前方一致でのマッチ部分削除(最長マッチ)
${変数名%パターン} → 後方一致でのマッチ部分削除(最短マッチ)
${変数名%%パターン} → 後方一致でのマッチ部分削除(最長マッチ)
${変数名/置換前文字列/置換後文字列} → 文字列置換(最初にマッチしたもののみ)
${変数名//置換前文字列/置換後文字列} → 文字列置換(マッチしたものすべて)

```bash
var="/my/path/dir/test.dat"
echo ${var#*/}
==> my/path/dir/test.dat
echo ${var##*/}
==> test.dat

var="/my/path/dir/test.20130930.dat"
echo ${var%.*}
==> /my/path/dir/test.20130930
echo ${var%%.*}
==> /my/path/dir/test

var="abcdef abcdef xyz"
# Replace First Only
echo ${var/abc/XXX}
==> XXXdef abcdef xyz
# Replace ALL
echo ${var//abc/XXX}
==> XXXdef XXXdef xyz

# 文字列の最後の一文字を取得する
STRING=abcdefg
echo ${STRING: -1}
==> g

# 最後の一文字を削除する
echo ${STRING/%?/}
==> abcdef
```

## ブレース展開

```bash
# backup 作成
cp /path/to/target/file/hogehoge{,.bk}
# 展開処理
echo 192.168.1.{1,3}
==> 192.168.1.1 192.168.1.3
echo 192.168.1.{1..5}
==> 192.168.1.1 192.168.1.2 192.168.1.3 192.168.1.4 192.168.1.5
echo /opt/{app,db}/{data,conf}
==> /opt/app/data /opt/app/conf /opt/db/data /opt/db/conf
```

## exec
exec &>fileとすると以降のコマンド実行結果は全てfileに書かれる

### 任意のファイルディスクリプタを開く。(出力)

```bash
exec 3>file         # 3というfileへの出力用のディスクリプタ(3以外でもよい)を開く
echo "hoge" >&3
exec 3>&-           # ファイルディスクリプタを閉じる
```

### 任意のファイルディスクリプタを開く。(入出力)

```bash
echo "hoge" > file
echo "fuga" >> file
echo "piyo" >> file
exec 3<> file
read var1 <&3
echo $var1  #hoge
echo 'puyo' >&3
exec 3>&-
exec 3<&-
cat file
# hoge
# puyo
# piyo
```
```bash
# 同義
echo 'hoge' >hoge.txt
>hoge.txt echo 'hoge'
echo >hoge.txt 'hoge'
```

## historyに日時を残す

HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

## 現在のセッションの履歴を残さない
unset HISTFILE && exit

## 履歴全削除
HISTFILESIZE=0 && exit

## パイプでコマンドを繋げた時にパイプのどれか1つでも0以外の戻り値を返したら
   その戻り値(複数あった場合は最も右側)を返す

-o pipefail


## EXITをフックする
```bash
#!/bin/bash

# 一時ファイルを格納するディレクトリを作成
tmpfile=$(mktemp -d)

# スクリプト終了時に必ず実行したい処理を記述
function finally {
    rm -rf $tmpfile
}
# trapコマンドでEXITシグナル受信時にfinally関数が実行されるようにする
trap finally EXIT

echo 'start' > $tmpfile/file1
cat $tmpfile/file1
```

$$

## test -n
```bash
var=
test -n $var && echo ng
ng      <<<<<<<<<<<<<<<< ATTENTION!!
test -n "$var" || echo ok
ok
var=hogehoge
test -n $var && echo ok
ok
test -n "$var" && echo ok
ok

var=
test -z $var && echo ok
ok
test -z "$var" && echo ok
ok
var=hogehoge
test -z $var || echo ok
ok
test -z "$var" || echo ok
ok
```
