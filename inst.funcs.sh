#!/bin/bash

# echo するのみ
log() {
    echo "$*"
}
logescape() {
    echo -e "$*"
}

# コマンド実行
# log メソッドを呼びつつ実行する
vexec() {
    cmd="$*"
    log " Exec: $cmd"
    eval $cmd
    log "    => ret=$?"
}

# コマンドダミー実行
# echoするのみ
dry_vexec() {
    cmd="$*"
    log " Dummy Exec(echo only): $cmd"
}

# コマンドがインストールされているかチェックする
testcmd() {
    cmd=`which $1`
    if [ -n "`echo "${cmd}" | grep 'not found'`" ]; then
        return 1
    elif [ "$cmd" = "" ]; then
        return 1
    else
        return 0
    fi
}

# $* が存在するかどうか判定する
isexist() {
    file="$*"
    count=`ls -a "$file" 2>/dev/null |wc -l|sed 's/ //g'`
    if [ "$count" == "0" ]; then
        # 存在しない場合は bash 内で false の意味を表す 1 を応答する.
        return 1
    fi
    # 存在する場合は bash 内で true の意味を表す 0 を応答する.
    return 0
}


# $1のファイルを$2へリンクを作成する
make_link() {
    from=$1
    to=$2
    dvexec "ln -s \"$from\" \"$to\""
}

# OSのディストリビューションを表示する
get_os_distribution() {
    if   [ -e /etc/debian_version ] ||
         [ -e /etc/debian_release ]; then
        # Check Ubuntu or Debian
        if [ -e /etc/lsb-release ]; then
            # Ubuntu
            distri_name="ubuntu"
        else
            # Debian
            distri_name="debian"
        fi
    elif [ -e /etc/fedora-release ]; then
        # Fedra
        distri_name="fedora"
    elif [ -e /etc/redhat-release ]; then
        # CentOS
        distri_name="redhat"
    elif [ -e /etc/turbolinux-release ]; then
        # Turbolinux
        distri_name="turbol"
    elif [ -e /etc/SuSE-release ]; then
        # SuSE Linux
        distri_name="suse"
    elif [ -e /etc/mandriva-release ]; then
        # Mandriva Linux
        distri_name="mandriva"
    elif [ -e /etc/vine-release ]; then
        # Vine Linux
        distri_name="vine"
    elif [ -e /etc/gentoo-release ]; then
        # Gentoo Linux
        distri_name="gentoo"
    elif [ `uname` = "Darwin" ]; then
        # mac
        distri_name="mac"
    else
        # Other
        distri_name="Unkown distribution"
    fi

    echo ${distri_name}
}
