#!/bin/bash

setconfig() {
    ssh_inner=$script_dir/.ssh
    ssh_outer=${HOME}/.ssh
    if [ -L "${ssh_outer}" ]; then
        # lnk の場合はなにもしない.
        dlog "  ==> already .ssh linked."
    elif [ -d "${ssh_outer}" ]; then
        # ~/.ssh が既に存在した場合
        if [ -e "${ssh_inner}" ]; then
            # script_dir にも .ssh が存在した場合、退避
            dvexec mv ${ssh_inner} ${script_dir}/.ssh_bkup
        fi
        # ディレクトリ退避
        dvexec mv $ssh_outer $ssh_inner
        # dotfiles 内部へリンクを貼る
        dvexec ln -s $ssh_inner $ssh_outer
    else
        dvexec mkdir $ssh_inner
        dvexec ln -s $ssh_inner $ssh_outer
    fi
    make_link_bkupable $script_dir/.exchange.key ~/.exchange.key
}
