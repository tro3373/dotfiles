#!/bin/bash

# install apt-cyg
which wget
ret=$?
if [ $ret -neq 0 ]; then
    echo "check cygwin install package wget at installer"
else
    cd ~/
    wget https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
    chmod 755 apt-cyg
    mv apt-cyg /usr/local/bin/
    # Install putclip, getclip command.
    apt-cyg install cygutils-extra
fi

if [ ! -e /etc/passwd ]; then
    # Create Login shell setting file.
    mkpasswd -l > /etc/passwd
    mkgroup  -l > /etc/group
    # edit login shell to /usr/bin/zsh
    echo "install zsh and edit /etc/passwd for change login shell."
fi
