#!/usr/bin/env bash

setup_home_dir_names() {
    if [ -e ~/Desktop ]; then
        return
    fi
    # 日本語ディレクトリ名を英語化
    env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update
}

setup_capslocks() {
    if ! has dconf; then
        log "==> No dconf command exist."
        return
    fi
    # Cpas Lock => Ctrl setting
    dconf reset /org/gnome/settings-daemon/plugins/keyboard/active
    dconf write /org/gnome/settings-daemon/plugins/keyboard/active true
    dconf reset /org/gnome/desktop/input-sources/xkb-options
    dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:nocaps']"
    #dconf reset /org/gnome/desktop/input-sources/xkb-options
}

setup_mount_media_setting() {
    # Disable automount external media
    gsettings set org.gnome.desktop.media-handling automount false
}

install_apps() {
    # Chrome install
    _update=0
    if ! sudo test -e /etc/apt/sources.list.d/google-chrome.list; then
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
        _update=1
    fi
    # Numix Icon theme
    if ! ls /etc/apt/sources.list.d |grep numix >& /dev/null; then
        sudo apt-add-repository -y ppa:numix/ppa
        _update=1
    fi

    if [[ $_update -eq 1 ]]; then
        sudo apt-get update
    fi

    sudo apt-get install -y google-chrome-stable
    sudo apt-get install -y numix-gtk-theme numix-icon-theme numix-icon-theme-circle

    # Tweak Tool
    sudo apt-get install -y unity-tweak-tool gnome-tweak-tool

    # xsel, meld, rapidsvn, smartmontools
    sudo apt-get install -y xsel meld rapidsvn smartmontools hardinfo

    # Guake install
    #sudo apt-get install -y guake

    # y-ppa-manager for fix GPG keys errors.
    #sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager
    #sudo apt-get update
    #sudo apt-get install -y y-ppa-manager
}

# geany install
setup_geany() {
    # support For ubuntu 16.04
    # sudo add-apt-repository -y ppa:geany-dev/ppa
    # sudo apt-get update
    # sudo apt-get upgrade
    sudo apt-get install -y geany
    if [ "" = "false" ]; then
        script_dir=$(cd $(dirname $0); pwd)
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

setup_default_editor() {
    if ! has vim; then
        sudo apt-get install -y vim
    fi
    # visudo エディタをvimに設定
    sudo update-alternatives --config editor
}

main () {
    setup_capslocks
    setup_home_dir_names
    setup_default_editor
    setup_mount_media_setting
    # smartctl -s on /dev/sda
    install_apps
}
main "$@"

