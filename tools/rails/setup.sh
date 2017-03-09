#!/bin/bash

dotbin=${DOTPATH:-~/.dot}/bin
has() {
    which ${1} >/dev/null 2>&1
    return $?
}
check() {
    if ! has anyenv; then
        echo "Installing anyenv ..."
        ../anyenv/setup.sh
    fi
    if ! has rbenv; then
        echo "Installing rbenv ..."
        ../anyenv/rbenv_install_ruby 2.4.0
    fi
    if ! `bundle --help>/dev/null 2>&1`; then
        echo "Installing bundler ..."
        sudo gem install bundler
    fi
}
rails_new() {
    if [[ -e tmp/project ]]; then
        echo "Already exist tmp/project directory."
        return 0
    fi
    mkdir -p tmp/project
    cd tmp/project
    $dotbin/railsnew -p
}
main() {
    check
    rails_new
}
main $*
