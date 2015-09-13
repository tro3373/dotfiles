#!/bin/bash

install() {
    log "  TODO >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    log "    Install Sumblime from [http://www.sublimetext.com/3]"
    log "  TODO >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    if [ "$OS" = "ubuntu" ]; then
        # ibus-mozc emacs-moxc のインストール
        dvexec "$instcmd ibus-mozc emacs-mozc"
    fi
}

setconfig() {
    if [ "$OS" = "mac" ]; then
        SUBLIMEUSERDIR=~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
        make_link_bkupable "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "/usr/local/bin/subl"
    else
        SUBLIMEUSERDIR=~/.config/sublime-text-3/Packages/User
    fi
    if [ -e $SUBLIMEUSERDIR ]; then
        make_link_bkupable "$script_dir/User" "$SUBLIMEUSERDIR"
    fi
    log "  TODO >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    log "    And exec Below on Sublime text3 GUI"
    log '      1. Ctrol + `'
    log '      2. copy paste from url https://packagecontrol.io/installation#st3'
    log "  TODO >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}
