#!/bin/bash

setconfig() {
    make_link_dot2home $script_dir
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
        log "    ForwardX11 yes"
        log "    ForwardX11Trusted yes"
        log "  Host [server2]"
        log "    HostName [ipaddress]"
        log "    Port 22"
        log "    User [username]"
        log "    ForwardX11 yes"
        log "    ForwardX11Trusted yes"
        log "  ---------------------"
    fi
}
