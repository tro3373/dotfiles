#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
source $script_dir/comm_load_create_setting.sh

main() {
    sudo qemu-img snapshot -l $domain_image
}
main
