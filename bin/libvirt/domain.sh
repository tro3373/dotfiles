#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
domain_setting_file=$script_dir/.domain
$script_dir/comm_load_create_setting.sh
if [[ -f $domain_setting_file ]]; then
    echo "Domain Setting Exist."
    echo
    cat $domain_setting_file
else
    echo "No Domain Setting Exist."
fi

