#!/bin/bash

target_dir=${PWD}
if [ ! "$@" == "" ]; then
    target_dir="$@"
fi

list=`find ${target_dir} -name ".git" -prune -o -type f -print`
# -perm 755 => 755 パーミッションを探す
# st=`find ${target_dir} -type f -perm 755`
# not = !
# list=`find ${target_dir} -type f ! -perm 755`

for file in $list
do
    filename=`basename $file`
    ext=${filename##*.}
    ext_list=("${ext_list[@]}" ${ext})
done

echo ${ext_list[@]} | tr ' ' '\n' | sort | uniq -c | sort -n

