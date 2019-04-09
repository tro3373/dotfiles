@echo off

@where choco
if errorlevel 1 powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
cd /d %~dp0

cinst -y git.install --params "'/Tasks:quicklaunch'"
cinst -y 7zip
cinst -y winmerge --params "'/Tasks:quicklaunch,fileassoc,sendto'"
cinst -y sakuraeditor --params "'/Tasks:quicklaunch,fileassoc,startup,sendto'"
cinst -y googlechrome --params "'/Tasks:quicklaunch,fileassoc'"
cinst -y firefox
cinst -y googlejapaneseinput
cinst -y tortoisesvn
cinst -y mpc-hc
cinst -y winscp
cinst -y virtualbox --params "'/Tasks:quicklaunch'"
cinst -y vagrant

rem cinst -y msys2 --params "'/Tasks:quicklaunch'"

rem cinst -y jdk8
rem cinst -y android-sdk
rem cinst -y vmwareplayer
rem cinst -y teraterm
rem cinst -y SublimeText3
rem cinst -y atom
rem cinst -y gvim
rem cinst -y sourcetree
rem cinst -y svn
rem cinst -y thunderbird
rem cinst -y putty
rem cinst -y ruby
rem cinst -y python


echo "Done"
pause

