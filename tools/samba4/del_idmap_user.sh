#!/bin/bash

wbinfo=/usr/local/samba/bin/wbinfo
ldbdel=/usr/local/samba/bin/ldbdel
idmap=/usr/local/samba/private/idmap.ldb

user_id=$1
while [[ "$user_id" == "" ]]; do
    echo "Input user_id..."
    read user_id
done

sid=$($wbinfo -n $user_id | awk '{print $1}')

# Delete idmap
echo "==> Deleting idmap db for user_id=$user_id, sid=$sid ..."
sudo $ldbdel --url=$idmap CN=$sid

