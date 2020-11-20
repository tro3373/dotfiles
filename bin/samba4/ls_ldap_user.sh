#!/bin/bash

script_path=$(
  cd $(dirname $0)
  pwd
)
source $script_path/smb4_common.sh

check_ldapsearch
load_credential
user_name="$1"
intaractive_set_user_name

# 指定クエリで取得できるLDAPユーザ情報を表示する
sudo ldapsearch -H ldap://$HOST -x -LLL -D "cn=$ADMIN_CN,cn=Users,dc=$DC_1,dc=$DC_2" -W -b "cn=$user_name,cn=Users,dc=$DC_1,dc=$DC_2"
