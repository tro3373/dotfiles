@echo off
set args=%*
if "%1" == "" (
    set args=%cd%
)
set gvim_dir=vim80-kaoriya-win64
set path=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;
rem GitGutter Not work
rem set path=%HOMEPATH%\AppData\Local\Msys64\usr\bin;%path%
rem rem Fullpath Not work
rem set path=%HOMEPATH%\AppData\Local\Msys64\usr\bin\git.exe;%path%
set path=C:\Program Files\Git\cmd;%path%
set path=%HOMEPATH%\AppData\Local\Msys64\Mingw64\bin;%path%
set path=%HOMEPATH%\bin;%path%
rem echo %path%
start "" C:%HOMEPATH%\tools\%gvim_dir%\gvim.exe --remote-tab-silent %args%

