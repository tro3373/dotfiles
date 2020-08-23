#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
source $script_dir/comm_load_create_setting.sh
$script_dir/snap_comm.sh -a $*

