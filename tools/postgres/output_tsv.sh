#!/bin/bash
host=hogehoge
database=hogehoge
user=hogehoge
outfile=output.tsv
args="$*"
sql=./exe.sql
pgpass=~/.pgpass
if [ ! -f $pgpass ]; then
    # .pgpass ファイル無し
    echo "No .pgpass file exist."
    echo "Create youre .pgpass file to home directory. like this.."
    echo '  echo "localhost:5432:database:username:password" > ~/.pgpass'
    echo '  chmod 0600 ~/.pgpass'
    exit 1
fi
if [ ! "$args" = "" ]; then
    # ファイル指定がある場合はそれを実行
    sql="$args"
elif [ ! -e $sql ]; then
    # execute.sql もない
    echo "No execute.sql file exist. path=$sql"
    exit 1
fi
echo "========================================" >> $outfile
echo "execute: $sql" >> $outfile
echo "========================================" >> $outfile
if [ -f "$sql" ]; then
    # ファイルの場合
    psql -h $host -U $user $databaes -A -F"	" -f "$sql" >> $outfile
else
    # sql の場合
    psql -h $host -U $user $databaes -A -F"	" -c "$sql" >> $outfile
fi

