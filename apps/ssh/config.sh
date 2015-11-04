#!/bin/bash

setconfig() {
    ssh_inner=$script_dir/.ssh
    ssh_outer=${HOME}/.ssh
    if [ -L "${ssh_outer}" ]; then
        # lnk の場合はなにもしない.
        log "  ==> already .ssh linked."
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
    fi
    if [ ! -e "${HOME}/.ssh/config" ]; then
        log "#================================================================"
        log "# SSH conf Setting(For Tmux) Sample"
        log "#================================================================"
        log "  Create file ~/.ssh/conf"
        log "  ---------------------"
        log "  Host [server1] [server2]"
        log "    IdentityFile /path/to/your/identity/file"
        log "    ServerAliveInterval 30"
        log "    PermitLocalCommand  yes"
        log "    LocalCommand tmux rename-window %n"
        log "    ForwardX11 yes"
        log "    ForwardX11Trusted yes"
        log "  Host [server1]"
        log "    HostName [ipaddress]"
        log "    Port 22"
        log "    User [username]"
        log "  Host [server2]"
        log "    HostName [ipaddress]"
        log "    Port 22"
        log "    User [username]"
        log "  ---------------------"
    fi
}
