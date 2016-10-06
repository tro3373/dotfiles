@echo off
set args="--remote-tab-silent %*"
if "%1" == "" (
    set args="."
)
start "" "%HOMEPATH%\tools\vim80-kaoriya-win64\gvim.exe %args%"

