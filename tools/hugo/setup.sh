#!/bin/bash

setup_hugo() {
    # http://qiita.com/syui/items/869538099551f24acbbf
    # https://kijtra.com/article/change-to-hugo/
    ! go version && echo "No golang installed" && exit 2
    hugo version && echo && echo "Already hugo installed" && exit 0
    echo "==> Installing hugo .."
    echo
    mkdir tmp && cd tmp
    git clone https://github.com/spf13/hugo
    cd hugo && go get
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
}
main
