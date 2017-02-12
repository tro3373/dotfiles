#!/bin/bash

main() {
    # @see http://sicklylife.hatenablog.com/entry/2017/02/06/211159
    # For Japanize zip file Under ubuntu 16.04
    wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
    wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -
    sudo wget https://www.ubuntulinux.jp/sources.list.d/xenial.list -O /etc/apt/sources.list.d/ubuntu-ja.list
    sudo apt update
    sudo apt upgrade
    sudo apt install ubuntu-defaults-ja p7zip-full
    sudo add-apt-repository ppa:sicklylife/ppa
    sudo apt update
    sudo apt upgrade
}
main $*
