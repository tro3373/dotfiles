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
./sudo_msys2.bat
exit

./sudo_cmd.bat
./setup_unxh.bat

# bootstap1
./sudo_msys2.bat
./bootstrap

# bootstap2
./sudo_msys2.bat
./bootstrap
```

## 3. setup

# TODO https://www.ncaq.net/2020/11/10/15/40/08/
```
./sudo_msys2.bat
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
    - add to context menu
        - 7zip
            - sudo 7zFM & add context menu from option settings
        - auto setup
            - sakura
            - code
            - vim
- move bootstrap_win.ps1 pkgs to setup app
- winln with icon
- sudo_cmd.bat with work directory
