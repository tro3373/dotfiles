#!/bin/bash

script_path=$(
  cd $(dirname $0)
  pwd
)
source $script_path/smb4_common.sh

check_ldappasswd
load_credential
user_name="$1"
intaractive_set_user_name

# 指定ユーザのパスワードを変更する
# プロンプトが立ち上がる
sudo ldappasswd -H ldap://$HOST -x -D "cn=$ADMIN_CN,cn=Users,dc=$DC_1,dc=$DC_2" -W -S "cn=$user_name,cn=Users,dc=$DC_1,dc=$DC_2"
