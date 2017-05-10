@echo off
set args=%*
if "%1" == "" (
    set args=%cd%
)
rem Search file size over 1Gb..
forfiles -s -p "%args%" -c "cmd /c if @fsize gtr 1073741824 echo @FDATE @FSIZE @PATH"
