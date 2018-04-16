#!/bin/bash

main() {
    if [[ -d ~/.anyenv ]]; then
        echo "Already ~/.anyenv exists."
        exit 0
    fi
    git clone https://github.com/riywo/anyenv ~/.anyenv
}
main
