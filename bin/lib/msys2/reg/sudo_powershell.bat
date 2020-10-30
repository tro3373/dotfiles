@echo off
echo Enabling long path..
rem powershell -NoProfile -ExecutionPolicy Unrestricted .\enable_long_path.ps1
rem @powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process .\enable_long_path.ps1 -Verb runas"
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process powershell.exe -Verb runas"
echo Done.
pause > nul
exit
