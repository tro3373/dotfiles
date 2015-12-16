#!/bin/bash

# Get OS bit
# 32bit : i686
# 64bit : x86_64
get_os_bit() {
    echo $(uname -m);
}

# Get Linux distribution name
get_os_distribution() {
    if   [ -e /etc/debian_version ] ||
         [ -e /etc/debian_release ]; then
        # Check Ubuntu or Debian
        if [ -e /etc/lsb-release ]; then
            # Ubuntu
            distri_name="ubuntu"
        else
            # Debian
            distri_name="debian"
        fi
    elif [ -e /etc/fedora-release ]; then
        # Fedra
        distri_name="fedora"
    elif [ -e /etc/redhat-release ]; then
        # CentOS
        distri_name="redhat"
    elif [ -e /etc/turbolinux-release ]; then
        # Turbolinux
        distri_name="turbol"
    elif [ -e /etc/SuSE-release ]; then
        # SuSE Linux
        distri_name="suse"
    elif [ -e /etc/mandriva-release ]; then
        # Mandriva Linux
        distri_name="mandriva"
    elif [ -e /etc/vine-release ]; then
        # Vine Linux
        distri_name="vine"
    elif [ -e /etc/gentoo-release ]; then
        # Gentoo Linux
        distri_name="gentoo"
    elif [ `uname` = "Darwin" ]; then
        # mac
        distri_name="mac"
    else
        # Other
        distri_name="Unkown distribution"
    fi

    echo ${distri_name}
}

# Get bit
# get_os_bit
# Get distribution
get_os_distribution
