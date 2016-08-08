#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)

main() {
    mkdir -p $script_dir/tmp
    cd $script_dir/tmp
    version=2.1.4
    wget https://osdn.jp/projects/nkf/downloads/64158/nkf-${version}.tar.gz
    tar zxvf nkf-${version}.tar.gz
    cd nkf-${version}
    make
    mkdir -p /usr/local/bin
    make install
}
main
