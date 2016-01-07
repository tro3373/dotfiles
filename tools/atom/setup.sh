#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
# インストール用関数 ロード
dry_run=0
source ~/dotfiles/setup/setup-funcs.sh
make_link_dot2home $script_dir
