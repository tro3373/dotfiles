#!/bin/bash

script_path=$(cd $(dirname $0); pwd)
source $script_path/smb4_common.sh

check_samba
check_wbinfo
user_name="$1"
intaractive_set_user_name

# 指定ユーザ情報を表示する
sudo /usr/local/samba/bin/wbinfo -n $user_name

