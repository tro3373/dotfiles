#!/bin/bash

url=https://github.com/rprichard/wslbridge.git
script_dir=$(cd $(dirname $0); pwd)
work_dir=$script_dir/tmp
clone_if_needed() {
    if [[ ! -e $work_dir ]]; then
        mkdir -p $work_dir
    fi
    cd $work_dir
    if [[ ! -e ./wslbridge ]]; then
        git clone $url
    fi
}
front() {
    cd ./wslbridge/frontend
    make

    mintty_winpath=$(cygpath -aw $(which mintty))
    winbin=$(cygpath -aw $WINHOME/bin)
    cp ../out/wslbridge.exe $winbin
    echo "$mintty_winpath -t \"Bash on Ubuntu on Windows\" -e ./wslbridge.exe" >> $winbin/wsl.bat
}

back() {
    cd ./wslbridge/backend
    make
}

main() {
    clone_if_needed
    cd $work_dir
    if [[ "$OSTYPE" == "msys" ]]; then
        echo "Building frontend ..."
        front
    else
        echo "Building backend ..."
        back
    fi
}
main $*
