#!/bin/bash

samba=/usr/local/samba
user_name="$1"

main() {
    while [[ "$user_name" == "" ]]; do
        echo "Input user_name for search..."
        read user_name
    done
    $samba/bin/ldbsearch --url=$samba/private/sam.ldb cn=$user_name
}
main
