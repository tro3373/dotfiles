#!/bin/bash

install() {
    url=https://github.com/ggreer/the_silver_searcher.git
    if is_mac; then
        dvexec "$instcmd ag"
    elif is_ubuntu; then
        dvexec "$instcmd silversearcher-ag"
    elif is_cygwin; then
        # 必要パッケージインストール
        dvexec "$instcmd autoconf automake gcc-g++ gettext gettext-devel liblzma-devel make mingw-gcc-g++ mingw-zlib-devel pkg-config xz zlib-devel"
        workdir="$app_dir/tmp"
        if [ ! -e $workdir ]; then
            dvexec "mkdir -p \"$workdir\""
        fi
        dvexec "cd \"$workdir\""
        dvexec git clone $url
        dvexec cd the_silver_searcher/
        dvexec aclocal && autoconf && autoheader && automake --add-missing
        dvexec ./configure
        dvexec make
        dvexec make install
    elif is_msys; then
        local type=package # build/zip/package
        if [ "$type" = "package" ]; then
            dvexec "$instcmd mingw-w64-x86_64-ag"
            return 0
        fi
        workdir="$app_dir/tmp"
        if [ ! -e $workdir ]; then
            dvexec "mkdir -p \"$workdir\""
        fi
        dvexec "cd \"$workdir\""
        if [ "$type" = "zip" ]; then
            if [ ! -e $workdir/ag.zip ]; then
                dvexec wget https://kjkpub.s3.amazonaws.com/software/the_silver_searcher/rel/0.29.1-1641/ag.zip
            fi
            dvexec unzip ag.zip
            dvexec mv ag/ag.exe $HOME/bin
            dvexec "cd -"
            return 0
        fi
        # for build
        dvexec $instcmd base-devel mingw-w64-x86_64-gcc mingw-w64-x86_64-pcre mingw-w64-x86_64-xz
        if [ ! -e the_silver_searcher/.git ]; then
            dvexec git clone $url
        fi
        dvexec cd the_silver_searcher/
        dvexec ./build.sh PCRE_CFLAGS=-DPCRE_STATIC LDFLAGS=-static
        dvexec strip ag.exe
    else
        :
        #cmd="sudo rpm -ivh http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm"
        #dvexec "$cmd"
    fi
}

setconfig() {
    make_link_dot2home $app_dir
}

