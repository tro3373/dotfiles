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
        if [[ 0 -eq 0 ]]; then
            dvexec $def_instcmd
            return 0
        fi
        # for msys2.
        # install lua.
        dvexec $instcmd ncurses-devel libcrypt-devel gettext-devel gcc make python2 ruby
        if [[ ! -e /usr/local/src/lua ]]; then
            dvexec mkdir -p /usr/local/src/lua
        fi
        dvexec cd /usr/local/src/lua
        local lua_version=5.3.2
        if [[ ! -e "/usr/local/src/lua/lua-$lua_version.tar.gz" ]]; then
            dvexec rm -rf /usr/local/src/lua/*
            dvexec wget http://www.lua.org/ftp/lua-$lua_version.tar.gz
            dvexec tar xvfpz ./lua-$lua_version.tar.gz
        fi
        dvexec cd ./lua-$lua_version

        dvexec make mingw
        dvexec make install

        # install vim.
        dvexec cd /usr/local/src/
        if [[ ! -e /usr/local/src/vim ]]; then
            dvexec git clone https://github.com/vim/vim.git
        fi
        dvexec cd vim/src
        dvexec ./configure \
            CPPFLAGS="-I/usr/include/ncursew" \
            --enable-fail-if-missing \
            --with-features=huge \
            --with-tlib=ncursesw \
            --enable-multibyte \
            --enable-perlinterp=yes \
            --enable-rubyinterp=yes \
            --enable-pythoninterp=yes \
            --enable-luainterp \
            --with-lua-prefix=/usr/local \
            --without-x \
            --disable-cscope \
            --disable-athena-check \
            --disable-carbon-check \
            --disable-motif-check \
            --disable-gtk2-check \
            --disable-nextaw-check \
            --disable-selinux \
            --disable-smack \
            --disable-darwin \
            --disable-mzschemeinterp \
            --disable-tclinterp \
            --disable-workshop \
            --disable-gpm \
            --disable-sysmouse \
            --disable-gui
        dvexec make
        dvexec make install
#    elif [ "$DETECT_OS" = "msys" ]; then
##        dvexec $def_instcmd
#        # for msys2.
#        # http://proglab.blog.fc2.com/blog-entry-38.html
#        # install lua.
#        #dvexec $instcmd ncurses-devel libcrypt-devel gettext-devel gcc make python ruby
#        if [[ ! -e "/usr/local/src/lua" ]]; then
#            dvexec mkdir -p /usr/local/src/lua
#        fi
#        if [[ ! -e "/usr/local/src/lua/luajit-2.0" ]]; then
#            dvexec git clone http://luajit.org/git/luajit-2.0.git /usr/local/src/lua/luajit-2.0
#        fi
#        dvexec cd /usr/local/src/lua/luajit-2.0
#        dvexec git checkout v2.0.4
#        dvexec make
#        dvexec make PREFIX=/opt/mingw64/luajit-2.0.4 install -Dm644 src/lua51.dll /opt/mingw64/luajit-2.0.4/bin/lua51.dll
#        dvexec mv /opt/mingw64/luajit-2.0.4/{share/luajit-2.0.4/jit/,bin/lua/jit/}
#        # install vim.
#        dvexec $instcmd pacman -S \
#            mingw-w64-x86_64-perl \
#            mingw-w64-x86_64-python \
#            mingw-w64-x86_64-pytho \
#            n3 \
#            mingw-w64-x86_64-ruby \
#            mingw-w64-x86_64-tcl
#        dvexec cd /usr/local/src/
#        if [[ ! -e /usr/local/src/vim ]]; then
#            dvexec git clone https://github.com/vim/vim.git /usr/local/src/vim
#        fi
#        dvexec cd /usr/local/src/vim
#        dvexec git checkout refs/tags/v7.4.884
#        dvexec patch -p1 -i $script_dir/Make_cyg_mingw.mak.diff
#        dvexec cd src
#        dvexec env CFLAGS="-mtune=native" \
#            mingw32-make -f Make_cyg_ming.mak \
#            DIRECTX=yes \
#            FEATURES=HUGE \
#            ARCH=x86-64 \
#            OLE=yes \
#            PERL=C:/msys64/mingw64 \
#            PERLLIB=C:/msys64/mingw64/lib/perl5/core_perl \
#            PERL_VER=522 \
#            LUA=C:/msys64/opt/mingw64/luajit-2.0.4 \
#            LUAINC=C:/msys64/opt/mingw64/luajit-2.0.4/include/luajit-2.0 \
#            PYTHON=C:/msys64/mingw64 \
#            PYTHONINC="-I C:/msys64/mingw64/include/python2.7" \
#            PYTHON_VER=2.7 \
#            PYTHON3=C:/msys64/mingw64 \
#            PYTHON3INC="-I C:/msys64/mingw64/include/python3.5m" \
#            PYTHON3_VER=3.5 \
#            RUBY=C:/msys64/mingw64 \
#            RUBYINC="-I C:/msys64/mingw64/include/ruby-2.2.0 -I C:/msys64/mingw64/include/ruby-2.2.0/x64-mingw32" \
#            RUBY_VER=22 \
#            RUBY_VER_LONG=220 \
#            TCL=C:/msys64/mingw64 \
#            TCL_VER=86
#        # -mtune=native で構築した vim.exe はまともに動作しないため
#        dvexec mingw32-make -f Make_cyg_ming.make ARCH=x86-64 clean
#
#        dvexec mingw32-make -f Make_cyg_ming.mak \
#            DIRECTX=yes \
#            FEATURES=HUGE \
#            ARCH=x86-64 \
#            GUI=no \
#            PERL=C:/msys64/mingw64 \
#            PERLLIB=C:/msys64/mingw64/lib/perl5/core_perl \
#            PERL_VER=522 \
#            LUA=C:/msys64/opt/mingw64/luajit-2.0.4 \
#            LUAINC=C:/msys64/opt/mingw64/luajit-2.0.4/include/luajit-2.0 \
#            PYTHON=C:/msys64/mingw64 \
#            PYTHONINC="-I C:/msys64/mingw64/include/python2.7" \
#            PYTHON_VER=2.7 \
#            PYTHON3=C:/msys64/mingw64 \
#            PYTHON3INC="-I C:/msys64/mingw64/include/python3.5m" \
#            PYTHON3_VER=3.5 \
#            RUBY=C:/msys64/mingw64 \
#            RUBYINC="-I C:/msys64/mingw64/include/ruby-2.2.0 -I C:/msys64/mingw64/include/ruby-2.2.0/x64-mingw32" \
#            RUBY_VER=22 \
#            RUBY_VER_LONG=220 \
#            TCL=C:/msys64/mingw64 \
#            TCL_VER=86 \
#            vim.exe
#        dvexec mkdir -p /opt/mingw64/vim-7.4.884
#        dvexec install -Dm755 {gvim.exe, vim.exe, vimrun.exe, xxd/xxd.exe} /opt/mingw64/vim-7.4.884
#        dvexec cp -r ../runtime /opt/mingw64/vim-7.4.884
#
    else
        dvexec $def_instcmd
    fi
}


setconfig() {
    make_link_dot2home $script_dir
#    vimbundle="$script_dir/.vim/bundle"
#    if [ ! -e "$vimbundle/neobundle.vim" ]; then
#        dvexec "cd \"$vimbundle\""
#        dvexec git clone git://github.com/Shougo/neobundle.vim
#    fi
#    log "  => Execute ':NeoBundleInstall' command in vim."
    if [ "$DETECT_OS" = "msys" ]; then
        make_link_bkupable "$script_dir/wingvim_from_msys" "${HOME}/bin/gvim"
    fi
}
