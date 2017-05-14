#!/usr/bin/env bash

current_dir=$(pwd)
script_dir=$(cd $(dirname $0); pwd)

# http://qiita.com/neknote/items/e1b6b1c96f138c2823ed?utm_source=Qiita%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9&utm_campaign=11ae3ee6bd-Qiita_newsletter_259_10_05_2017&utm_medium=email&utm_term=0_e44feaa081-11ae3ee6bd-32822417
# Like mac Spotlight
albert() {
    sudo add-apt-repository -y ppa:nilarimogard/webupd8
    sudo apt-get update
    sudo apt-get install -y albert
    # needs startup setting
}

# Like mac Doc
plank() {
    sudo apt install -y plank
    # needs startup setting
}

# material theme
flat_plat() {
    cd /tmp
    curl -sL https://github.com/nana-4/Flat-Plat/archive/v20170323.tar.gz | tar xz
    cd Flat-Plat-20170323 && sudo ./install.sh
}

# material icons
papirus() {
    sudo add-apt-repository ppa:papirus/papirus -y
    sudo apt-get update
    sudo apt-get install papirus-icon-theme -y
}
main() {
    :
}

main "$@"

