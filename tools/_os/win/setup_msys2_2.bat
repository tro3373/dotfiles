@echo off
setlocal

set user=%username%
set msys64root=C:%HOMEPATH%\AppData\Local\Msys64
set bin=%msys64root%\usr\bin
set msys2_shell=%msys64root%\msys2_shell.cmd
set fstab=%msys64root%\etc\fstab
set hosts=%msys64root%\etc\hosts
set unxrel=.unxh

if not exist "%msys64root%" (
    echo No msys root dir. %msys64root%
    exit 1
)
if not exist "%msys2_shell%" (
    echo No msys2_shell.cmd. %msys2_shell%
    exit 1
)
if not exist "%fstab%" (
    echo No fstab. %fstab%
    exit 1
)
if not exist C:\Users\%username%\%unxrel% (
    md C:\Users\%username%\%unxrel%
)

if not exist "%hosts%" (
    %msys2_shell%
    echo _______
    echo First setup Done. ReRun
) else if not exist "C:%HOMEPATH%\%unxrel%\.profile" (
    rem Mount home to wins specified path
    rem %bin%\bash.exe -c "/usr/bin/mv /home/%username%/* /c/Users/%username%/%unxrel%/"
    %bin%\bash.exe -c "/usr/bin/mv /home/%username%/.??* /c/Users/%username%/%unxrel%/"
    %bin%\bash.exe -c "/usr/bin/echo C:/Users/%username%/%unxrel% /home/%username% >> /etc/fstab"
    echo _______
    echo Second setup Done. home is changed. ReRun
) else if not exist "%msys64root%\var\cache" (
    rem Update pakages
    %bin%\bash.exe -c "/usr/bin/pacman -Sy pacman --noconfirm && /usr/bin/pacman -Syu --noconfirm && /usr/bin/pacman -Su --noconfirm && /usr/bin/echo Done Update"
    echo _______
    echo Third setup Done. pakages updated. ReRun
) else if not exist "%msys64root%\mingw64\bin\ag.exe" (
    rem Install pakages
    rem base-devel: grep make
    rem msys2-devel: gcc
    rem mingw-w64-x86_64-toolchain mingw-w64-x86_64-gcc
    %bin%\bash.exe -c "/usr/bin/pacman -S --noconfirm base-devel msys2-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain man zsh vim git winpty svn wget sed diffutils tar unzip patch bc mingw-w64-x86_64-ag"
    rem Change login shell to zsh
    %bin%\bash.exe -c "/usr/bin/sed -ri -e 's/bash/zsh/g' /msys2_shell.cmd"
    rem SHELL variable change to zsh
    %bin%\bash.exe -c "/usr/bin/sed -ri -e 's/^.*(profile_d zsh)/  \1\n  SHELL=`which zsh`/g' /etc/profile"
    rem symlink enable
    %bin%\bash.exe -c "/usr/bin/sed -ri -e 's/rem set MSYS=win/set MSYS=win/g' /msys2_shell.cmd"
    echo _______
    echo Forth setup Done. ReRun
) else (
    echo _______
    echo All process Done.
)

endlocal
pause

