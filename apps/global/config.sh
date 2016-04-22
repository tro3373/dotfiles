#!/bin/bash

install() {
    if [ "$DETECT_OS" = "mac" ]; then
        dvexec brew install global --with-exuberant-ctags --with-pygments
    elif [ "$DETECT_OS" = "ubuntu" ]; then
        dvexec "$instcmd python-pip exuberant-ctags ncurses-dev"
        dvexec sudo pip install Pygments
        download_global_src_and_build
        dvexec cp -f /usr/local/share/gtags/gtags.conf ~/.globalrc
        dvexec "sed -ri -e 's/^(\t:tc=native:)/\1tc=pygments:/g' ~/.globalrc"
    elif [ "$DETECT_OS" = "cygwin" ]; then
        dvexec $def_instcmd
    elif [ "$DETECT_OS" = "msys" ]; then
        dvexec $def_instcmd
    else
        dvexec $def_instcmd
    fi
}

get_global_src_url() {
    local dlpage="https://www.gnu.org/software/global/download.html"
    local url="`curl -s $dlpage | grep -E "global-.+\.tar\.gz" | awk -F"'" '{print $2}'`"
    echo $url
}

download_global_src_and_build() {
    # http://qiita.com/yoshizow/items/9cc0236ac0249e0638ff
    # ソースコード取得
    workdir="$script_dir/tmp"
    if [[ ! -e $workdir ]]; then
        dvexec "mkdir -p \"$workdir\""
    fi
    dvexec "cd \"$workdir\""
    if [[ ! -e "$workdir/global.tar.gz" ]]; then
        local dlurl=$(get_global_src_url)
        dvexec curl -sS -o global.tar.gz $dlurl
    fi
    if [[ ! -e "$workdir/global" ]]; then
        dvexec mkdir -p $workdir/global
        dvexec tar xvfpz $workdir/global.tar.gz -C $workdir/global
    fi
    dvexec cd $workdir/global/global*
    dvexec ./configure --prefix=/usr/local
    dvexec make
    dvexec sudo make install
}

setconfig() {
    :
}
