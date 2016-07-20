#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
domain_setting_file=$script_dir/.domain
images_dir=/var/lib/libvirt/images
xmls_dir=/etc/libvirt/qemu
list_files() {
    sudo sh -c "ls -lF $xmls_dir/*.xml"
    sudo sh -c "ls -lF $images_dir/*"
}
create_domain_setting() {
    while [[ "" == "$domain" ]]; do
        echo "Input target domain name"
        read domain
        if [[ "" == "$domain" ]]; then
            continue
        fi
        while [[ "" == "$answer" ]]; do
            echo "Domain name is \"$domain\". Are you ready?(Y/n)"
            read answer
            if [[ "$answer" =~ [nN] ]]; then
                domain=
                answer=
                break
            fi
        done
    done
    echo "domain_name=$domain" > $domain_setting_file
    echo "domain_xml=$xmls_dir/${domain}.xml" >> $domain_setting_file
    echo "domain_image=$images_dir/${domain}.qcow2" >> $domain_setting_file
    echo "Domain name $domain setting file created. $domain_setting_file"
}

detect_domain() {
    if [[ ! -f $domain_setting_file ]]; then
        create_domain_setting
    fi
    source $domain_setting_file
}

detect_domain
