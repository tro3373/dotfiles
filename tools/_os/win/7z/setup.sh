#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
main() {
    echo "==> Download from https://sevenzip.osdn.jp/"
    # local work_dir=$script_dir/tmp
    # [ ! -e $work_dir ] && mkdir $work_dir
    # cd $work_dir
    # local url="$(curl -fsSL https://sevenzip.osdn.jp/ |grep "href" |grep "x64.exe" |awk -F"href" '{print $2}' |awk -F\" '{print $2}')"
    # cd - >/dev/null 2>&1
    # echo "Done!"
}
main

