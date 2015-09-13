#!/bin/bash

install() {
    if [ "$OS" = "mac" ]; then
        dvexec sudo brew tap peco/peco
        dvexec sudo brew install peco
    else
        # peco 最新バージョンを取得
        peco_latest_version="`get_pecoltver`"
        log "  ===> Peco latest version=${peco_latest_version}"
        dlurl="https://github.com/peco/peco/releases/download/${peco_latest_version}/peco_linux_amd64.tar.gz"
        log "  ===> Donload from url=${dlurl}"

        workdir="$script_dir/tmp"
        if [ ! -e $workdir ]; then
            dvexec "mkdir -p \"$workdir\""
        fi
        dvexec "cd \"$workdir\""
        dvexec wget $dlurl
        if [ -e "$script_dir/tmp/peco_linux_amd64.tar.gz" ]; then
            dvexec tar xvfpz peco_linux_amd64.tar.gz
            installto=/usr/local/bin
            sudo="sudo"
            if [ "$OSTYPE" = "cygwin" ]; then
                sudo=""
            fi
            dvexec "$sudo cp peco_linux_amd64/peco $installto"
            log "  ===> peco installed to $installto"
        fi
    fi
}

# peco 最新バージョンを取得
get_pecoltver() {
    version="`curl -sI https://github.com/peco/peco/releases/latest | awk -F'/' '/^Location:/{print $NF}' |sed 's/\r//g'`"
    echo "$version"
}

setconfig() {
    if [ ! -e ${HOME}/.config/peco ]; then
        dvexec "mkdir -p \"${HOME}/.config/peco\""
    fi
    make_link_bkupable "${script_dir}/config.json" "${HOME}/.config/peco/config.json"
}
