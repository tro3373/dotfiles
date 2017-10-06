#!/bin/bash

install() {
    if is_msys; then
        dvexec mkdir -p $app_dir/tmp
        dvexec cd $app_dir/tmp
        version=2.1.4
        dvexec wget https://osdn.jp/projects/nkf/downloads/64158/nkf-${version}.tar.gz
        dvexec tar zxvf nkf-${version}.tar.gz
        dvexec cd nkf-${version}
        dvexec make
        dvexec mkdir -p /usr/local/bin
        dvexec make install
    else
        dvexec $def_instcmd
    fi
}

setconfig() {
    :
}
