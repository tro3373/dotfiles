#!/bin/bash

script_dir=$(
  cd $(dirname $0)
  pwd
)
source $script_dir/comm_load_create_setting.sh

delrestore=$1
snap_id="$2"
cmd="Delete"
[[ $delrestore =~ -a ]] && cmd="Restore"

list_snap() {
  $script_dir/snap_list.sh
}
input_snap_name() {
  snap_id=
  while [[ "" == "$snap_id" ]]; do
    list_snap
    echo
    echo "Input snap target No for $cmd"
    read snap_id
  done
}

check_snap_name() {
  [[ "" != "$snap_id" ]] && list_snap | grep -E "^$snap_id " >/dev/null 2>&1
}
main() {
  if [[ ! $delrestore =~ -[ad] ]]; then
    echo "input -a/-d option" >&2
    exit 1
  fi
  local answer=
  while [[ ! $answer =~ [Yy] ]]; do
    if [[ "" != "$answer" ]]; then
      snap_id=
      snap_name=
    fi
    while ! check_snap_name; do
      input_snap_name
    done
    snap_name=$(list_snap | grep -E "^$snap_id " | awk {'print $2'})
    echo "Are you ready for $cmd ? ID=$snap_id Name=$snap_name (y/n)"
    read answer
  done
  echo sudo qemu-img snapshot ${delrestore} ${snap_name} ${domain_image}
  echo
  list_snap
}
main
