#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
main() {
    # find $WINHOME/tools -maxdepth 1 -name "*kaoriya*" -type d >/dev/null 2>&1 && echo "Already kaoriya-vim exist at $WINHOME/tools" && exit 1
    ls $WINHOME/tools |grep -E "*kaoriya*" >/dev/null 2>&1 && echo "Already kaoriya-vim exist at $WINHOME/tools. do nothing." && exit 1
    [ ! -e $WINHOME/tools ] && mkdir $WINHOME/tools
    local work_dir=$script_dir/tmp
    [ ! -e $work_dir ] && mkdir $work_dir
    cd $work_dir
    echo "==> Downloading .."
    local kaoriya_url="$(curl -fsSL http://vim-jp.org/redirects/koron/vim-kaoriya/latest/win64/ |grep "a href" |awk -F\" '{print $2}')"
    curl -fsSLO $kaoriya_url
    echo "==> Unzipping .."
    unzip "$script_dir/tmp/*kaoriya*zip"
    local kaoriyavim="$(find . -maxdepth 1 -name "*kaoriya*" -type d)"
    mv $kaoriyavim $WINHOME/tools
    cd -
    echo "Done!"
}
main

