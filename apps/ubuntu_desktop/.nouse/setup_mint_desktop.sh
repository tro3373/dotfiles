#!/bin/bash

set -eu

script_dir=$(cd $(dirname $0); pwd)

# Cpas Lock => Ctrl setting
#if [ type dconf > /dev/null 2>&1 ]; then
#    dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:nocaps']"
#    #dconf reset /org/gnome/desktop/input-sources/xkb-options
#fi

install_gnome_terminal_solarized() {
    work_dir="$script_dir/tmp"
    if [ ! -e $work_dir ]; then
        mkdir -p $work_dir
    fi
    cd $work_dir
    git git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git
    cd gnome-terminal-colors-solarized
    ./install.sh
    cd -
}
install_gnome_terminal_solarized

