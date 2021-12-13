@echo off

:main
  call :enable
  REM call :disable
  call :nomalend
exit /b 0

:enable
  rem https://docs.microsoft.com/ja-jp/windows/wsl/install-win10
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
  set /P read="You need to reboot andDownload And install https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi and Press Key..."
  REM wsl --set-default-version 2
  REM wsl --list --online
  REM wsl --install -d Ubuntu-20.04
  REM wsl --set-version Ubuntu-20.04 2
exit /b 0

:disable
  Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
  Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
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


rem @echo off
rem set JOBPRM=%*
rem rem !!WARNING!!
rem rem   Symbolic link command is aborted when you start command prompt normal user. exec cmd as Administrator.
rem
rem :main
rem     call :init
rem     call :logic
rem     call :nomalend
rem exit /b 0
rem
rem :logic
rem     call :logs **************************************
rem     call :logs * Start
rem     call :logs **************************************
rem     set SUBFNK_NM=Main[%0]
rem rem    call :add_paths
rem     call :makedirs
rem     call :makelinks
rem rem    call :chocolatey
rem     call :sakura
rem     call :sublime3
rem     call :atom
rem     call :git
rem     call :vim
rem exit /b 0
rem
rem :init
rem     set RC=0
rem     set DT=%date:/=%
rem     set TM=%time::=%
rem     set TM=%TM: =0%
rem     set JOBNM=setup.bat
rem     rem バッチ自身に、d:ドライブ付,p:パス付で表したもの
rem     set DOTPATH=%~dp0
rem     rem パスの最後に￥が入る為、以下コマンドで、０番目〜（最後-１）までを抽出
rem     set DOTPATH=%DOTPATH:~0,-1%
rem     set BKUPMAX=8
rem     set BKUPROOTDIR=%DOTPATH%\bkup
rem     set BKUPDIR=%BKUPROOTDIR%\%DT%-%TM%
rem     md %BKUPDIR%
rem     set DIR_LOG=%BKUPDIR%
rem     set BKUPFLNM=database_name.dmp
rem     set LOG=%DIR_LOG%\%JOBNM%.%DT%.%TM%.log
rem rem    set LOG=%DIR_LOG%\%JOBNM%.%DT%.log
rem rem    set DIR_NONE=D:\NONE
rem rem    set DIR_EXST=D:\EXST
rem     set index=0
rem exit /b 0
rem
rem *******************************************************
rem Output Logs
rem *******************************************************
:logs
    SET DTLOG=%date:/=%
    SET TMLOG=%time::=%
    echo %DTLOG% %TMLOG% %JOBNM% %*
    echo %DTLOG% %TMLOG% %JOBNM% %*>>%LOG%
exit /b 0
rem
rem rem *******************************************************
rem rem execute cmd
rem rem *******************************************************
rem :exccmd
rem     set TMPCMD=%*
rem     call :logs execute_cmd=[%TMPCMD%]
rem     %TMPCMD%>>%LOG% 2>&1
rem     if not "%errorlevel%" == "0" (
rem         call :logs abort [%TMPCMD%] return code="%errorlevel%"
rem         call :abnomalend 1
rem     )
rem exit /b 0
rem
rem rem *******************************************************
rem rem Force execute cmd
rem rem *******************************************************
rem :forceexccmd
rem     set TMPCMD=%*
rem     call :logs execute_cmd=[%TMPCMD%]
rem     %TMPCMD%>>%LOG% 2>&1
rem exit /b 0

