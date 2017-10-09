#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)

# インストール用関数 ロード
dry_run=0
source $DOTPATH/bin/lib/funcs

if is_mac; then
    SUBLIMEUSERDIR=~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
    make_lnk_with_bkup "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "/usr/local/bin/subl"
elif is_msys; then
    SUBLIMEUSERDIR=$WINHOME/AppData/Roaming/Sublime\ Text\ 3/Packages/User
else
    SUBLIMEUSERDIR=~/.config/sublime-text-3/Packages/User
fi
make_lnk_with_bkup "$script_dir/User" "$SUBLIMEUSERDIR"

