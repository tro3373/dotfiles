#!/bin/bash

has() { which ${1} >& /dev/null; }

backup() {
    for f in "$@"; do
        sudo test ! -e $f && continue
        local dst=$f.org
        sudo test -e $dst && continue
        sudo cp -rf $f $dst
    done
}
main() {
    if test -f /etc/bootstrapped; then
        return
    fi

    set -e
    ## =================キーボードの設定===================
    sudo localectl set-keymap jp106

    ## =================日本語環境の構築===================
    sudo timedatectl set-timezone Asia/Tokyo  # タイムゾーン設定
    backup /etc/locale.conf
    cat << 'EOF' | sudo tee /etc/locale.conf >/dev/null
LANG=en_US.UTF8
LC_NUMERIC=en_US.UTF8
LC_TIME=en_US.UTF8
LC_MONETARY=en_US.UTF8
LC_PAPER=en_US.UTF8
LC_MEASUREMENT=en_US.UTF8
EOF
    backup /etc/locale.gen
    cat << EOF | sudo tee /etc/locale.gen >/dev/null
en_US.UTF-8 UTF-8
ja_JP.UTF-8 UTF-8
EOF
    sudo locale-gen

    sudo pacman -R --noconfirm xorg-fonts-misc xorg-font-utils xorg-server xorg-server-common xorg-bdftopcf libxfont libxfont2

    sudo pacman -Syyu --noconfirm

    sudo pacman -S --noconfirm libxfont2

    if ! has yaourt; then
        sudo pacman -S --noconfirm yaourt
    fi

    backup /etc/pacman.d/mirrorlist
    if ! has reflector; then
        sudo pacman -S --noconfirm reflector
        sudo reflector --verbose --country 'Japan' -l 10 --sort rate --save /etc/pacman.d/mirrorlist
    fi
    if ! has powerpill; then
        gpg --recv-keys --keyserver hkp://pgp.mit.edu 1D1F0DC78F173680
        yaourt -S --noconfirm powerpill  # Use powerpill instead of pacman. Bye pacman...
    fi

    ### =================powerpill SigLevel書き換え===================
    if ! sudo test -e /etc/pacman.conf.org; then
        backup /etc/pacman.conf
        sudo sed -i -e 's/Required DatabaseOptional/PackageRequired/' /etc/pacman.conf
    fi

    # =================全パッケージのアップデート===================
    sudo powerpill -Syu --noconfirm
    yaourt -Syua --noconfirm

    # for clipboard
    sudo powerpill -S --noconfirm xsel
    yaourt -S --noconfirm xorg-server-xvfb
    # =================GUI環境===================
    # sudo pacman -S --noconfirm xorg-xinit lightdm-gtk-greeter
    # sudo pacman -S --noconfirm xorg-xinit

    # sudo pacman -S --noconfirm lightdm-gtk-greeter
    # yes 'all' | sudo pacman -S --noconfirm xfce4 lightdm
    # sudo pacman -S --noconfirm xfce4 lightdm
    # sudo pacman -S --noconfirm xfce4
    # sudo systemctl enable lightdm.service
    # ## /etc/systemd/system/default.targetのリンクをmulti-user.targetからgraphical.targetに変える
    # sudo systemctl set-default graphical.target


    ## =================フォントとインプットメソッドのインストール===================
    # yaourt -S --noconfirm otf-takao
    # yes 'all' | sudo pacman -S --noconfirm fcitx-im fcitx-configtool fcitx-mozc
    # sudo pacman -S --noconfirm fcitx-im fcitx-configtool fcitx-mozc
    #
    # sudo cat << 'EOF' > ${HOME}/.xprofile
    # export GTK_IM_MODULE=fcitx
    # export QT_IM_MODULE=fcitx
    # export XMODIFIERS=”@im=fcitx”
    # EOF
    #
    #
    #
    # ## =================自動ログイン===================
    # sudo cat /etc/lightdm/lightdm.conf |
    #    sudo sed -e 's/#autologin-user=/autologin-user=vagrant/' |
    #        sudo tee /etc/lightdm/lightdm.conf
    # sudo groupadd -r autologin
    # sudo gpasswd -a vagrant autologin
    # ↑一回目のログインはユーザー名とパスワード(どちらもvagrnat)打たないといけない


    # =====================dockerセットアップ==========================
    #sudo pacman -S --noconfirm docker  # dockerインストール
    #sudo systemctl enable docker  # ログイン時にデーモン実行
    #sudo groupadd docker  # sudoなしで使えるようにする設定
    #sudo gpasswd -a vagrant docker  # sudoなしで使えるようにする設定
    #sudo systemctl restart docker

    # =================その他好きなもの===================
    # yaourt -S --noconfirm man-pages-ja-git  # 日本語man
    # sudo pacman -S --noconfirm fzf  # Simplistic interactive filtering tool
    # sudo pacman -S --noconfirm thefuck  # Corrects your previous console command
    # sudo pacman -S --noconfirm atool  # Managing file archives of various types
    # yaourt -S --noconfirm gitflow-avh-git  # git-flow tools
    # sudo pacman -S --noconfirm python-pygments pygmentize  # Python syntax highlighter



    # =================shell環境構築===================
    ## =================dotfilesのクローン===================
    #git clone --recursive --depth 1 https://github.com/u1and0/dotfiles.git
    #cd ${HOME}/dotfiles  # クローンしたすべてのファイルをホームへ移動
    #for i in `ls -A`
    #do
    #    mv -f $i ${HOME}
    #done
    ## `mv`の代わりに`cp`を使っても良いが、`cp *`だけだとドットファイル移動できないので、
    ## `cp .*`も使う必要あり。冗長的なので`ls -A`と`mv`で一回で移動できるようにしました。
    #cd ${HOME} && rmdir dotfiles


    ## =================ログインshellをzshに変更===================
    #sudo chsh vagrant -s /usr/bin/zsh

    # ================End of bootstraping====================
    # 実行したときの時間書き込み
    date | sudo tee /etc/bootstrapped
    echo "==> Done."
    echo "===> sudo reboot"
}
main

