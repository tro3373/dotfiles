#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
source $script_dir/comm_load_create_setting.sh

main() {
    local cmd=$(basename ${1%.*})
    echo sudo virsh $cmd $domain_name
}
main $1
