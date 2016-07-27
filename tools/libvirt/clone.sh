#!/bin/bash

# Guest OS Cloning tool
# - Feture
#   - touch below file
#     - /etc/hosts
#     - /etc/hostname
#     - /etc/udev/rules.d/70-persistent-net.rules
# - !!!WARNING!!
# 1.Ubuntu Only
#   this code will work on ubuntu Only.
# 2.Domain name and Hostname
#   We assume always same host name and domain name.
#   No support for different name host/domain.
# 3.Static IP Address
#   We assume static ip address.
#

# Load common domain setting.
script_dir=$(cd $(dirname $0); pwd)

# constant variables
work_dir=$script_dir/tmp
images_dir=/var/lib/libvirt/images
src_domain=original

# start args variables
dst_domain=$1
dst_ip=$2

confirm() {
    local msg="$1"
    local answer=
    echo "$msg"
    read answer
    if [[ "$answer" =~ [yY] ]]; then
        return 0
    fi
    return 1
}

initialize() {
    set -eu
    # original guest 起動チェック
    if sudo virsh list | grep $src_domain > /dev/null 2>&1; then
        echo "!!!Warning!!! Guest $src_domain is running."
        if ! confirm "Are you ready?(y/n)"; then
            echo "Do nothing."
            exit 1
        fi
    fi
    # clean tmp dir
    if [ -e $work_dir ]; then
        echo " ==> Warning tmp($work_dir) exists. Deleting..."
        rm -rf $work_dir
    fi
    mkdir -p $work_dir
}

interactive() {
    local input_confirm=$1
    local variable=$2
    local msg="$3"
    local input_word= answer=
    while [[ "" == "$answer" ]]; do
        while [[ "$input_word" == "" ]]; do
            echo "$msg"
            read input_word
        done
        [ $input_confirm -ne 1 ] && break
        if confirm " \"$input_word\" is inputed. Are you ready?(y/n)"; then
            break
        fi
        input_word=
        answer=
    done
    eval "$variable=$input_word"
}

clone_guest() {
    while [[ "" == "$dst_domain" || "" == "$dst_ip" ]]; do
        # New Guest Hostname
        interactive 1 dst_domain "Input New Guest Domain Name(Hostname)"
        # New Guest IP Address
        interactive 1 dst_ip "Input New Guest IP Address"
        echo
        echo "New Guest Domain(Hostname) is $dst_domain"
        echo "New Guest IP Address is $dst_ip"
        echo
        if confirm "Are you ready?(y/n)"; then
            break
        fi
        dst_domain=
        dst_ip=
    done
#    sudo virt-clone --original $src_domain --name $dst_domain --file $images_dir/$dst_domain.qcow2
}

# common proc for virt-copy-in/virt-cat
mod_comm() {
    local domain path file dir
    domain=$1
    path="$2"
    sedcmd="$3"
    file=$(basename $path)
    dir=$(dirname $path)
    sudo virt-cat -d $domain $path > $work_dir/$file
    sudo sed -ie "$sedcmd" $work_dir/$file
#    sudo virt-copy-in -d $domain $work_dir/$file $dir
}

mod_hosts() {
    # !!!WARNING!!! We assume always same host name and domain name.
    mod_comm "$dst_domain" "/etc/hosts" "s/$src_domain/$dst_domain/g"
}

mod_hostname() {
    # !!!WARNING!!! We assume always same host name and domain name.
    sudo sh -c "echo $dst_domain > $work_dir/hostname"
#    sudo virt-copy-in -d $dst_domain $work_dir/hostname /etc/
}

mod_70persistent() {
    # !!!WARNING!!! We assume always same host name and domain name.
    src_mac=$(sudo virsh domiflist $src_domain |grep virbr0 |awk '{print $5}')
    dst_mac=$(sudo virsh domiflist $dst_domain |grep virbr0 |awk '{print $5}')
    mod_comm "$dst_domain" "/etc/udev/rules.d/70-persistent-net.rules" "s/$src_mac/$dst_mac/g"
}

mod_network() {
    # !!!WARNING!!! We assume Ubuntu and static ip address.
    mod_comm "$dst_domain" "/etc/network/interfaces" "s/address.*/address $dst_ip/g"
}

mod_guest() {
    mod_hosts
    mod_hostname
    mod_70persistent
    mod_network
}

main() {
    initialize
    clone_guest
    mod_guest
}
main

