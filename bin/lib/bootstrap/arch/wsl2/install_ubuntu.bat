@echo off

:main
  call :install
  call :nomalend
exit /b 0

:install
  wsl --set-default-version 2
  wsl --list --online
  wsl --install -d Ubuntu-20.04
exit /b 0

rem *******************************************************
rem Normal End
rem *******************************************************
:nomalend
    call :logs **************************************
    call :logs * Done
    call :logs **************************************
    set /P read="Press Key..."
exit /b 0

rem *******************************************************
rem Abnormal End
rem *******************************************************
:abnomalend
    call :logs **************************************
    call :logs * Abort
    call :logs **************************************
    call :logs aborte_func=[%SUBFNK_NM%]
    set /P read="Press Key..."
    set RC=%1
exit %1

rem *******************************************************
rem Output Logs
rem *******************************************************
:logs
    SET DTLOG=%date:/=%
    SET TMLOG=%time::=%
    echo %DTLOG% %TMLOG% %JOBNM% %*
    echo %DTLOG% %TMLOG% %JOBNM% %*>>%LOG%
exit /b 0
