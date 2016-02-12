REM !!WARNING!!
REM   Symbolic link command is aborted when you start command prompt normal user. exec cmd as Administrator.

REM Sakura Setting ===========
rem cmd /c mklink %HOMEPATH%"\AppData\Roaming\sakura\sakura.ini" %HOMEPATH%"\dotfiles\tools\win\sakura\sakura.ini"
REM =================================

REM Sublime Text3 Setting ===========
rmdir -recurse %HOMEPATH%"\AppData\Roaming\Sublime Text 3\Packages\User"
cmd /c mklink /D %HOMEPATH%"\AppData\Roaming\Sublime Text 3\Packages\User" %HOMEPATH%"\dotfiles\tools\sublime\User"
REM ---------------------------------
REM And Do Below.
REM 1. Start Sublime Text3
REM 2. Ctrl + `
REM 3. Paste this or copy from here. https://packagecontrol.io/installation#st3
REM    import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
REM =================================

REM Atom Setting ===========
cmd /c mklink /D %HOMEPATH%"\.atom" %HOMEPATH%"\dotfiles\tools\atom\.atom"
REM =================================

REM chocolatey Setting ===========
rem @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
REM cinst packages.config
REM =================================
REM exit 0

REM git bash Setting =============
REM .bashrc
REM   export PS1="$ "
REM   alias ls='ls --show-control-chars'
REM ===============================
