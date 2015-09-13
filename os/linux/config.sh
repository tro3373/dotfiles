#!/bin/bash

setconfig() {
    if testcmd dconf; then
        # dconf がインストールされている場合
        log "#================================================================"
        log "# Keybind Settings"
        log "#  Cpas Lock => Ctrl setting"
        log "#================================================================"
        dvexec "dconf write /org/gnome/desktop/input-sources/xkb-options \"['ctrl:nocaps']\""
        #dvexec dconf reset /org/gnome/desktop/input-sources/xkb-options
    else
        # dconf がインストールされていない場合
        log "#================================================================"
        log "# Keybind Settings"
        log "#  Cpas Lock => Ctrl setting"
        log "#    dconf is not installed. Do nothing."
        log "#================================================================"
    fi
}
