#!/bin/bash

main() {
    cd ./tmp/hugo/mysite
    git clone --recursive https://github.com/spf13/hugoThemes.git themes
}
main
