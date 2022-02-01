# SSH use cli tips.

## Compressed file transfer
```sh
tar czf - /home/localuser/filefolder | ssh remote-machine@ip.address.of.remote.machine tar -xvzf -C /home/remoteuser/
```

## Running a local script on a remote machine (or remote on local)
```sh
ssh remoteuser@ip.address.of.server 'bash -s' < scriptfile.sh
```

## Remote hard drive backup
```sh
sudo dd if=/dev/sda | ssh remoteuser@ip.addresss.of.remote.machine 'dd of=sda.img'
```

## Remote hard drive restoration
```sh
ssh remoteuser@ip.address.of.remote.machine 'dd if=sda.img' | dd of=/dev/sda
```

## Send a file
```sh
cat file | ssh remoteuser@ip.address.of.remote.machine "cat > remote"
# or use '<', '>'
ssh remoteuser@ip.address.of.remote.machine "cat > remote" < file
```

# References from...
- [How to Use SSH Pipes on Linux](https://www.maketecheasier.com/ssh-pipes-linux/)

## Variables
- '%d' (local user's home directory)
- '%h' (remote host name)
- '%l' (local host name)
- '%n' (host name as provided on the command line)
- '%p' (remote port)
- '%r' (remote user name)
- '%u' (local user name)
