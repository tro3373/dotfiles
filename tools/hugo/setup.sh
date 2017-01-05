#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
tmp_dir=$script_dir/tmp
tmp_hugo=$tmp_dir/hugo

setup_hugo() {
    # http://qiita.com/syui/items/869538099551f24acbbf
    # https://kijtra.com/article/change-to-hugo/
    ! go version >/dev/null 2>&1 && echo "No golang installed" && exit 2
    hugo version >/dev/null 2>&1 && return
    echo "==> Installing hugo .."
    [ -e $tmp_hugo ] && rm -rf $tmp_hugo
    git clone https://github.com/spf13/hugo $tmp_hugo
    cd $tmp_hugo && echo "==> Go getting .. " && go get && cd - >/dev/null 2>&1 && echo "==> hugo installed."
}

setup_memo() {
    if [ ! -e $tmp_b/.git ]; then
        [ -z $1 ] && echo "Specify url for clone" && exit 2
        git clone $1
    fi
}

new_mysite() {
    hugo new site mysite
}

get_all_themes() {
    cd ./mysite
    git clone --recursive https://github.com/spf13/hugoThemes.git tmp
}

gen_config() {
    cd ./mysite
    cat << EOF > config.yaml
---
contentdir: "content"
layoutdir: "layouts"
publishdir: "public"
indexes:
  category: "categories"
baseurl: ""
title: ""
EOF
}

main() {
    setup_hugo
    setup_memo $1
}
main $*
