#!/bin/bash

install() {
    if [ "$OS" = "ubuntu" ]; then
        # build tool のインストール
        dvexec "$instcmd build-essential"
        # https://gist.github.com/raimon49/9d45d480a607fb463ffe
        # 日本語用
        dvexec "$instcmd libncursesw5-dev"

        # ソースコード取得
        workdir="$script_dir/tmp"
        if [ ! -e $workdir ]; then
            dvexec "mkdir -p \"$workdir\""
        fi
        dvexec "cd \"$workdir\""
        if [ ! -e "$script_dir/tmp/tig" ]; then
            dvexec git clone https://github.com/jonas/tig.git
        fi
        dvexec "cd tig"
        dvexec git checkout tig-2.1

        # ビルド, インストール
        dvexec sudo LDLIBS=-lncursesw CFLAGS=-I/usr/include/ncursesw make install prefix=/usr/local
        dvexec rehash
        dvexec /usr/local/bin/tig -v
    elif [ "$OS" = "redhat" ]; then
        targetrpm="rpmforge-release-0.5.2-2.el6.rf.x86_64"
        result=`rpm -qa |grep $targetrpm`
        if [ "$result" = "" ]; then
            cmd="sudo rpm -ivh http://pkgs.repoforge.org/rpmforge-release/${targetrpm}.rpm"
            dvexec "$cmd"
        fi
        dvexec $def_instcmd
    else
        dvexec $def_instcmd
    fi
}

setconfig() {
    make_link_dot2home $script_dir
}
