# setup msys2
## 1. Set ps execution policy
```
./setup_ps_execution_policy.bat
```

## 2. install packages via scoop

```
./bootstrap_win.ps1
```

## 3. Bootstrap

```
# init msys2
./admin_msys2.ps1
exit

# bootstap1
./admin_msys2.ps1
./bootstrap

# bootstap2
./admin_msys2.ps1
./bootstrap
```

## 3. setup

# TODO https://www.ncaq.net/2020/11/10/15/40/08/
```
./admin_msys2.ps1
cd .dot/bin
./setup msys2 -e
```

## TODO
- gui
    - Task bar
        - Move to left
        - Remove shortcuts
        - Dislay all task icons always
        - Not integrate button
        - Auto disapper
        - Use small task bar button
    - Explore
        - Show extention
        - Show hidden files
        - Add Quick Launch
        - Set icon to `admin msys start batch`
    - Desktop Icons
        - Display pc, network, control panel
        - Setup changer wallpaper
    - Window snap
        - Disable show nighbor snap app suggestion
        - Disable change windows size for nighbor app window when snapped
- scoop
    - scoop 7zip context menu is need to kick reg file?
- setup
    - is msys2 tran setup include hackgen?
