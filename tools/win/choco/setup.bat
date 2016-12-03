@echo off

@where choco
if errorlevel 1 powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
cd /d %~dp0

rem sakura
rem gvim
rem cinst -y sourcetree
rem cinst -y svn
rem cinst -y tortoisesvn
rem cinst -y thunderbird
rem cinst -y msys2
rem cinst -y jdk8
rem cinst -y putty
rem cinst -y ruby
rem cinst -y python
rem cinst -y android-sdk
rem cinst -y vmwareplayer
rem cinst -y virtualbox
rem cinst -y vagrant
rem cinst -y mpc-hc
rem cinst -y teraterm
rem cinst -y winscp

cinst -y git.install
cinst -y 7zip
cinst -y winmerge
cinst -y GoogleChrome
cinst -y Firefox
cinst -y SublimeText3
cinst -y atom
cinst -y googlejapaneseinput

echo "Done"
pause

