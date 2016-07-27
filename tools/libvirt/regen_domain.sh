#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
rm $script_dir/.domain
$script_dir/comm_load_create_setting.sh

