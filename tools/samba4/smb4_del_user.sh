#!/bin/bash

SERVER_SHARE_ROOT=/data/share/Users
samba_tool=/usr/local/samba/bin/samba-tool
if [[ ! -e $samba_tool ]]; then
    echo "No samba-tool exist" 1>&2
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

if ! `id ${user_name} > /dev/null 2>&1`; then
    echo "No user exist ${user_name}" 1>&2
    exit 1
fi

del_home=$2
if [[ -e /home/${user_name} ]]; then
    # /home にユーザが存在する場合のみ削除コマンドを発行する.
    while [[ ! "$del_home" =~ ^[0-1]$  ]]; do
        echo "Delete home directory? /home/$user_name (y/N)"
        read read_del_home
        if [[ "$read_del_home" =~ ^[yY]$ ]]; then
            del_home=1
        elif [[ "$read_del_home" = "" || "$read_del_home" =~ ^[nN]$ ]]; then
            del_home=0
        fi
    done
    if [[ $del_home -eq 1 ]]; then
        sudo rm -rf /home/$user_name
    fi
fi

del_share=$3
share_path=$SERVER_SHARE_ROOT/${user_name:-HOGEHOGEHOGE}
if [[ -e ${share_path} ]]; then
    # /data/share/Users にユーザ用ディレクトリが存在する場合のみ削除コマンドを発行する.
    while [[ ! "$del_share" =~ ^[0-1]$  ]]; do
        echo "Delete server share directory? $share_path (y/N)"
        read read_del_share
        if [[ "$read_del_share" =~ ^[yY]$ ]]; then
            del_share=1
        elif [[ "$read_del_share" = "" || "$read_del_share" =~ ^[nN]$ ]]; then
            del_share=0
        fi
    done
    if [[ $del_share -eq 1 ]]; then
        sudo rm -rf $share_path
    fi
fi

sudo userdel -r $user_name
sudo $samba_tool user delete $user_name

