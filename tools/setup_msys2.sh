#!/bin/bash

################################################################################
# !!!! Attention !!!!!
################################################################################
# 1. First of all, install msys2 with installer .
#    from [MSYS2 installer](http://msys2.github.io/).
# 2. Update core Packages.
#    type `update-core`, and execute.
#    If update-core command is not exist, execute 
#    `pacman --needed -Sy bash pacman pacman-mirrors msys2-runtime msys2-runtime-devel`
# 3. Reboot terminal.
# 4. execute bellow shell.
################################################################################

# update packages
pacman -Su --noconfirm

# Install needed packages
pacman -S --noconfirm \
    zsh \
    vim \
    git \
    svn \
    wget \
    sed \
    diffutils \
    grep \
    tar \
    unzip \
    patch \
    mingw-w64-x86_64-gcc \
    make \
    gcc

# 起動SHELLをZSHへ
#sed -ri -e 's/bash/zsh/g' /mingw32_shell.bat
#sed -ri -e 's/bash/zsh/g' /mingw64_shell.bat
sed -ri -e 's/bash/zsh/g' /msys2_shell.cmd
# symlink enable
#sed -ri -e 's/rem set MSYS=win/set MSYS=win/g' /mingw32_shell.bat
#sed -ri -e 's/rem set MSYS=win/set MSYS=win/g' /mingw64_shell.bat
sed -ri -e 's/rem set MSYS=win/set MSYS=win/g' /msys2_shell.cmd
# SHELL 変数へzshを正しく設定するようパッチ
sed -ri -e 's/^.*(profile_d zsh)/  \1\n  SHELL=`which zsh`/g' /etc/profile


