#!/bin/bash

install() {
    if [ "$OS" = "mac" ]; then
        dvexec "$instcmd ag"
    elif [ "$OS" = "ubuntu" ]; then
        dvexec "$instcmd silversearcher-ag"
    elif [ "$OSTYPE" = "cygwin" ]; then
        # 必要パッケージインストール
        dvexec "$instcmd autoconf automake gcc-g++ gettext gettext-devel liblzma-devel make mingw-gcc-g++ mingw-zlib-devel pkg-config xz zlib-devel"
        clone_src_cd
        dvexec aclocal && autoconf && autoheader && automake --add-missing
        dvexec ./configure
        dvexec make
        dvexec make install
    elif [ "$OS" = "mingw" ]; then
        # 必要パッケージインストール
        # dvexec "$instcmd base-devel mingw-w64-{i686,x86_64}-gcc mingw-w64-{i686,x86_64}-pcre mingw-w64-{i686,x86_64}-xz"
        # clone_src_cd
        # dvexec ./build.sh PCRE_CFLAGS=-DPCRE_STATIC LDFLAGS=-static
        # dvexec strip ag.exe
        :
        # だめならこれを試すべし
        # http://proglab.blog.fc2.com/blog-entry-9.html
    else
        :
        #cmd="sudo rpm -ivh http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm"
        #dvexec "$cmd"
    fi
}

clone_src_cd() {
    # ソースコード取得
    workdir="$script_dir/tmp"
    if [ ! -e $workdir ]; then
        dvexec "mkdir -p \"$workdir\""
    fi
    dvexec "cd \"$workdir\""
    if [ ! -e "$workdir/the_silver_searcher" ]; then
        dvexec git clone https://github.com/ggreer/the_silver_searcher.git
    fi
    dvexec cd the_silver_searcher/
}

setconfig() {
    make_link_dot2home $script_dir
}
