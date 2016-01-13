#!/bin/bash

script_path=$(cd $(dirname $0); pwd)
source $script_path/smb4_common.sh

check_samba
check_ldbedit
check_sam

# idmap.ldb 情報を編集する
sudo /usr/local/samba/bin/ldbedit -e vim -H /usr/local/samba/private/sam.ldb

