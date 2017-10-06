#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
dry_run=0

# インストール用関数 ロード
source $DOTPATH/lib/funcs

if is_mac; then
    brew update
    brew install mercurial
elif is_ubuntu; then
    sudo apt-get install curl git mercurial make binutils bison gcc build-essential
elif is_redhat; then
    sudo yum install curl git make bison gcc glibc-devel
elif is_cygwin; then
    echo "Not Support!!" 1>&2
    exit 1
fi

# Install gvm
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

# echo '[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"' >> .zshrc
# gvm install go1.4
# gvm use go1.4
# gvm install go1.5

# go version
# gvm use go1.4.2 --default
# gvm list
# gvm listall

## go setting(@see https://github.com/astaxie/build-web-application-with-golang/blob/master/ja/01.1.md)
# export GOROOT=$HOME/go
# export GOPATH=$HOME/gopath
# export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# [ dufferzafar/cheat ]( http://mattn.kaoriya.net/software/lang/go/20150518101220.htm )
# - https://github.com/dufferzafar/cheat
# - https://github.com/jahendrie/cheat
# go get github.com/dufferzafar/cheat
