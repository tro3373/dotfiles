@echo off
set JOBPRM=%*
rem !!WARNING!!
rem   Symbolic link command is aborted when you start command prompt normal user. exec cmd as Administrator.

:main
    call :init
    call :logic
    call :nomalend
exit /b 0

:logic
    call :logs **************************************
    call :logs * Start
    call :logs **************************************
    set SUBFNK_NM=Main[%0]
rem    call :add_paths
    call :makedirs
    call :makelinks
rem    call :chocolatey
    call :sakura
    call :sublime3
    call :atom
    call :git
    call :vim
exit /b 0

:init
    set RC=0
    set DT=%date:/=%
    set TM=%time::=%
    set TM=%TM: =0%
    set JOBNM=setup.bat
    rem バッチ自身に、d:ドライブ付,p:パス付で表したもの
    set DOTPATH=%~dp0
    rem パスの最後に￥が入る為、以下コマンドで、０番目〜（最後-１）までを抽出
    set DOTPATH=%DOTPATH:~0,-1%
    set BKUPMAX=8
    set BKUPROOTDIR=%DOTPATH%\bkup
    set BKUPDIR=%BKUPROOTDIR%\%DT%-%TM%
    md %BKUPDIR%
    set DIR_LOG=%BKUPDIR%
    set BKUPFLNM=database_name.dmp
    set LOG=%DIR_LOG%\%JOBNM%.%DT%.%TM%.log
rem    set LOG=%DIR_LOG%\%JOBNM%.%DT%.log
rem    set DIR_NONE=D:\NONE
rem    set DIR_EXST=D:\EXST
    set index=0
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
rem execute cmd
rem *******************************************************
:exccmd
    set TMPCMD=%*
    call :logs execute_cmd=[%TMPCMD%]
    %TMPCMD%>>%LOG% 2>&1
    if not "%errorlevel%" == "0" (
        call :logs abort [%TMPCMD%] return code="%errorlevel%"
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

rem 1:target_dir
:mkdir_ifnotexist
    call :logs "[mkdir_ifnotexist] %*"
    if not exist %1 (
        call :exccmd md %1
    )
exit /b 0

rem 1:rinkto_parent
rem 2:rinkto_file
rem 3:rinkfrom_file
rem 4:0:file,1:dir
:backuppable_link
    call :logs "[backuppable_link] %*"
    if exist "%1\%2" (
        call :logs "%1\%2 is exists. do nothing."
        exit /b 0
    )
    call :mkdir_ifnotexist %1
    if exist %1\%2 (
        call :exccmd move %1\%2 %BKUPDIR%
    )
    if "%4" == "0" (
        rem file
        call :exccmd mklink %1\%2 %3
    ) else (
        rem dir
        call :exccmd mklink /D %1\%2 %3
    )
exit /b 0

:add_paths
    set SUBFNK_NM=add_paths
    setx /M path "%path%;c:%homepath%\bin"
    setx /M pathext "%pathext%;lnk"
exit /b 0

:makedirs
    set SUBFNK_NM=makedirs
    call :mkdir_ifnotexist "%HOMEPATH%\bin"
    call :mkdir_ifnotexist "%HOMEPATH%\tools"
    call :mkdir_ifnotexist "%HOMEPATH%\works"
exit /b 0

:makelinks
    set LIBBIN="%DOTPATH%\tools\win\bin"
    for /f "delims=;" %%A in ('dir %LIBBIN% /b/o-n') do (
        call :backuppable_link "%HOMEPATH%\bin" "%%A" "%LIBBIN%\%%A" 0
    )

    call :backuppable_link "%HOMEPATH%" ".bashrc" "%DOTPATH%\apps\zsh\win\.bashrc" 0
    call :backuppable_link "%HOMEPATH%" ".ctags" "%DOTPATH%\apps\ctags\.ctags" 0
    call :backuppable_link "%HOMEPATH%" ".agignore" "%DOTPATH%\apps\ag\.agignore" 0
exit /b 0

:chocolatey
    set SUBFNK_NM=chocolatey
    call :exccmd @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
    call :exccmd cinst packages.config
exit /b 0

:sakura
    set SUBFNK_NM=sakura
    call :backuppable_link "%HOMEPATH%\AppData\Roaming\sakura" "sakura.ini" "%DOTPATH%\tools\win\sakura\sakura.ini" 0
exit /b 0

:sublime3
    set SUBFNK_NM=sublime3
    call :backuppable_link "%HOMEPATH%\AppData\Roaming\Sublime Text 3\Packages" "User" "%DOTPATH%\tools\sublime\User" 1
    rem ---------------------------------
    rem And Do Below.
    rem 1. Start Sublime Text3
    rem 2. Ctrl + `
    rem 3. Paste this or copy from here. https://packagecontrol.io/installation#st3
    rem    import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
exit /b 0

:atom
    set SUBFNK_NM=atom
    call :backuppable_link "%HOMEPATH%" ".atom" "%DOTPATH%\tools\atom\.atom" 1
exit /b 0

:git
    set SUBFNK_NM=git
    call :backuppable_link "%HOMEPATH%" ".git_template" "%DOTPATH%\apps\git\.git_template" 1
    rem git config --global user.name sample_username
    rem git config --global user.email sample_email@domain.com
    git config --global core.editor "vim -c 'set fenc=utf-8'"
    git config --global core.quotepath false
    git config --global color.ui auto
    git config --global push.default simple
    git config --global http.sslVerify false
    git config --global core.preloadindex true
    git config --global core.fscache true
    rem Windows set filemode to false
    git config --global core.filemode false
    git config --global alias.co checkout
    git config --global alias.cm commit
    git config --global alias.st status
    git config --global alias.br branch
    git config --global alias.lgo "log --oneline"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.lga "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.tar "archive --format=tar HEAD -o"
    git config --global alias.tgz "archive --format=tgz HEAD -o"
    git config --global alias.zip "archive --format=zip HEAD -o"
    git config --global alias.or orphan
    git config --global init.templatedir '~/.git_template'
    git config --global alias.ignore '!gi() { curl -L -s https://www.gitignore.io/api/$@ ;}; gi'
exit /b 0

:vim
    set SUBFNK_NM=vim
    call :backuppable_link "%HOMEPATH%" "_gvimrc" "%DOTPATH%\apps\vim\.gvimrc" 0
    call :backuppable_link "%HOMEPATH%" "_vimrc" "%DOTPATH%\apps\vim\.vimrc" 0
    call :backuppable_link "%HOMEPATH%" ".vim" "%DOTPATH%\apps\vim\.vim" 1

    if not exist "%HOMEPATH%/.vim/plugged/vim-plug" (
        call :exccmd md "%HOMEPATH%/.vim/plugged/vim-plug"
    )
    if not exist "%HOMEPATH%/.vim/plugged/vim-plug/autoload" (
        call :exccmd git clone https://github.com/junegunn/vim-plug.git "%HOMEPATH%/.vim/plugged/vim-plug/autoload"
    )
exit /b 0

