#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
dry_run=0
# インストール用関数 ロード
source ~/dotfiles/setup/setup-funcs.sh
make_link_dot2home $script_dir
