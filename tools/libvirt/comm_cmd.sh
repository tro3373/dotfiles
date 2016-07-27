#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
source $script_dir/comm_load_create_setting.sh

main() {
    local cmd=$(basename ${1%.*})
    if [[ ! "" == "$2" ]]; then
        while [[ "" == "$answer" ]]; do
            echo "Executing cmd=$cmd domain=$domain_name Are you ready?(y/N)"
            read answer
            if [[ ! "$answer" =~ [yY] ]]; then
                echo "Command canceled." 1>&2
                exit 1
            fi
        done
    fi
    sudo virsh $cmd $domain_name
}
main $*
