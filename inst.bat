REM !!WARNING!!
REM   Symbolic link command is aborted when you start command prompt normal user. exec cmd as Administrator.

REM Sakura Setting ===========
cmd /c mklink %HOMEPATH%"\AppData\Roaming\sakura\sakura.ini" %HOMEPATH%"\dotfiles\os\win\sakura\sakura.ini"
REM =================================

REM Sublime Text3 Setting ===========
rmdir -recurse %HOMEPATH%"\AppData\Roaming\Sublime Text 3\Packages\User"
cmd /c mklink /D %HOMEPATH%"\AppData\Roaming\Sublime Text 3\Packages\User" %HOMEPATH%"\dotfiles\apps\subl\User"
REM ---------------------------------
REM And Do Below.
REM 1. Start Sublime Text3
REM 2. Ctrl + `
REM 3. Paste this or copy from here. https://packagecontrol.io/installation#st3
REM    import urllib.request,os,hashlib; h = '2deb499853c4371624f5a07e27c334aa' + 'bf8c4e67d14fb0525ba4f89698a6d7e1'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
REM =================================

REM Atom Setting ===========
cmd /c mklink /D %HOMEPATH%"\.atom" %HOMEPATH%"\dotfiles\apps\apm\.atom"
REM =================================

REM chocolatey Setting ===========
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
REM cinst packages.config
REM =================================
REM exit 0

