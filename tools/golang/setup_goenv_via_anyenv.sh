#!/bin/bash

main() {
    [ ! type anyenv >/dev/null 2>&1 ] && echo "No anyenv exist." && exit 2
    if ! type goenv >/dev/null 2>&1; then
        anyenv install goenv
        echo "===> Reload shell"
    else
        local version=1.8
        goenv install $version
        goenv global $version
        goenv rehash
        go version
        echo "Done!"
    fi
}
main
