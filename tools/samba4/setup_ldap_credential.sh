#!/bin/bash

script_path=$(cd $(dirname $0); pwd)
source $script_path/smb4_common.sh

HOST=
ADMIN_CN=
DC_1=
DC_2=

echo "==> Setting up ldap credential file..."

while [[ "$HOST" == "" ]]; do
    echo "Input ldap host name..."
    read HOST
done

while [[ "$ADMIN_CN" == "" ]]; do
    echo "Input ldap accessable administrator name..."
    read ADMIN_CN
done

while [[ "$DC_1" == "" ]]; do
    echo "Input ldap domain name 1..."
    read DC_1
done

while [[ "$DC_2" == "" ]]; do
    echo "Input ldap domain name 2..."
    read DC_2
done

echo "#!/bin/bash" > $credential_file
echo "" >> $credential_file
echo "HOST=$HOST" >> $credential_file
echo "ADMIN_CN=$ADMIN_CN" >> $credential_file
echo "DC_1=$DC_1" >> $credential_file
echo "DC_2=$DC_2" >> $credential_file

chmod 600 $credential_file

echo
echo "Credentialed file created. $credential_file"
echo "Press Enter to Continue..."
echo
read waiting_enter

