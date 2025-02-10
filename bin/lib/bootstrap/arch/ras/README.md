# setup arch linux on raspberry pi

## 1. Edit pub and bootstrap.conf

```bash
cp ~/.ssh/id_rsa.pub ./pub
```

```bootstrap.conf
ip=192.168.11.xx
host=xxx
pass=xxx
wlan_ssid=xxx
wlan_psk=xxx
```

## 2. Create sd

Only support linux.
setup sd card to system, and check device id and execute

```
sudo ./create_sd /dev/sda -e
```

## 3. Run in raspberry pi booted from sd

```
su - root
cd bin
./start_bootstrap
# Execute twice.
#   => once kernel updated, rpi will be rebooted.
```
