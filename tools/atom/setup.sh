#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
dry_run=0
# インストール用関数 ロード
source $DOTPATH/lib/setup_funcs.sh
initialize

if [ "$DETECT_OS" = "msys" ]; then
    make_link_bkupable "$script_dir/.atom" "$WINHOME/.atom"
else
    make_link_bkupable "$script_dir/.atom" "$HOME/.atom"
fi
