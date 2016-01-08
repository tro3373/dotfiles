#!/bin/bash
#==================================================
samba_tool=/usr/local/samba/bin/samba-tool
MAIL_DOMAIN=@hogehoge.jp
NIS_DOMAIN=hogehoge
UID_START=10000
OPS1_NAME=1st
OPS2_NAME=2nd
OPS_3NAME=3rd
OPS1_GID=10000
OPS2_GID=10001
OPS3_GID=10002
BASE_GROUP=base_group
#===================================================

user_name="$1"
ops=$2

if [[ ! -e $samba_tool ]]; then
    echo "No samba-tool exist" 1>&2
    exit 1
fi

while [[ "$user_name" = "" ]]; do
    echo "Input user_name for create..."
    read user_name
done
while [[ ! "$ops" =~ ^[1-3]$ ]]; do
    cat <<EOF
Input number:
    1: 1st
    2: 2nd
    3: 3rd
EOF
    read ops
done

echo "===> add user info."
echo "  Add User Name: $user_name"
echo "  Ops Number   : $ops"

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
    if [[ -e /home/$uid ]]; then
        echo "/home/$uid is exist."
        return 1
    fi
    getent passwd |egrep "^$uid:.+$" > /dev/null 2>&1
    return $?
}

main() {
    local ops_name gid_number base_group uid_number
    case $ops in
        1)
            ops_name=$OPS1_NAME
            gid_number=$OPS1_GID
            base_group=$BASE_GROUP
            ;;
        2)
            ops_name=$OPS2_NAME
            gid_number=$OPS2_GID
            base_group=$BASE_GROUP
            ;;
        3)
            ops_name=$OPS_3NAME
            gid_number=$OPS3_GID
            base_group=$BASE_GROUP
            ;;
        *)
            echo "Invalid ops specified. $opt" &1>2
            exit 1
            ;;
    esac

    if check_uid_exist ${user_name}; then
        echo "${user_name} is already exist" &1>2
        exit 1
    fi

    # uid 採番
    uid_number=`get_next_uid`

    # user 作成
    sudo ${samba_tool} user create ${user_name} ${user_name} \
        --must-change-at-next-login \
        --use-username-as-cn \
        --mail-address=${user_name}${MAIL_DOMAIN} \
        --uid=${user_name} \
        --nis-domain=${NIS_DOMAIN} \
        --uid-number=${uid_number} \
        --gid-number=${gid_number} \
        --unix-home=/home/${user_name} \
        --login-shell=/bin/bash

    # 所属グループ登録
    sudo ${samba_tool} group addmembers ${ops_name} ${user_name}
    if [[ $ops -ne 3 ]]; then
        sudo ${samba_tool} group addmembers ${base_group} ${user_name}
    fi
}

main
