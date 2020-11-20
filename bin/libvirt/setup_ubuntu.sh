#!/bin/bash

script_dir=$(
  cd $(dirname $0)
  pwd
)
source $script_dir/comm_load_create_setting.sh
guest_name=original

main() {
  # Install packages
  sudo apt-get install qemu-kvm libvirt-bin virtinst bridge-utils libguestfs-tools
  # Enable vhost(Enable Module for decrease network overhead)
  sudo modprobe vhost_net
  # check vhost
  sudo lsmod | grep vhost
  sudo sh -c 'echo vhost_net >> /etc/modules'
  # Disable host ip v6
  sudo sh -c 'echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf'
  sudo sh -c 'echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf'
  sudo sysctl -p
  # # Install Guest
  # sudo virt-install \
  #     --name $guest_name \
  #     --ram 1024 \
  #     --disk path=/var/lib/libvirt/images/$guest_name.img,size=30 \
  #     --vcpus 2 \
  #     --os-type linux \
  #     --os-variant ubuntu16.04 \
  #     --network bridge=br0 \
  #     --graphics none \
  #     --console pty,target_type=serial \
  #     --location http://jp.archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/ \
  #     --extra-args 'console=ttyS0,115200n8 serial'
  # # Enable serial console in Guest
  # ## Add setting to /etc/default/grub in Guest
  # sudoedit /etc/default/grub
  # # GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200n8"
  # # GRUB_SERIAL_COMMAND="serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1"
  # sudo update-grub
}
main
