#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)

# インストール用関数 ロード
dry_run=0
source $DOTPATH/bin/lib/funcs

install() {
    cmd_pyenv=~/.anyenv/envs/pyenv/bin/pyenv
    cmd_pip=~/.anyenv/envs/pyenv/shims/pip
    if [ -e $cmd_pyenv ]; then
        if $cmd_pyenv version |grep "2.7.10" > /dev/null 2>&1; then
            if [ -e ~/.local/lib/python2.7/site-packages/powerline ]; then
                return 0
            fi
        fi
    fi
    # see anyenv setting...
    #   http://qiita.com/luckypool/items/f1e756e9d3e9786ad9ea
    #   https://github.com/riywo/anyenv
    # see powerline setting...
    #   http://qiita.com/qurage/items/4edda8559cc4c98758ee
    if is_mac; then
        if ! test_cmd xcode-select; then
            mexe "xcode-select --install"
        fi
        mexe "brew install readline; brew link readline;"
    elif is_ubuntu; then
        mexe sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev
    elif is_redhat; then
        mexe sudo yum install -y gcc gcc-c++ make git openssl-devel bzip2-devel zlib-devel readline-devel sqlite-devel
    elif is_cygwin; then
        mexe apt-cyg install patch
    fi

    # anyenv install
    if [ ! -d "${HOME}/.anyenv" ]; then
        mexe git clone https://github.com/riywo/anyenv ~/.anyenv
    fi

    # pyenv install
    if [ ! -d ${HOME}/.anyenv/envs/pyenv ]; then
        mexe "export PATH=\"$HOME/.anyenv/bin:$PATH\""
        eval "$(anyenv init -)"
        mexe anyenv install pyenv
    fi

    # python 2.7.10 install via pyenv
    if [ -d ${HOME}/.anyenv/envs/pyenv/bin ]; then
        if ! $cmd_pyenv version |grep "2.7.10" > /dev/null 2>&1; then
            mexe "export PATH=\"$HOME/.anyenv/envs/pyenv/bin:$PATH\""
            eval "$(pyenv init -)"
            mexe $cmd_pyenv install 2.7.10
            mexe $cmd_pyenv global 2.7.10
        fi
    fi

    # pip install powerline
    if [ ! -e ~/.local/lib/python2.7/site-packages/powerline ]; then
        mexe $cmd_pip install --user git+git://github.com/powerline/powerline
    fi

    # powerline settings
    if [ ! -e ~/.config/powerline ]; then
        mexe mkdir -p ~/.config/powerline
        mexe cp -R ~/.local/lib/python2.7/site-packages/powerline/config_files/* ~/.config/powerline/
        make_lnk_with_bkup $script_dir/default.json ~/.config/powerline/themes/tmux/default.json
        make_lnk_with_bkup $script_dir/powerline.json ~/.config/powerline/themes/powerline.json
    fi
}
install

