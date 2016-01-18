#!/bin/bash

#==================================================
samba=/usr/local/samba
samba_tool=$samba/bin/samba-tool
ldbmodify=$samba/bin/ldbmodify
net=$samba/bin/net
dc1=hoge
dc2=local
#==================================================

group_name="$1"
display_name="$2"
description="$3"
gid_number="$4"


check_group_name() {
    local group_name="$1"
    IFS=$'\n'
    # samba4 既存チェック
    for s4g in `wbinfo -g`; do
        s4gm=$(echo $s4g|grep -wxci "$group_name")
        if [ $s4gm -ne 0 ]; then
            echo "already registered(samba4): $group_name"
            exit 1
        fi
    done
    # /etc/group 既存チェック
    for hostg in `cat /etc/group|cut -d":" -f1`; do
        hostg_m=$(echo $hostg|grep -wxci "$group_name")
        if [ $hostg_m -ne 0 ]; then
            echo "already registered(host): $group_name"
            exit 1
        fi
    done
}

add_samba_group() {
    local group_name="$1"
    echo "Creating s4 posix group "$group_name
    sudo $samba_tool group add "$group_name"
    if [ $? -ne 0 ]; then
       echo "error";
       exit 1
    fi
}

main() {
    while [[ "$group_name" = "" ]]; do
        echo "Input group_name for create..."
        read group_name
    done

    echo "===> add group info."
    echo "  GroupName      : $group_name"
    echo "  Add Group Name : $display_name"
    echo "  Description    : $description"

    # check add group
    check_group_name "$group_name"

    set -eu
    # samba4に登録
    add_samba_group "$group_name"

    # posixGroupの追加とxidNumberをgidnumberにするldifファイルを作成
    ldif=/tmp/"$group_name"
    strgid=$(wbinfo --group-info="$group_name")
    gid=$(echo $strgid | cut -d ":" -f 3)
    cat << EOT > $ldif
dn: cn=$group_name,cn=Users,dc=$dc1,dc=$dc2
changetype: modify
add:objectclass
objectclass: posixGroup
-
add: gidnumber
gidnumber: $gid
EOT

    if [[ ! -z ${display_name} ]]; then
        cat << EOT >> $ldif
-
add: displayname
displayname: ${display_name:- }
EOT
    fi

    if [[ ! -z ${description} ]]; then
        cat << EOT >> $ldif
-
add: description
description: ${description:- }
EOT
    fi

    sudo $ldbmodify --url=$samba/private/sam.ldb -b dc=$dc1,dc=$dc2 $ldif
    if [[ $? -ne 0 ]]; then
        echo "Failed to modify sam.ldb group $grou_name" 1>2&
        exit 1
    fi
    # gid_number 指定なし時は処理なし(Posix group化なし)
    [[ -z $gid_number ]] && exit 0

    sid=$(wbinfo --name-to-sid="$group_name")
    gsid=$(echo "$sid" | cut -d " " -f1)

    cat << EOT > $ldif
dn: cn=$gsid
changetype: modify
replace: xidNumber
xidNumber: $gid_number
EOT
    echo "sleeping 2..."
    sleep 2
    sudo $ldbmodify --url=$samba/private/idmap.ldb $ldif
    if [[ $? -ne 0 ]]; then
        echo "Failed to modify idmap.ldb group" 1>2&
        exit 1
    fi
    cat << EOT > $ldif
dn: cn=$group_name,cn=Users,dc=$dc1,dc=$dc2
changetype: modify
replace: gidNumber
gidNumber: $gid_number
EOT
    echo "sleeping 2..."
    sleep 2
    sudo $ldbmodify --url=$samba/private/sam.ldb $ldif
    if [[ $? -ne 0 ]]; then
        echo "Failed to modify sam.ldb group" 1>2&
        exit 1
    fi
    rm $ldif
    echo "$group_name changed from gid $gsid to $gid_number"
    echo "cache clear!"
    sudo $net cache flush
}
main
