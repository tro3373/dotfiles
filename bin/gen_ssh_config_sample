#!/bin/bash

target=./ssh-config
echo "Host [server1] [server2]" >> $target
echo "  IdentityFile /path/to/your/identity/file" >> $target
echo "  ServerAliveInterval 30" >> $target
echo "  PermitLocalCommand  yes" >> $target
echo "  LocalCommand tmux rename-window %n" >> $target
echo "  ForwardX11 yes" >> $target
echo "  ForwardX11Trusted yes" >> $target
echo "  RemoteForward 52224 localhost:52224" >> $target
echo "Host [server1]" >> $target
echo "  HostName [ipaddress]" >> $target
echo "  Port 22" >> $target
echo "  User [username]" >> $target
echo "Host [server2]" >> $target
echo "  HostName [ipaddress]" >> $target
echo "  Port 22" >> $target
echo "  User [username]" >> $target
chmod 640 $target

