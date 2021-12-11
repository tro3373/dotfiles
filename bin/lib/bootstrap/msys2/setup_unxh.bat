@echo off

move %USERPROFILE%\scoop\persist\msys2\home\%USERNAME% %USERPROFILE%\.unxh
mklink /D %USERPROFILE%\scoop\persist\msys2\home\%USERNAME% %USERPROFILE%\.unxh
pause > nul
exit
