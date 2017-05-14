#!/bin/bash

install() {
    if [ "$DETECT_OS" = "msys" ]; then
        dvexec echo "Nothing todo for ssh on msys"
    else
        dvexec $def_instcmd
    fi
}

setconfig() {
    # exchange.key setting
    make_link_bkupable $script_dir/.exchange.key ~/.exchange.key

    # .ssh directory setting
    # link .ssh not work
    # link_to_dot
    if [[ "$DETECT_OS" != "msys" ]]; then
        change_to_right_permission
    fi
}

change_to_right_permission() {
    local ssh_dir=${HOME}/.ssh
    if [ ! -e ${ssh_dir} ]; then
        # dvexec mkdir -p ${ssh_dir}
        echo "No .ssh directory exists."
        return 0
    fi
    if ! stat -c "%a %n" ${ssh_dir} | grep 755 >/dev/null 2>&1; then
        dvexec chmod 755 ${ssh_dir}
    fi

    local files=$(find ${ssh_dir}/ -type f)
    for file in $files; do
        if stat -c "%a %n" ${file} | grep -v 600 >/dev/null 2>&1; then
            dvexec chmod 600 ${file}
        fi
    done
}

link_to_dot() {
    ssh_inner=$script_dir/.ssh
    ssh_outer=${HOME}/.ssh

    if [ ! -e $ssh_inner ]; then
        dvexec mkdir -p $ssh_inner
        dvexec chmod 755 $ssh_inner
    fi

    local inner_count=$(ls $ssh_inner/ |wc -l)
    local outer_count=$(ls $ssh_outer/ |wc -l)
    if [ $inner_count -eq 0 ] && [ $outer_count -ne 0 ]; then
        dvexec mv $ssh_outer/* $ssh_inner/
    fi
    make_link_bkupable $ssh_inner $ssh_outer
}
