#!/bin/bash

################################################### SETTING START
# powerline設定を実行するかどうか
EXE_POWERLINE=1
# インストールコマンド DEBUG 実行
TEST_INSCMD=0
################################################### SETTING END

################################################### INITIALIZE START
# Rootディレクトリ
DIR_ROOT=$(cd $(dirname $0); pwd)

# インストール用関数 ロード
source $DIR_ROOT/setup/setup-funcs.sh

# 起動引数設定
DRYRUN=1
DRYRUNCMD=""
INSTAPP=""
# ${@:3}
if [ $# -eq 2 ] && [ "$1" = "exec" ]; then
    DRYRUN=0
    INSTAPP=$2
elif [ "$1" = "exec" ]; then
    DRYRUN=0
elif [ $# -eq 1 ]; then
    # 引数1、ダミー実行
    INSTAPP=$1
fi
################################################### INITIALIZE END

# セットアップ開始
setup
