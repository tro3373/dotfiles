#!/bin/bash
#==================================================
samba=/usr/local/samba
samba_tool=$samba/bin/samba-tool
ldbmodify=$samba/bin/ldbmodify
lib_add_user_to_group=./add_user_to_group.sh
wbinfo=$samba/bin/wbinfo
MAIL_DOMAIN=@hoge.jp
DEF_SHELL=/sbin/nologin
DC1=hoge
DC2=local
NIS_DOMAIN=$DC1
UID_START=10000
OPS1_NAME=1stOps
OPS2_NAME=2ndOps
OPS_3NAME=3rdOps
OPS1_GID=10000
OPS2_GID=10001
OPS3_GID=10002
BASE_GROUP=hogehoge
SERVER_SHARE_ROOT=/path/to/server/share
#===================================================

user_name="$1"
group_name=$2
display_name="$3"
description="$4"
uid_number=$5

is_exist_group() {
    $wbinfo --group-info="$1" > /dev/null 2>&1
    return $?
}

if [[ ! -e $samba_tool ]]; then
    echo "No samba-tool exist" 1>&2
    exit 1
fi

while [[ "$user_name" = "" ]]; do
    echo "Input user_name for create..."
    read user_name
done

while [[ "$group_name" == "" ]] || ! is_exist_group "$group_name"; do
    echo "Input primary group_name for user..."
    read group_name
done

echo "===> add user info."
echo "  Add User Name: $display_name"
echo "  UID          : $user_name"
echo "  group_name   : $group_name"
echo "  Description  : $description"

set -eu
get_uid_minimam() {
    cat /etc/login.defs |egrep "^UID_MIN" | awk '{print $2}'
}

get_uid_maximam() {
    cat /etc/login.defs |egrep "^UID_MAX" | awk '{print $2}'
}

get_recentry_uid() {
    local minimam_uid="`get_uid_minimam`"
    local maximam_uid="`get_uid_maximam`"
    local recentry_uid=$UID_START
    for value in `getent passwd | awk -F":" '{ print $3 }' | sort -nr`; do
        # getent passwd コマンドで取得できる 採番済UIDを降順ソート
        if [[ $value -lt $maximam_uid && $value -gt $minimam_uid ]]; then
            # /etc/login.defs の設定値（最大、最小UID）の範囲内で、
            # getent 結果内から検索し、一番はじめにみつかった、
            # 最大のUIDを検知した場合、そのUIDを最近UIDとして設定する
            recentry_uid=$value
            break
        fi
        if [[ $value -lt $UID_START ]]; then
            # uid 開始番号より下回る場合は、開始番号を設定
            break
        fi
    done
    echo $recentry_uid
}

get_next_uid() {
    echo $((`get_recentry_uid` + 1))
}

check_uid_exist() {
    local uid=$1
    if `wbinfo -i $uid > /dev/null 2>&1`; then
        echo "wbinfo exist." 1>&2
        return 1
    fi
    if [[ -e /home/$uid ]]; then
        echo "/home/$uid is exist." 1>&2
        return 1
    fi
    getent passwd |egrep "^$uid:.+$" > /dev/null 2>&1
    return $?
}

main() {
    local gid_number base_group
    gid_number=`$wbinfo --group-info="$group_name" | awk -F":" '{print $3}'`

    if check_uid_exist ${user_name}; then
        echo "${user_name} is already exist" &1>2
        exit 1
    fi

    # uid 採番
    if [[ -z $uid_number ]]; then
        uid_number=`get_next_uid`
    fi

    # user 作成
        # --given-name=Illyasviel --surname=Einzbern \
        # --gecos="${display_name:- }" \
        # --must-change-at-next-login \
    sudo $samba_tool user create ${user_name} ${user_name} \
        --use-username-as-cn \
        --mail-address=${user_name}${MAIL_DOMAIN} \
        --uid=${user_name} \
        --nis-domain=${NIS_DOMAIN} \
        --uid-number=${uid_number} \
        --gid-number=${gid_number} \
        --unix-home=/home/${user_name} \
        --login-shell=$DEF_SHELL

    echo "created user info... $(id $user_name)"
    # get the primarygroupid
    primarygid=$($wbinfo --gid-to-sid=$gid_number | cut -d "-" -f 8)
    # primarygroupid
    cat << EOT > /tmp/${user_name}
dn: cn=${user_name},cn=Users,dc=$DC1,dc=$DC2
changetype: modify
replace: primarygroupid
primarygroupid: $primarygid
EOT
    if [[ ! -z ${display_name} ]]; then
        cat << EOT >> /tmp/${user_name}
-
add: displayname
displayname: ${display_name:- }
EOT
    fi
    if [[ ! -z ${description} ]]; then
        cat << EOT >> /tmp/${user_name}
-
add: description
description: ${description:- }
EOT
    fi

    # 所属グループ登録
    $lib_add_user_to_group "${user_name}" "${group_name}"

    echo "Sleeping 5..."
    sleep 5
    # 所属プライマリグループ登録
    sudo $ldbmodify --url=$samba/private/sam.ldb -b dc=$DC1,dc=$DC2 /tmp/${user_name}
    if [ $? -ne 0 ]; then
        echo "Failed to modify primary groupid for $user_name" 1>2&
        exit 1
    fi
    rm /tmp/$user_name

    # 共有ディレクトリ作成
    share_path=$SERVER_SHARE_ROOT/${user_name}
    if [[ ! -e ${share_path} ]]; then
        # ディレクトリが存在しない場合は作成
        sudo mkdir -p ${share_path}
        sudo chmod 770 ${share_path}
        sudo chown ${user_name}:root ${share_path}
    fi
}

main
