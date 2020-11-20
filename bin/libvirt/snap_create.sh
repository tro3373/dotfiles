#!/bin/bash

script_dir=$(
  cd $(dirname $0)
  pwd
)
source $script_dir/comm_load_create_setting.sh

timestamp="$(date +%Y%m%d.%H%M%S)"
suggestFileName="${domain_name}.img.snapshot.${timestamp}"
outFileName="$1"

main() {
  if [[ "" == "$outFileName" ]]; then
    answer=
    while [[ ! $answer =~ [yYnN] ]]; do
      echo "Use $suggestFileName ?(yn)"
      read answer
    done
    if [[ $answer =~ [nN] ]]; then
      echo "Error. Specify output file name. exit." 1>&2
      exit 1
    fi
    outFileName=$suggestFileName
  fi
  sudo qemu-img snapshot -c ${outFileName} $domain_image
}
main
