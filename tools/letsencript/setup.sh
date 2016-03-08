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
    echo "  # Sample1"
    echo "  30 2 * * 1 cd $src_dir && ./letsencrypt-auto certonly --standalone -d www.example.com -d example.com --debug"
    echo "  # Sample2"
    echo "  00 05 01 * * $src_dir/letsencrypt-auto renew --force-renew && /bin/systemctl reload httpd"
    echo "  # Sample3"
    echo "  00 05 01 * * service apache2 stop && $src_dir/letsencrypt-auto renew --force-renew && service apache2 start"
}
main
