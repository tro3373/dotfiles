#!/bin/bash

samba_tool=/usr/local/samba/bin/samba-tool
if [[ ! -e $samba_tool ]]; then
    echo "No samba-tool exist" 1>&2
    exit 1
fi

group_name="$1"
while [[ "$group_name" == "" ]]; do
    echo "Input group_name for Delete..."
    echo
    read group_name
done

if ! `wbinfo --group-info="${group_name}" > /dev/null 2>&1`; then
    echo "No group exist ${group_name}" 1>&2
    exit 1
fi

sudo $samba_tool group delete "$group_name"

