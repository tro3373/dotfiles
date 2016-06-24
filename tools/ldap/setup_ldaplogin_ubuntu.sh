#!/bin/bash

main() {
    sudo apt-get install ldap-auth-client nscd

    # For recreate.
    #       dpkg-reconfigure ldap-auth-config
    # Not tested bellow.
#     cat <<EOF>/usr/share/pam-configs/mkhomedir
# Name: Create home directory on login
# Default: yes
# Priority: 900
# Session-Type: Additional
# Session:
#         required    pam_mkhomedir.so umask=0022 skel=/etc/skel
# EOF
    sudo pam-auth-update
    sudo auth-client-config -t nss -p lac_ldap
    sudo systemctl restart nscd.service
}
main
