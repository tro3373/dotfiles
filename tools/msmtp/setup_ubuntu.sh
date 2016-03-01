#!/bin/bash

gmail_account=${1:-hoge@gmail.com}
gmail_passwd=${2:-hogehoge}
main() {
    sudo apt-get install msmtp
    cat << EOT >> ~/.msmtprc
defaults
auth on
tls on
tls_certcheck off

logfile ~/.msmtp.log
aliases ~/.aliases

account gmail
user $gmail_account
password $gmail_passwd
from $gmail_account
host smtp.gmail.com
port 587

account default : gmail
EOT
    chmod 600 ~/.msmtprc
}
main
