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
    # [ 0 -eq 0 ] && return

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
