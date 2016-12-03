#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
dry_run=0
# インストール用関数 ロード
source $DOTPATH/setup/setup_funcs.sh

make_link_bkupable "$script_dir/.atom" "$WINHOME/.atom"
