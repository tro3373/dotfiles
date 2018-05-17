# Install arch linux to raspberry pi 3 via ubuntu

## Refs
- [Official](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3)
- [raspberry pi](https://wiki.archlinux.jp/index.php/Raspberry_Pi#Ethernet_.E3.82.92.E4.BD.BF.E3.82.8F.E3.81.9A.E3.81.AB_WLAN_.E3.82.92.E8.A8.AD.E5.AE.9A)

## Prepare
```sh
# ar: Ignoring unknown extended header keyword 'SCHILY.dev'
sudo apt-get install bsdtar
```

# Error
## bsdtar: Ignoring malformed pax extended attribute
- [Raspberry Pi 3にArch LinuxARM(2017年3月1日リリースARMｖ7)をインストール](https://itdecoboconikki.com/2017/03/18/raspberry-pi-3-arch-linux-arm-v7-2017-03-01-install/)

```sh
mkdir tmp && cd tmp
wget https://www.libarchive.org/downloads/libarchive-3.3.1.tar.gz
tar xzf libarchive-3.3.1.tar.gz
cd libarchive-3.3.1
./configure
make
sudo make install
```

## setup arch on raspberry
```sh
# package update
pacman -Syu
pacman -S lshw
reboot
```

### setup wifi static network

```sh
# disable ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/40-ipv6.conf
# power save mode off
iw wlan0 set power_save off
# check status
iwconfig wlan0

# static wifi setting
#cp /etc/netctl/examples/wireless-wpa /etc/netctl/profile
cp /etc/netctl/examples/wireless-wpa-static /etc/netctl/wlan
vi /etc/netctl/wlan
# test add profile
netctl start wlan
# enable add profile
netctl enable wlan

# static eth setting
cp /etc/netctl/examples/ethernet-static /etc/netctl/eth
vi /etc/netctl/eth
netctl start eth
netctl enable eth


# if not work
#systemctl status network
bash -c 'net link set eth0 down && netctl start profile-eth-static'

reboot
```

### setup system
```sh
loadkeys jp106
echo "KEYMAP=jp106" > /etc/vconsole.conf

# change root password
passwd

# locale setting
# uncomment en_US.UTF-8 UTF-8 and ja_JP.UTF-8 UTF-8
vi /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
export "LANG=en_US.UTF-8"

# date time
unlink /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# hostname
echo "arch-server" >/etc/hostname

# sudo
pacman -S sudo
# uncomment %wheel ALL=(ALL) NOPASSWD: ALL
visudo

# create sudo user
useradd -m -g wheel [hoge]
passwd hoge
```

### setup system
```sh
sudo pacman -S git
```



