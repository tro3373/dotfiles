#!/bin/bash

set -eu

brew install postgresql
# データベースの初期化 (文字コードはUTF-8)
#  initdb /usr/local/var/postgres -E utf8

curl -o fixBrewLionPostgresql.sh http://nextmarvel.net/blog/downloads/fixBrewLionPostgres.sh
chmod 755 fixBrewLionPostgresql.sh
./fixBrewLionPostgresql.sh

ME=`whoami`
sudo -u $ME psql postgres -f setup-init.sql




# PostgreSQLサーバの起動(参考)
#  postgres -D /usr/local/var/postgres

