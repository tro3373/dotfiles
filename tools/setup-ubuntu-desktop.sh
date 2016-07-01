#!/bin/bash

set -eu

script_dir=$(cd $(dirname $0); pwd)

# Settings for 2byte characters
# @see https://wiki.ubuntulinux.jp/hito/WIP-ambiwidth
# sudo bash -c 'echo "export VTE_CJK_WIDTH=1" > /etc/profile.d/vte_cjk_width.sh'
# For Under ubuntu14.10
# ln -s ~/dotfiles/tools/ubuntu/cjk-terminal.desktop ~/.local/share/applications/cjk-terminal.desktop
# For Upper ubuntu15.04, terminal-app settings can do that.
# [Profile settings - compatibility - fazy width char] => set to double byte
#   => but, tmux not fix it, buggy....

# Cpas Lock => Ctrl setting
if [ type dconf > /dev/null 2>&1 ]; then
    dconf reset /org/gnome/settings-daemon/plugins/keyboard/active
    dconf write /org/gnome/settings-daemon/plugins/keyboard/active true
    dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:nocaps']"
    #dconf reset /org/gnome/desktop/input-sources/xkb-options
fi

# Disable automount external media
gsettings set org.gnome.desktop.media-handling automount false

# font install
fonts_install() {
    work_dir="$script_dir/tmp"
    if [ ! -e $work_dir ]; then
        mkdir -p $work_dir
    fi
    cd $work_dir
    git clone https://tro3373@bitbucket.org/tro3373/fonts.git
    cd fonts
    ./setup.sh
    cd -
}
fonts_install

# xsel, meld, rapidsvn, smartmontools
sudo apt-get install -y xsel meld rapidsvn smartmontools hardinfo
# smartctl -s on /dev/sda

if [ ! -e ~/Desktop ]; then
    # 日本語ディレクトリ名を英語化
    env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update
fi
# visudo エディタをvimに設定
sudo apt-get install vim
sudo update-alternatives --config editor

# Unity Tweak Tool
sudo apt-get install -y unity-tweak-tool
# Numix Icon theme
sudo apt-add-repository -y ppa:numix/ppa
sudo apt-get update
# support For ubuntu 16.04
#sudo apt-get install -y numix-gtk-theme numix-icon-theme numix-wallpaper-saucy numix-icon-theme-circle
sudo apt-get install -y numix-gtk-theme numix-icon-theme numix-icon-theme-circle

# Guake install
#sudo apt-get install -y guake

# y-ppa-manager for fix GPG keys errors.
#sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager
#sudo apt-get update
#sudo apt-get install -y y-ppa-manager

# Chrome install
if ! type google-chrome-stable > /dev/null 2>&1; then
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
fi

# sublime install
if ! type subl > /dev/null 2>&1; then
    sudo add-apt-repository -y ppa:webupd8team/sublime-text-3
    sudo apt-get update
    sudo apt-get install -y sublime-text-installer ibus-mozc emacs-mozc
    cd ./sublime
    ./setup.sh
    cd -
fi

# atom install
if ! type apm > /dev/null 2>&1; then
    sudo add-apt-repository -y ppa:webupd8team/atom
    sudo apt-get update
    sudo apt-get install -y atom
    cd ./atom
    ./setup.sh
    ./atom/install_from_package_list.sh
    cd -
fi

# geany install
geany_install() {
    # support For ubuntu 16.04
    # sudo add-apt-repository -y ppa:geany-dev/ppa
    # sudo apt-get update
    # sudo apt-get upgrade
    sudo apt-get install -y geany
    if [ "" = "false" ]; then
        geanyconfdir=$HOME/.config/geany
        mv "$geanyconfdir/geany.conf" "$geanyconfdir/geany.conf.org"
        mv "$geanyconfdir/keybindings.conf" "$geanyconfdir/keybindings.conf.org"
        ln -s "$script_dir/ubuntu/geany/geany.conf" "$geanyconfdir/geany.conf"
        ln -s "$script_dir/ubuntu/geany/keybindings.conf" "$geanyconfdir/keybindings.conf"

        cd ~/.config/geany/filedefs
        tar xvfpz "$script_dir/ubuntu/geany/oblivion2.tar.gz"
        cat filetypes.xml > filetypes.html
        sed 's/^selection.+$/selection=0x000;0x33B5E5;false;true/g' filetypes.common

        echo "- Themeを[ここ](http://www.geany.org/Download/Extras)からダウンロード"
        echo "- [色設定の為、最新にUPDATE](http://enwarblog.blogspot.jp/2012/08/geany.html)"
        echo "- oblivion2.tar.gz"
        echo "    - 解凍し、~/.config/geany/filedefs へ配置"
        echo "- htmlの色変更"
        echo "    - htmlファイルがバグっているので、filetype.htmlは、filetype.xmlからコピーし貼付け"
        echo "- 選択時の色を赤から変更"
        echo "    - filetypes.commom"
        echo "#selection=0x000;0xA52A2A;false;true"
        echo "selection=0x000;0x33B5E5;false;true"
    fi
}
if ! type geany > /dev/null 2>&1; then
    geany_install
fi

