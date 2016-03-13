#!/bin/bash

# Install msys2 with installer
#  - [MSYS2 installer](http://msys2.github.io/)


# update package core
update-core
# update-core コマンドがない場合は以下コマンド
# pacman --needed -Sy bash pacman pacman-mirrors msys2-runtime msys2-runtime-devel

echo "reboot msys2"

# update packages
pacman -Su

# Install needed packages
pacman -S vim git wget sed diffutils grep tar unzip patch

# SHELL 変数へzshを正しく設定するようパッチ
sed -ri -e 's/^.*(profile_d zsh)/  \1\n  SHELL=`which zsh`/g' /etc/profile





echo "Install dotfiles..."
