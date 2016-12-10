#!/bin/bash

install() {
    if [ "$DETECT_OS" = "ubuntu" ]; then
#        dvexec "$instcmd --force-yes vim vim-gtk vim-athena vim-gnome"
        dvexec sudo apt-get remove -y --purge vim vim-runtime vim-gnome vim-tiny vim-common vim-gui-common
        dvexec sudo apt-get install -y liblua5.1-dev luajit \
            libluajit-5.1 python-dev ruby ruby-dev libperl-dev \
            mercurial libncurses5-dev libgnome2-dev libgnomeui-dev \
            libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev \
            libx11-dev libxpm-dev libxt-dev

        if [[ ! -e /usr/include/lua5.1/include ]]; then
            dvexec sudo mkdir /usr/include/lua5.1/include
        fi
        dvexec sudo ln -sf /usr/include/luajit-2.0 /usr/include/lua5.1/include
        dvexec cd /usr/local/src/
        if [[ ! -e /usr/local/src/vim ]]; then
            dvexec sudo git clone https://github.com/vim/vim.git
            dvexec cd vim/src
        else
            dvexec cd vim
            dvexec sudo git pull --rebase
            dvexec cd src
        fi
        dvexec sudo ./configure --with-features=huge \
            --enable-rubyinterp \
            --enable-largefile \
            --disable-netbeans \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
            --enable-perlinterp \
            --enable-luainterp \
            --with-luajit \
            --enable-gui=auto \
            --enable-fail-if-missing \
            --with-lua-prefix=/usr/include/lua5.1 \
            --enable-cscope
        dvexec sudo make
        dvexec sudo make install
        dvexec cd ..
        if [[ ! -e /usr/share/vim ]]; then
            dvexec sudo mkdir /usr/share/vim
        fi
        if [[ ! -e /usr/share/vim/vim74 ]]; then
            dvexec sudo mkdir /usr/share/vim/vim74
        fi
        dvexec sudo cp -fr runtime/* /usr/share/vim/vim74/
    elif [ "$DETECT_OS" = "mac" ]; then
        dvexec $instcmd lua
        dvexec $instcmd vim --with-lua
    elif [ "$DETECT_OS" = "redhat" ]; then
        dvexec cd /usr/local/src/
        if [[ ! -e /usr/local/src/luajit ]]; then
            dvexec sudo git clone http://luajit.org/git/luajit-2.0.git luajit
        fi
        dvexec cd luajit
        dvexec sudo make
        dvexec sudo make install
        dvexec cd ../
        if [[ ! -e /usr/local/src/vim ]]; then
            dvexec sudo git clone https://github.com/vim/vim.git
            dvexec cd vim/src
        else
            dvexec cd vim
            dvexec sudo git pull --rebase
            dvexec cd src
        fi
        dvexec sudo yum install -y ruby ruby-devel lua lua-devel luajit luajit-devel \
            ctags mercurial python python-devel python3 python3-devel tcl-devel perl \
            perl-devel perl-ExtUtils-ParseXS perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
            perl-ExtUtils-Embed ncurses-devel
        dvexec sudo ./configure --enable-multibyte \
            --with-features=huge \
            --enable-luainterp \
            --enable-perlinterp \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/lib64/python2.7/config \
            --enable-rubyinterp \
            --with-ruby-command=/usr/bin/ruby \
            --enable-gui=gtk2 \
            --enable-cscope \
            --with-tlib=ncurses \
            --prefix=/usr/local
        dvexec sudo make
        dvexec sudo make install
    elif [ "$DETECT_OS" = "msys" ]; then
        # for msys2.
        local type=build # build/package
        if [ "$type" = "package" ]; then
            dvexec $def_instcmd
            return 0
        fi
        # install lua.
        dlog "===> Lua Building .."
        dvexec $instcmd ncurses-devel libcrypt-devel gettext-devel gcc make
        if [[ ! -e /usr/local/src/lua ]]; then
            dvexec mkdir -p /usr/local/src/lua
        fi
        dvexec cd /usr/local/src/lua
        local lua_version=5.3.3
        if [[ ! -e "/usr/local/src/lua/lua-$lua_version.tar.gz" ]]; then
            dvexec rm -rf /usr/local/src/lua/*
            dvexec wget http://www.lua.org/ftp/lua-$lua_version.tar.gz
            dvexec tar xvfpz ./lua-$lua_version.tar.gz
        fi
        dvexec cd ./lua-$lua_version
        dvexec make mingw
        dvexec make install

        # install vim.
        dlog "===> Vim Building .."
        dvexec $instcmd python3 ruby

        dlog "===> Msys2 packages Cloning .."
        local msys2packages=/usr/local/src/Msys2-packages
        if [[ ! -e "$msys2packages/.git" ]]; then
            dvexec cd /usr/local/src
            dvexec git clone https://github.com/Alexpux/MSYS2-packages.git
        fi
        dvexec cd /usr/local/src/MSYS2-packages
        dvexec git checkout .
        local ver=92832fb441011827cfb93ec3208b86cecce05648
        dvexec git checkout $ver
        dvexec patch -p1 < $script_dir/vim_pkgbuild.patch
        dvexec cd vim
        dvexec makepkg
        # upgrade error will occur
        #dvexec pacman -U --noconfirm vim*.pkg.tar.xz
    else
        dvexec $def_instcmd
    fi
}


setconfig() {
    make_link_dot2home $script_dir
    if [ "$DETECT_OS" = "msys" ]; then
        local buildvim=/usr/local/src/Msys2-packages/vim/pkg/vim/usr/bin/vim.exe
        if [ -e $buildvim ]; then
            make_link_bkupable "$buildvim" "${HOME}/bin/vim"
        fi
    fi
}
