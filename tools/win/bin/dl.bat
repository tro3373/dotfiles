@echo off

if "%1" == "" (
    call :error
else if "%2" == "" (
    call :error
)
bitsadmin.exe /TRANSFER dl_job %1 "%2"
exit 0

:error
    echo "bitsadmin.exe /TRANSFER [�W���u��] [arg1:�����[�gURL] [arg2:�_�E�����[�h��]"
    set /P read="Press any key..."
exit 2

