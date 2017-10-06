#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
dry_run=0

# インストール用関数 ロード
source $DOTPATH/lib/funcs
initialize

if is_mac; then
    SUBLIMEUSERDIR=~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
    make_link_bkupable "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "/usr/local/bin/subl"
elif is_msys; then
    SUBLIMEUSERDIR=$WINHOME/AppData/Roaming/Sublime\ Text\ 3/Packages/User
else
    SUBLIMEUSERDIR=~/.config/sublime-text-3/Packages/User
fi
make_link_bkupable "$script_dir/User" "$SUBLIMEUSERDIR"

