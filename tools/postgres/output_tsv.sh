#!/bin/bash
database=hogehoge
user=hogehoge
outfile=hogehoge.tsv
sql="select * form hogehoge;"

psql -U $user $database -A -F"	" -c "$sql" > $outfile

