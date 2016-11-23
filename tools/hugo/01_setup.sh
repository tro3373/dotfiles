#!/bin/bash

main() {
    # http://qiita.com/syui/items/869538099551f24acbbf
    # https://kijtra.com/article/change-to-hugo/
    [ ! go --version >/dev/null 2>&1 ] && echo "No golang installed" && exit 2
    mkdir tmp && cd tmp
    git clone https://github.com/spf13/hugo
    cd hugo && go get
}
main
