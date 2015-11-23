#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
# インストール用関数 ロード
DRYRUN=0
source ~/dotfiles/setup/setup-funcs.sh

if [ "$OS" = "mac" ]; then
    SUBLIMEUSERDIR=~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
    make_link_bkupable "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "/usr/local/bin/subl"
else
    SUBLIMEUSERDIR=~/.config/sublime-text-3/Packages/User
fi
if [ -e $SUBLIMEUSERDIR ]; then
    make_link_bkupable "$script_dir/User" "$SUBLIMEUSERDIR"
fi

