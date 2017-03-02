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

update_build_package() {
    pacman -S patch
    pacman -S mingw-w64-x86_64-toolchain
    pacman -S make gcc git
}

front() {
    cd ./wslbridge/frontend
    # update_build_package
    make

    # mintty_winpath=$(cygpath -aw $(which mintty))
    mintty_winpath=$(cygpath -aw $(dirname $(which mintty)))
    winbin=$(cygpath -aw $WINHOME/bin)
    cp ../out/wslbridge.exe $winbin
    cat <<EOL>$winbin/wsl.bat
@echo off
cd $mintty_winpath
mintty.exe -t "Bash on Ubuntu on Windows" -e $winbin\wslbridge.exe
EOL
    # echo "@echo off" > $winbin/wsl.bat
    # # echo "$mintty_winpath -t \"Bash on Ubuntu on Windows\" -e $winbin\\wslbridge.exe" >> $winbin/wsl.bat
    # echo "cd $mintty_winpath"
    # echo "mintty -t \"Bash on Ubuntu on Windows\" -e $winbin\\wslbridge.exe" >> $winbin/wsl.bat
    unix2dos $winbin/wsl.bat
}

back() {
    cd ./wslbridge/backend
    make
    winbin=/mnt/c/Users/`whoami`/bin
    cp ../out/wslbridge-backend $winbin
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
