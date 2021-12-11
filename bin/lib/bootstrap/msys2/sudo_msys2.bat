@echo off
REM set MSYS=winsymlinks:nativestrict
powershell start-process -verb runas "$env:USERPROFILE/scoop/apps/msys2/current/msys2_shell.cmd"
REM powershell start-process "cmd.exe /c set TERM=xterm-256color && set MSYS=winsymlinks:nativestrict && %userprofile%/scoop/apps/msys2/current/msys2_shell.cmd -defterm -no-start -full-path -shell bash" -verb runas
REM powershell start-process "cmd.exe /c set MSYS=winsymlinks:nativestrict && %userprofile%/scoop/apps/msys2/current/msys2_shell.cmd" -verb runas
REM powershell start-process "cmd.exe /c '%userprofile%/scoop/apps/msys2/current/msys2_shell.cmd'" -verb runas
REM powershell start-process "cmd.exe /c $env:USERPROFILE/scoop/apps/msys2/current/msys2_shell.cmd" -verb runas
exit
