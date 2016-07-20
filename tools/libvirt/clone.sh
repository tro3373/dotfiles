#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
source $script_dir/comm_load_create_setting.sh

main() {
    while [[ "" == "$new_domain" ]]; do
        echo "Input clone new domain name."
        read new_domain
        if [[ "" == "$new_domain" ]]; then
            continue
        fi
        while [[ "" == "$answer" ]]; do
            echo "New Domain name is \"$new_domain\". Are you ready?(Y/n)"
            read answer
            if [[ "$answer" =~ [nN] ]]; then
                domain=
                answer=
                break
            fi
        done
    done
    sudo virt-clone --original $domain_name --name $new_domain --file $images_dir/$new_domain.qcow2
}
main
