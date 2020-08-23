#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
main() {
    /msys2.exe bash -c "$script_dir/build.sh"
}
main $*
