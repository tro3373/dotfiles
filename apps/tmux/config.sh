#!/bin/bash

install() {
    workdir="$script_dir/tmp"
    if [ ! -e $workdir ]; then
        dvexec "mkdir -p \"$workdir\""
    fi
    dvexec "cd \"$workdir\""
    if [ "$OS" = "ubuntu" ]; then
        myinstcmd="curl -fsSL https://gist.github.com/shime/5706655/raw/install.sh | sudo bash -e"
        dvexec $myinstcmd
    elif [ "$OS" = "redhat" ]; then
        dvexec "$instcmd gcc make ncurses ncurses-devel"

        dvexec "wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz"
        dvexec "tar xvzf libevent-2.0.21-stable.tar.gz"
        dvexec "cd libevent-2.0.21-stable"
        dvexec "./configure"
        dvexec "make"
        dvexec "sudo make install"
        dvexec "sudo echo \"/usr/local/lib\" > /etc/ld.so.conf.d/libevent.conf"
        dvexec "sudo ldconfig"
        dvexec "cd ../"
        dvexec "wget http://downloads.sourceforge.net/tmux/tmux-1.9a.tar.gz"
        dvexec "tar xvzf tmux-1.9a.tar.gz"
        dvexec "cd tmux-1.9a"
        dvexec "./configure"
        dvexec "make"
        dvexec "sudo make install"
   else
        dvexec "$instcmd tmux"
    fi
}

setconfig() {
    make_link_dot2home $script_dir
}

