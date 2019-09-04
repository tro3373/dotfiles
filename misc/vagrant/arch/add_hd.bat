@echo off
rem https://qiita.com/sawanoboly/items/cbd056253a130a4b961e
rem https://flying-foozy.hatenablog.com/entry/20100616/1276697737

set vboxd="C:\Program Files\Oracle\VirtualBox"
set vboxm="C:\Program Files\Oracle\VirtualBox\VBoxManage"

%vboxm% list vms

echo Execute bellow to show vm info
echo %vboxm% showvminfo arch_default_1536040035176_8754

echo Execute bellow to add 50G hd.
rem size 51400 MB -> 50G
echo "%vboxm%" createhd --filename addtional.vdi --size 51400 --variant Fixed

rem exit
set /P read="Done. Press any key to exit..."
