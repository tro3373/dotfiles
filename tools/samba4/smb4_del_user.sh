#!/bin/bash

samba_tool=/usr/local/samba/bin/samba-tool
if [[ ! -e $samba_tool ]]; then
    echo "No samba-tool exist"
    exit 1
fi

user_name="$1"
while [[ "$user_name" = "" ]]; do
    echo "Input user_name for Delete..."
    echo
    sudo $samba_tool user list
    echo
    read user_name
done
sudo $samba_tool user delete $user_name
