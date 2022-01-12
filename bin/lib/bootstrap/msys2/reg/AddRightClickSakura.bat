@echo off
reg add HKCU\Software\Classes\*\shell\Sakura /t REG_SZ /ve /d "Edit with Sakura"
reg add HKCU\Software\Classes\*\shell\Sakura\command /t REG_EXPAND_SZ /ve /d %%USERPROFILE%%"\scoop\apps\sakura-editor\current\sakura.exe \"%%1\""
pause > nul
exit
