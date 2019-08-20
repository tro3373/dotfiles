@echo off
cd %USERPROFILE%\.unxh\.dot\misc\vagrant\arch
cd
REM delete /
set DT=%date:/=%
REM delete :
set TM=%time::=%
REM replace space to 0
set TM=%TM: =0%
REM substring 0-4
set TM=%TM:~0,4%
set DST=%DT%_%TM%_arch.box
echo Executing... vagrant package --output %DST%
REM vagrant package --output %DST%
REM exit
set /P read="Done. Press any key to exit..."
