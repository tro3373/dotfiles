@echo off
powershell start-process -verb runas "$env:USERPROFILE/scoop/apps/msys2/current/msys2_shell.cmd" -ArgumentList '-shell,zsh,-mingw64'
exit
