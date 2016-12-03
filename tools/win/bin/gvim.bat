@echo off
set args="--remote-tab-silent %*"
if "%1" == "" (
    set args="."
)
set HOME=C:%HOMEPATH%\works
rem zsh 動作しない
set SHELL=C:%HOMEPATH%\AppData\Local\msys64\usr\bin\zsh
start "" "C:%HOMEPATH%\tools\vim80-kaoriya-win64\gvim.exe %args%"

