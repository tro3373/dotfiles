# sample.bat

```bat
@echo off
set JOBPRM=%*

:main
    call :init
    call :logic
exit /b 0

:init
    set RC=0
    set DT=%date:/=%
    set TM=%time::=%
    set TM=%TM: =0%
    set JOBNM=setup.bat
    rem バッチ自身に、d:ドライブ付,p:パス付で表したもの
    set DIR_JOB=%~dp0
    rem パスの最後に￥が入る為、以下コマンドで、０番目〜（最後-１）までを抽出
    set DIR_JOB=%DIR_JOB:~0,-1%
    set BKUPMAX=8
    set BKUPROOTDIR=%DIR_JOB%\backup
    set BKUPDIR=%BKUPROOTDIR%\%DT%
    mkdir %BKUPDIR%
    set DIR_LOG=%BKUPDIR%
    set BKUPFLNM=database_name.dmp
    set LOG=%DIR_LOG%\%JOBNM%.%DT%.%TM%.log
rem    set LOG=%DIR_LOG%\%JOBNM%.%DT%.log
rem    set DIR_NONE=D:\NONE
rem    set DIR_EXST=D:\EXST
    set index=0
exit /b 0


:logic
    call :logs **************************************
    call :logs * Start
    call :logs **************************************
    set SUBFNK_NM=Main[%0]
rem    call :getDirectories
rem    call :moveFilesMain
    call :backupDatabase
    call :deleteOldFiles
    call :nomalend
exit /b 0


rem *******************************************************
rem Postgresql
rem *******************************************************
:backupDatabase
    set SUBFNK_NM=BackupDatabase[%0]
    call :logs %SUBFNK_NM=DB%Start
    call :forceexccmd pg_dump -h localhost -p 5432 -U database_name -f %BKUPDIR%\%BKUPFLNM% database_name
    call :logs %SUBFNK_NM=DB%Complete
exit /b 0

rem *******************************************************
rem DeleteBackupData
rem *******************************************************
:deleteOldFiles
    set SUBFNK_NM=DeleteBackupData[%0]
    call :logs %SUBFNK_NM=DB%Start
    setlocal enabledelayedexpansion
    set i=0
    for /f "delims=;" %%A in ('dir %BKUPROOTDIR% /b/o-n') do (
        set /a i=!i!+1
        call :removeDir !i! %BKUPROOTDIR%\%%A
    )
    endlocal
    call :logs %SUBFNK_NM=DB%Complete
exit /b 0

rem *******************************************************
rem Remove Directory
rem *******************************************************
:removeDir
    if %1 gtr %BKUPMAX% (
        call :forceexccmd rd /s /q %2
    )
exit /b 0


rem *******************************************************
rem execute cmd
rem *******************************************************
:exccmd
    set TMPCMD=%*
    call :logs execute_cmd=[%TMPCMD%]
    %TMPCMD%>>%LOG% 2>&1
    if not "%errorlovel%" == "0" (
        call :logs abort [%TMPCMD%] return code="%errorlovel%"
        call :abnomalend 1
    )
exit /b 0


rem *******************************************************
rem Force execute cmd
rem *******************************************************
:forceexccmd
    set TMPCMD=%*
    call :logs execute_cmd=[%TMPCMD%]
    %TMPCMD%>>%LOG% 2>&1
exit /b 0


rem *******************************************************
rem Output Logs
rem *******************************************************
:logs
    SET DTLOG=%date:/=%
    SET TMLOG=%time::=%
    echo %DTLOG% %TMLOG% %JOBNM% %*
    echo %DTLOG% %TMLOG% %JOBNM% %*>>%LOG%
exit /b 0


rem *******************************************************
rem Normal End
rem *******************************************************
:nomalend
    call :logs **************************************
    call :logs * Done
    call :logs **************************************
exit 0


rem *******************************************************
rem Abnormal End
rem *******************************************************
:abnomalend
    call :logs **************************************
    call :logs * Abort
    call :logs **************************************
    call :logs aborte_func=[%SUBFNK_NM%]
    set RC=%1
exit %1
```