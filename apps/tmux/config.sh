#!/bin/bash

install() {
#    workdir="$script_dir/tmp"
#    if [ ! -e $workdir ]; then
#        dvexec "mkdir -p \"$workdir\""
#    fi
#    dvexec "cd \"$workdir\""
    if [ "$DETECT_OS" = "ubuntu" ]; then
        # for tmux from git
        dvexec sudo apt-get install -y autoconf libtool pkg-config libevent-dev autotools-dev automake build-essential libncurses5-dev 
        install_common
    elif [ "$DETECT_OS" = "redhat" ]; then
        # for tmux from git
        dvexec sudo yum install -y libevent libeventdevel automake ncursesdevel
        install_common
    else
        dvexec "$instcmd tmux"
    fi
}

install_common() {
    dvexec cd /usr/local/src
    if [[ ! -e tmux/ ]]; then
        dvexec sudo git clone https://github.com/tmux/tmux.git
    fi
    dvexec cd tmux
    dvexec sudo ./autogen.sh
    dvexec sudo ./configure --prefix=/usr/local
    dvexec sudo make
    dvexec sudo make install
}

setconfig() {
    make_link_dot2home $script_dir
}

