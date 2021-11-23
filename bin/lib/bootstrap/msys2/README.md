# setup msys2
## 1. install packages via scoop

```
./bootstrap_win.ps1
```

## 2. setup msys2
### 1. start msys via Admin

```
set MSYS=winsymlinks:nativestrict
@powershell start-process "%userprofile%\scoop\apps\msys2\current\msys2_shell.cmd" -verb runas

@powershell start-process "set MSYS=winsymlinks:nativestrict && %userprofile%\scoop\apps\msys2\current\msys2_shell.cmd" -verb runas
```

### 2. bootstrap msys2

```
./bootstrap
```

## 3. setup

```
./setup msys2 -e
```

todo fix ahk setup. not symlink. shotcut. and lnk path is wrong.
is msys2 tran setup include hackgen?
scoop 7zip context menu is need to kick reg file?
