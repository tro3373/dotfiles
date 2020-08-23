#!/bin/bash

script_path=$(cd $(dirname $0); pwd)
source $script_path/smb4_common.sh
target=$(basename $0 .sh).ldif

check_sam
load_credential

sudo /usr/local/samba/bin/ldbmodify --url=/usr/local/samba/private/sam.ldb -b dc=$DC_1, dc=$DC_2 $target

