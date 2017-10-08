#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)

# インストール用関数 ロード
dry_run=0
source $DOTPATH/bin/lib/funcs

if is_msys; then
    make_link_bkupable "$script_dir/.atom" "$WINHOME/.atom"
else
    make_link_bkupable "$script_dir/.atom" "$HOME/.atom"
fi
