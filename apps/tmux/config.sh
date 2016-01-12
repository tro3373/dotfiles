#!/bin/bash

install() {
#    workdir="$script_dir/tmp"
#    if [ ! -e $workdir ]; then
#        dvexec "mkdir -p \"$workdir\""
#    fi
#    dvexec "cd \"$workdir\""
    if [ "$OS" = "ubuntu" ]; then
        # for tmux from git
        dvexec cd /usr/local/src
        dvexec sudo git clone https://github.com/tmux/tmux.git
        dvexec sudo apt-get install autoconf libtool pkg-config libevent-dev
        dvexec cd tmux
        dvexec sudo ./autogen.sh
        dvexec sudo ./configure --prefix=/usr/local
        dvexec sudo make
        dvexec sudo make install
    elif [ "$OS" = "redhat" ]; then
        # for tmux from git
        dvexec sudo yum install -y libevent libeventdevel automake ncursesdevel
        dvexec cd /usr/local/src
        dvexec sudo git clone https://github.com/tmux/tmux.git
        dvexec cd tmux
        dvexec sudo ./autogen.sh
        dvexec sudo ./configure --prefix=/usr/local
        dvexec sudo make
        dvexec sudo make install
    else
        dvexec "$instcmd tmux"
    fi
}

setconfig() {
    make_link_dot2home $script_dir
}

