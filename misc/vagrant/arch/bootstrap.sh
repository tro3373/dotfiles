#!/usr/bin/env bash

bootstrapf=/etc/bootstrapped
has() { which ${1} >& /dev/null; }

backup() {
    local ret=1
    for f in "$@"; do
        sudo test ! -e $f && continue
        local dst=$f.org
        sudo test -e $dst && continue
        sudo cp -rf $f $dst
        ret=0
    done
    return $ret
}
initialize() {
    if test -f $bootstrapf; then
        return 1
    fi
    set -e
    return 0
}
finalize() {
    date | sudo tee $bootstrapf >/dev/null
}

setup_network() {
    local net_rule=/etc/udev/rules.d/66-persistent-net.rules
    if sudo grep eth1 $net_rule>/dev/null; then
        return
    fi
    cat << EOF |sudo tee -a $net_rule >/dev/null
# from enp0s8 to eth1
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="08:00:27:74:f7:e0", NAME="eth1"
EOF
    #if ! sudo test -e /etc/netctl/eth0; then
    #    return
    #fi
    #sudo netctl disable eth0
}

setup_keyboard() {
    echo "==> setupping keyboard .."
    local val=jp106
    if localectl |grep "Keymap" |grep $val >/dev/null; then
        return
    fi
    sudo localectl set-keymap $val
}
setup_lang_locale() {
    echo "==> setupping lang locale .."
    local val="Asia/Tokyo"
    if ! timedatectl |grep "Time zone" |grep "$val" >/dev/null; then
        sudo timedatectl set-timezone Asia/Tokyo  # タイムゾーン設定
    fi
    if backup /etc/locale.conf; then
        cat << 'EOF' | sudo tee /etc/locale.conf >/dev/null
LANG=en_US.UTF8
LC_NUMERIC=en_US.UTF8
LC_TIME=en_US.UTF8
LC_MONETARY=en_US.UTF8
LC_PAPER=en_US.UTF8
LC_MEASUREMENT=en_US.UTF8
EOF
    fi
    if backup /etc/locale.gen; then
        cat << EOF | sudo tee /etc/locale.gen >/dev/null
en_US.UTF-8 UTF-8
ja_JP.UTF-8 UTF-8
EOF
        sudo locale-gen
    fi
}

setup_samba() {
    if ! has samba; then
        sudo powerpill -S samba
    fi
    if sudo test -e /etc/samba/smb.conf; then
        return
    fi
    sudo wget "https://git.samba.org/samba.git/?p=samba.git;a=blob_plain;f=examples/smb.conf.default;hb=HEAD" -O /etc/samba/smb.conf.org
    cat << EOF |sudo tee -a /etc/samba/smb.conf >/dev/null
[global]
    # TBD ファイルを使用
    passdb backend = tdbsam
    # アーカイブ属性と実行属性を相互変換しない
    map archive = no
    unix charset = UTF-8
    dos charset = CP932

    #workgroup = WORKGROUP
    #local master = yes
    dns proxy = no

    hosts allow = 127.0.0.0/8 192.168.33.0/24
    host deny = all

    security = user
    map to guest = Bad User
    guest account = vagrant
    #unix password sync = yes

    create mode = 0644
    directory mode = 0755
[share]
   path = /home/vagrant
   writeable = true
   force user = vagrant
   force group = vagrant
   public = true
   #guest ok = yes # public の alias
   guest only = yes
EOF
    #sudo smbpasswd vagrant
    sudo chmod 775 /home/vagrant
    sudo systemctl enable smbd nmbd
    sudo systemctl start smbd nmbd
}


setup_packages() {
    echo "==> setupping packages .."
    # パッケージ更新が X用のパッケージが邪魔してできないので、先にアンインストール
    sudo pacman -R --noconfirm xorg-fonts-misc xorg-font-utils xorg-server xorg-server-common xorg-bdftopcf libxfont libxfont2
    # パッケージ更新
    sudo pacman -Syyu --noconfirm
    sudo pacman -S --noconfirm libxfont2
    if ! has yaourt; then
        sudo pacman -S --noconfirm yaourt
    fi
    if ! has reflector; then
        sudo pacman -S --noconfirm reflector
    fi
    if backup /etc/pacman.d/mirrorlist; then
        sudo reflector --verbose --country 'Japan' -l 10 --sort rate --save /etc/pacman.d/mirrorlist
    fi
    if ! has powerpill; then
        gpg --recv-keys --keyserver hkp://pgp.mit.edu 1D1F0DC78F173680
        yaourt -S --noconfirm powerpill  # Use powerpill instead of pacman. Bye pacman...
    fi
    ### =================powerpill SigLevel書き換え===================
    if backup /etc/pacman.conf; then
        sudo sed -i -e 's/Required DatabaseOptional/PackageRequired/' /etc/pacman.conf
    fi

    # パッケージ更新
    sudo powerpill -Syu --noconfirm
    yaourt -Syua --noconfirm


    # for clipboard
    sudo powerpill -S --noconfirm xsel
    yaourt -S --noconfirm xorg-server-xvfb

    # setup samba
    setup_samba

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
    # sudo cat << 'EOF' > ${HOME}/.xprofile
    # export GTK_IM_MODULE=fcitx
    # export QT_IM_MODULE=fcitx
    # export XMODIFIERS=”@im=fcitx”
    # EOF
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
}
setup_dots() {
    echo "==> setupping .dot .."
    [[ -e ~/.dot ]] && return
    curl -fSsL git.io/tr3s |sh
    cd ~/.dot/bin
    ./setup -e
}
setup_login_shell() {
    echo "==> setupping login shell .."
    ! has zsh && return
    sudo chsh vagrant -s /usr/bin/zsh
}
main() {
    ! initialize && return
    setup_network
    setup_keyboard
    setup_lang_locale
    setup_packages
    setup_login_shell
    setup_dots
    finalize
    echo "==> Done."
    echo "===> sudo reboot"
}
main
