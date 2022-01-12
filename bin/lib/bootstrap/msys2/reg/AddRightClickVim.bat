@echo off
reg add HKCU\Software\Classes\*\shell\Vim /t REG_SZ /ve /d "Edit with Vim (&V)"
reg add HKCU\Software\Classes\*\shell\Vim\command /t REG_EXPAND_SZ /ve /d %%USERPROFILE%%"\scoop\apps\vim-kaoriya\current\gvim.exe -p --remote-tab-silent \"%%1\""
pause > nul
exit