rem rem 1:target_dir
rem :mkdir_ifnotexist
rem     call :logs "[mkdir_ifnotexist] %*"
rem     if not exist %1 (
rem         call :exccmd md %1
rem     )
rem exit /b 0
rem
rem rem 1:rinkto_parent
rem rem 2:rinkto_file
rem rem 3:rinkfrom_file
rem rem 4:0:file,1:dir
rem :backuppable_link
rem     call :logs "[backuppable_link] %*"
rem     if exist "%1\%2" (
rem         call :logs "%1\%2 is exists. do nothing."
rem         exit /b 0
rem     )
rem     call :mkdir_ifnotexist %1
rem     if exist %1\%2 (
rem         call :exccmd move %1\%2 %BKUPDIR%
rem     )
rem     if "%4" == "0" (
rem         rem file
rem         call :exccmd mklink %1\%2 %3
rem     ) else (
rem         rem dir
rem         call :exccmd mklink /D %1\%2 %3
rem     )
rem exit /b 0
rem
rem :add_paths
rem     set SUBFNK_NM=add_paths
rem     setx /M path "%path%;c:%homepath%\bin"
rem     setx /M pathext "%pathext%;lnk"
rem exit /b 0
rem
rem :makedirs
rem     set SUBFNK_NM=makedirs
rem     call :mkdir_ifnotexist "%HOMEPATH%\bin"
rem     call :mkdir_ifnotexist "%HOMEPATH%\tools"
rem     call :mkdir_ifnotexist "%HOMEPATH%\works"
rem exit /b 0
rem
rem :makelinks
rem     set LIBBIN="%DOTPATH%\tools\_os\win\bin"
rem     for /f "delims=;" %%A in ('dir %LIBBIN% /b/o-n') do (
rem         call :backuppable_link "%HOMEPATH%\bin" "%%A" "%LIBBIN%\%%A" 0
rem     )
rem
rem     call :backuppable_link "%HOMEPATH%" ".bashrc" "%DOTPATH%\apps\zsh\win\.bashrc" 0
rem     call :backuppable_link "%HOMEPATH%" ".ctags" "%DOTPATH%\apps\ctags\.ctags" 0
rem     call :backuppable_link "%HOMEPATH%" ".agignore" "%DOTPATH%\apps\ag\.agignore" 0
rem exit /b 0
rem
rem :chocolatey
rem     set SUBFNK_NM=chocolatey
rem     call :exccmd @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
rem     call :exccmd cinst packages.config
rem exit /b 0
rem
rem :sakura
rem     set SUBFNK_NM=sakura
rem     call :backuppable_link "%HOMEPATH%\AppData\Roaming\sakura" "sakura.ini" "%DOTPATH%\tools\_os\win\sakura\sakura.ini" 0
rem exit /b 0
rem
rem :sublime3
rem     set SUBFNK_NM=sublime3
rem     call :backuppable_link "%HOMEPATH%\AppData\Roaming\Sublime Text 3\Packages" "User" "%DOTPATH%\tools\sublime\User" 1
rem     rem ---------------------------------
rem     rem And Do Below.
rem     rem 1. Start Sublime Text3
rem     rem 2. Ctrl + `
rem     rem 3. Paste this or copy from here. https://packagecontrol.io/installation#st3
rem     rem    import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
rem exit /b 0
rem
rem :atom
rem     set SUBFNK_NM=atom
rem     call :backuppable_link "%HOMEPATH%" ".atom" "%DOTPATH%\tools\atom\.atom" 1
rem exit /b 0
rem
rem :git
rem     set SUBFNK_NM=git
rem     call :backuppable_link "%HOMEPATH%" ".git_template" "%DOTPATH%\apps\git\.git_template" 1
rem     rem git config --global user.name sample_username
rem     rem git config --global user.email sample_email@domain.com
rem     git config --global core.editor "vim -c 'set fenc=utf-8'"
rem     git config --global core.quotepath false
rem     git config --global color.ui auto
rem     git config --global push.default simple
rem     git config --global http.sslVerify false
rem     git config --global core.preloadindex true
rem     git config --global core.fscache true
rem     rem Windows set filemode to false
rem     git config --global core.filemode false
rem     git config --global alias.co checkout
rem     git config --global alias.cm commit
rem     git config --global alias.st status
rem     git config --global alias.br branch
rem     git config --global alias.lgo "log --oneline"
rem     git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
rem     git config --global alias.lga "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
rem     git config --global alias.tar "archive --format=tar HEAD -o"
rem     git config --global alias.tgz "archive --format=tgz HEAD -o"
rem     git config --global alias.zip "archive --format=zip HEAD -o"
rem     git config --global alias.or orphan
rem     git config --global init.templatedir '~/.git_template'
rem     git config --global alias.ignore '!gi() { curl -L -s https://www.gitignore.io/api/$@ ;}; gi'
rem exit /b 0
rem
rem :vim
rem     set SUBFNK_NM=vim
rem     call :backuppable_link "%HOMEPATH%" "_gvimrc" "%DOTPATH%\apps\vim\.gvimrc" 0
rem     call :backuppable_link "%HOMEPATH%" "_vimrc" "%DOTPATH%\apps\vim\.vimrc" 0
rem     call :backuppable_link "%HOMEPATH%" ".vim" "%DOTPATH%\apps\vim\.vim" 1
rem
rem     if not exist "%HOMEPATH%/.vim/plugged/vim-plug" (
rem         call :exccmd md "%HOMEPATH%/.vim/plugged/vim-plug"
rem     )
rem     if not exist "%HOMEPATH%/.vim/plugged/vim-plug/autoload" (
rem         call :exccmd git clone https://github.com/junegunn/vim-plug.git "%HOMEPATH%/.vim/plugged/vim-plug/autoload"
rem     )
rem exit /b 0
