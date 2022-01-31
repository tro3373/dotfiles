# setup arch linux on x86_64
## 1. create live usb

Only support linux.
setup usb to system, and check device id and execute

```
./create_live_usb
```

## 2. boot from live usb and setup live

1. First, Read option `1` sequence(`create_fs#setup_live`) and excute commands starts with `:` line.
2. Second, Send create_fs, create_fs.conf to live usb
```
scp create_fs create_fs.conf root@{live_usb_ip}:/root/
```

## 3. create fs via live usb over ssh from local

```
ssh root@{live_usb_ip}
./create_fs 2
# after chroot
./create_fs 3
```
