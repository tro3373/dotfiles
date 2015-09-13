#!/bin/bash

install() {
    if [ "$OS" = "mac" ]; then
        dvexec "$instcmd ag"
    elif [ "$OS" = "ubuntu" ]; then
        dvexec "$instcmd silversearcher-ag"
    elif [ "$OSTYPE" = "cygwin" ]; then
        # 必要パッケージインストール
        dvexec "$instcmd autoconf automake gcc-g++ gettext gettext-devel liblzma-devel make mingw-gcc-g++ mingw-zlib-devel pkg-config xz zlib-devel"
        # ソースコード取得
        workdir="$script_dir/tmp"
        if [ ! -e $workdir ]; then
            dvexec "mkdir -p \"$workdir\""
        fi
        dvexec "cd \"$workdir\""
        if [ ! -e "$workdir/the_silver_searcher" ]; then
            dvexec git clone https://github.com/ggreer/the_silver_searcher.git
        fi
        dvexec "cd the_silver_searcher/"
        dvexec "aclocal && autoconf && autoheader && automake --add-missing"
        dvexec "./configure"
        dvexec "make"
        dvexec "make install"
    #else
        #cmd="sudo rpm -ivh http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm"
        #dvexec "$cmd"
    fi
}
