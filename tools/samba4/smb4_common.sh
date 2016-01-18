#!/bin/bash

samba_tool=/usr/local/samba/bin/samba-tool
credential_file=~/.ldap_credential

check_samba_tool() {
    if [[ ! -e $samba_tool ]]; then
        echo "No samba-tool exist" 1>&2
        exit 1
    fi
}

check_ldapsearch() {
    if ! type ldapsearch > /dev/null 2>&1; then
        echo "No samba ldapsearch" 1>&2
        exit 1
    fi
}

check_ldappasswd() {
    if ! type ldappasswd > /dev/null 2>&1; then
        echo "No samba ldapsearch" 1>&2
        exit 1
    fi
}

check_samba() {
    if [[ ! -e /usr/local/samba ]]; then
        echo "No samba directory (/usr/local/samba)" 1>&2
        exit 1
    fi
}

check_wbinfo() {
    if [[ ! -e /usr/local/samba/bin/wbinfo ]]; then
        echo "No samba wbinfo" 1>&2
        exit 1
    fi
}

check_ldbedit() {
    if [[ ! -e /usr/local/samba/bin/ldbedit ]]; then
        echo "No samba ldbedit exist" 1>&2
        exit 1
    fi
}

check_idmap() {
    if [[ ! -e /usr/local/samba/private/idmap.ldb ]]; then
        echo "No samba idmap.ldb exist" 1>&2
        exit 1
    fi
}

check_sam() {
    if [[ ! -e /usr/local/samba/private/sam.ldb ]]; then
        echo "No samba sam.ldb exist" 1>&2
        exit 1
    fi
}

load_credential() {
    if [[ ! -e $credential_file ]]; then
        local script_path=$(cd $(dirname $0); pwd)
        $script_path/setup_ldap_credential.sh
    fi
    source $credential_file
}

intaractive_set_user_name() {
    check_samba_tool
    while [[ "$user_name" = "" ]]; do
        echo "==> Input user_name for dump..."
        echo
        sudo $samba_tool user list
        echo
        read user_name
    done
}

