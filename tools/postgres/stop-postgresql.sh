#!/bin/bash

set -eu

# PostgreSQL設定（DBの置き場所）
export PGDATA=/usr/local/var/postgres
# PostgreSQLサーバの停止
pg_ctl -D /usr/local/var/postgres stop -s -m fast
