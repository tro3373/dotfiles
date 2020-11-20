#!/bin/bash

script_dir=$(
  cd $(dirname $0)
  pwd
)
$script_dir/comm_cmd.sh $0 1

echo
$script_dir/list_files.sh
echo "!!!Warning!!! rm image file if not needed."
