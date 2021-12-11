@echo off
REM echo Enabling long path..
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\enable_long_path.ps1
REM @powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process .\enable_long_path.ps1 -Verb runas"
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process powershell.exe -Verb runas"
REM echo Done.
REM pause > nul
exit
