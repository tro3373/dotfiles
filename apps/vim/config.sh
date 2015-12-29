#!/bin/bash

install() {
    if [ "$OS" = "ubuntu" ]; then
        dvexec "$instcmd --force-yes vim vim-gtk vim-athena vim-gnome"
    else
        dvexec $def_instcmd
    fi
}


setconfig() {
    make_link_dot2home $script_dir
#    vimbundle="$script_dir/.vim/bundle"
#    if [ ! -e "$vimbundle/neobundle.vim" ]; then
#        dvexec "cd \"$vimbundle\""
#        dvexec git clone git://github.com/Shougo/neobundle.vim
#    fi
#    log "  => Execute ':NeoBundleInstall' command in vim."
}
