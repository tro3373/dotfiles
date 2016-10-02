rem @echo off
set JOBPRM=%*
rem !!WARNING!!
rem   Symbolic link command is aborted when you start command prompt normal user. exec cmd as Administrator.

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
    set BKUPROOTDIR=%DIR_JOB%\bkup
    set BKUPDIR=%BKUPROOTDIR%\%DT%-%TM%
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
    call :makebin
rem    call :chocolatey
    call :sakura
rem    call :sublime3
rem    call :atom
rem    call :git
rem    call :bash
rem    call :vim
    call :nomalend
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

rem 1:rinkto_parent
rem 2:rinkto_file
rem 3:rinkfrom_file
rem 4:0:file,1:dir
:backuppable_link
    call :logs "%1 %2 %3 %4"
    call :forceexccmd md "%1"
    if exist "%1\%2" (
        call :exccmd move "%1\%2" "%BKUPDIR%"
    )
    if "%4" == "0" (
        rem file
        call :exccmd mklink "%1\%2" "%3"
    ) else (
        rem dir
        call :exccmd mklink /D "%1\%2" "%3"
    )
exit /b 0

:makebin
    rem bin ===========
    if not exist %HOMEPATH%"\bin" (
        call :exccmd mkdir %HOMEPATH%"\bin"
    )
    if not exist %HOMEPATH%"\bin\ln.bat" (
        call :exccmd mklink %HOMEPATH%"\bin\ln.bat" %HOMEPATH%"\dotfiles\tools\win\bin\ln.bat"
    )
exit /b 0

:chocolatey
    call :exccmd @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
    call :exccmd cinst packages.config
exit /b 0

:sakura
    call :logs "sakura"
    call :backuppable_link "%HOMEPATH%\AppData\Roaming\sakura" "sakura.ini" "%HOMEPATH%\dotfiles\tools\win\sakura\sakura.ini" 0
rem    cmd /c md %HOMEPATH%"\AppData\Roaming\sakura"
rem    if exist %HOMEPATH%"\AppData\Roaming\sakura\sakura.ini" (
rem        cmd /c del %HOMEPATH%"\AppData\Roaming\sakura\sakura.ini.bak"
rem        cmd /c ren %HOMEPATH%"\AppData\Roaming\sakura\sakura.ini" sakura.ini.bak
rem    )
rem    cmd /c mklink %HOMEPATH%"\AppData\Roaming\sakura\sakura.ini" %HOMEPATH%"\dotfiles\tools\win\sakura\sakura.ini"
exit /b 0

:sublime3
    call :backuppable_link "%HOMEPATH%\AppData\Roaming\Sublime Text 3\Packages" "User" "%HOMEPATH%\dotfiles\tools\sublime\User" 1
rem    rmdir -recurse %HOMEPATH%"\AppData\Roaming\Sublime Text 3\Packages\User"
rem    cmd /c mklink /D %HOMEPATH%"\AppData\Roaming\Sublime Text 3\Packages\User" %HOMEPATH%"\dotfiles\tools\sublime\User"
    rem ---------------------------------
    rem And Do Below.
    rem 1. Start Sublime Text3
    rem 2. Ctrl + `
    rem 3. Paste this or copy from here. https://packagecontrol.io/installation#st3
    rem    import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
exit /b 0

:atom
    call :backuppable_link "%HOMEPATH%" ".atom" "%HOMEPATH%\dotfiles\tools\arom\.arom" 1
rem    cmd /c mklink /D %HOMEPATH%"\.atom" %HOMEPATH%"\dotfiles\tools\atom\.atom"
exit /b 0

:git
    rem git config --global user.name sample_username
    rem git config --global user.email sample_email@domain.com
    git config --global core.editor "vim -c 'set fenc=utf-8'"
    git config --global core.quotepath false
    git config --global color.ui auto
    git config --global push.default simple
    git config --global http.sslVerify false
    git config --global core.preloadindex true
    git config --global core.fscache true
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
exit /b 0

:bash
    call :backuppable_link "%HOMEPATH%" ".bashrc" "%HOMEPATH%\dotfiles\tools\win\.bashrc" 0
rem    cmd /c mklink %HOMEPATH%"\.bashrc" %HOMEPATH%"\dotfiles\tools\win\.bashrc"
exit /b 0

:vim
    call :backuppable_link "%HOMEPATH%" "_gvimrc" "%HOMEPATH%\dotfiles\apps\vim\.gvimrc" 0
    call :backuppable_link "%HOMEPATH%" "_vimrc" "%HOMEPATH%\dotfiles\apps\vim\.vimrc" 0
    call :backuppable_link "%HOMEPATH%" ".vim" "%HOMEPATH%\dotfiles\apps\vim\.vim" 1
    call :execute md "%HOMEPATH%/.vim/plugged/vim-plug"
    call :execute git clone https://github.com/junegunn/vim-plug.git "%HOMEPATH%/.vim/plugged/vim-plug/autoload"
rem    cmd /c mklink %HOMEPATH%"\_gvimrc" %HOMEPATH%"\dotfiles\apps\vim\.gvimrc"
rem    cmd /c mklink %HOMEPATH%"\_vimrc" %HOMEPATH%"\dotfiles\apps\vim\.vimrc"
rem    cmd /c mklink /D %HOMEPATH%"\.vim" %HOMEPATH%"\dotfiles\apps\vim\.vim"
rem    mkdir -p $HOME/vimfiles/plugged/vim-plug
rem    git clone https://github.com/junegunn/vim-plug.git ~/vimfiles/plugged/vim-plug/autoload
exit /b 0

