#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
main() {
    local msys64=${WINHOME:-/c/Users/$(whoami)}/AppData/Local/Msys64
    [ -e $msys64 ] && echo "Already msys64 exist at $msys64. do nothing." && exit 1
    local work_dir=$script_dir/tmp
    [ ! -e $work_dir ] && mkdir $work_dir
    cd $work_dir
    local target=msys2-x86_64-latest.tar.xz
    if [ ! -e $target ]; then
        echo "==> Downloading .."
        curl -fsSLO http://repo.msys2.org/distrib/$target
    fi
    if [ ! -e msys64 ]; then
        echo "==> Untaring .."
        tar Jxfv $target
    fi
    if [ ! -e $msys64 ]; then
        echo "==> Moving to $msys64 .."
        mv msys64 $msys64
    fi
    cd -
    echo "Done!"
}
main

