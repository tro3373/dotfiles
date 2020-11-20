#!/bin/bash

script_dir=$(
  cd $(dirname $0)
  pwd
)
domain_setting_file=$script_dir/.domain
images_dir=/var/lib/libvirt/images
xmls_dir=/etc/libvirt/qemu
list_files() {
  sudo sh -c "ls -lF $xmls_dir/*.xml"
  sudo sh -c "ls -lF $images_dir/*"
}
create_domain_setting() {
  while [[ "" == "$domain" ]]; do
    echo "Input target domain name"
    read domain
    if [[ "" == "$domain" ]]; then
      continue
    fi
  done
  echo "domain_name=$domain" >$domain_setting_file
  echo "domain_xml=$xmls_dir/${domain}.xml" >>$domain_setting_file
  echo "domain_image=$images_dir/${domain}.qcow2" >>$domain_setting_file
  echo
  echo "Domain name $domain setting file created. $domain_setting_file"
  cat $domain_setting_file
}

detect_domain() {
  if [[ ! -f $domain_setting_file ]]; then
    create_domain_setting
  fi
  source $domain_setting_file
}

detect_domain
