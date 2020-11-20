#!/bin/bash
#==================================================
samba=/usr/local/samba
samba_tool=$samba/bin/samba-tool
wbinfo=$samba/bin/wbinfo
#===================================================

user_name="$1"
group_name=$2

is_exist_user() {
  $wbinfo --user-info="$1" >/dev/null 2>&1
  return $?
}
is_exist_group() {
  $wbinfo --group-info="$1" >/dev/null 2>&1
  return $?
}

if [[ ! -e $samba_tool ]]; then
  echo "No samba-tool exist" 1>&2
  exit 1
fi

while [[ $user_name == "" ]] || ! is_exist_user "$user_name"; do
  echo "Input user_name to modify..."
  read user_name
done

while [[ $group_name == "" ]] || ! is_exist_group "$group_name"; do
  echo "Input group_name for add user..."
  read group_name
done

set -eu
main() {
  # 所属グループ登録
  sudo $samba_tool group addmembers ${group_name} ${user_name}
}

main
