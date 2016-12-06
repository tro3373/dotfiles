@echo off
set args="--remote-tab-silent %*"
if "%1" == "" (
    set args="."
)
set path=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;
rem set path=%HOMEPATH%\AppData\Local\Msys64\usr\bin;%path%
set path=%HOMEPATH%\AppData\Local\Msys64\usr\bin\ag.exe;%path%
set path=C:\Program Files\Git\cmd;%path%
set path=%HOMEPATH%\bin;%path%
start "" "C:%HOMEPATH%\tools\vim80-kaoriya-win64\gvim.exe %args%"

