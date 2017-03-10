#!/bin/bash

current_dir=$(pwd)
script_dir=$(cd $(dirname $0); pwd)

has() {
    which ${1} >/dev/null 2>&1
    return $?
}

main() {
    :
}
main $*
