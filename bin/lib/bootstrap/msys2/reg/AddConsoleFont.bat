@echo off
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont" /v "932.0" /t REG_SZ /d "HackGen Console"
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont" /v "932.1" /t REG_SZ /d "Osaka-Mono"
pause > nul
exit
