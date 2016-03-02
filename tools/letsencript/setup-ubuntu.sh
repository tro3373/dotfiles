#!/bin/bash

src_dir=/opt/letsencrypt
main() {
    if [[ ! -d $src_dir ]]; then
        sudo git clone https://github.com/letsencrypt/letsencrypt $src_dir
        cd $src_dir
    else
        cd $src_dir
        sudo git pull
    fi
    echo "Do below..."
    echo "  cd $src_dir"
    echo "==>Set Up the SSL Certificate"
    echo "  ./letsencrypt-auto certonly --standalone -d www.example.com -d example.com --debug"
    echo "==>Crontab"
    echo "  sudo crontab -e"
    echo "  # Add below.."
    echo "  30 2 * * 1 cd $src_dir && ./letsencrypt-auto certonly --standalone -d www.example.com -d example.com --debug"
}
main
