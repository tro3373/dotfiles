#!/bin/bash

set -eu

script_dir=$(cd $(dirname $0); pwd)

# Cpas Lock => Ctrl setting
if [ type dconf > /dev/null 2>&1 ]; then
    dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:nocaps']"
    #dconf reset /org/gnome/desktop/input-sources/xkb-options
fi

# font install
fonts_install() {
    work_dir="$script_dir/tmp"
    if [ ! -e $work_dir ]; then
        mkdir -p $work_dir
    fi
    cd $work_dir
    git clone git@bitbucket.org:tro3373/fonts.git
    cd fonts
    ./setup.sh
    cd -
}
fonts_install

# xsel, meld, rapidsvn
sudo apt-get install xsel meld rapidsvn

if [ ! -e ~/Desktop ]; then
    # 日本語ディレクトリ名を英語化
    env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update
fi
# visudo エディタをvimに設定
sudo update-alternatives --config editor

# Unity Tweak Tool
sudo apt-get install unity-tweak-tool
# Numix Icon theme
sudo apt-add-repository ppa:numix/ppa
sudo apt-get update
sudo apt-get install numix-gtk-theme numix-icon-theme numix-wallpaper-saucy numix-icon-theme-circle

# y-ppa-manager for fix GPG keys errors.
#sudo add-apt-repository ppa:webupd8team/y-ppa-manager
#sudo apt-get update
#sudo apt-get install y-ppa-manager

# Chrome install
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install google-chrome-stable

# sublime install
sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo apt-get update
sudo apt-get install sublime-text-installer ibus-mozc emacs-mozc

# atom install
sudo add-apt-repository ppa:webupd8team/atom
sudo apt-get update
sudo apt-get install atom

npm stars --install

# geany install
geany_install() {
    sudo add-apt-repository ppa:geany-dev/ppa
    sudo apt-get update
    sudo apt-get upgrade
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
geany_install
