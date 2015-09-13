#!/bin/bash

setconfig() {
    log "#================================================================"
    log "# .DS_Store not make settings."
    log "#================================================================"
    dvexec defaults write com.apple.desktopservices DSDontWriteNetworkStores true
    log "#================================================================"
    log "# Delete Localized directory names, and to set eng name Setting."
    log "#================================================================"

    delifexist ~/Applications/.localized
    delifexist ~/Desktop/.localized
    delifexist ~/Documents/.localized
    delifexist ~/Downloads/.localized
    delifexist ~/Movies/.localized
    delifexist ~/Music/.localized
    delifexist ~/Pictures/.localized
    delifexist ~/Public/.localized
    delifexist ~/Library/.localized
    log "#================================================================"
    log "# Finder extend"
    log "#================================================================"
    log "   Install App XtraFinder.app"
    log ""
    log "#================================================================"
    log "# mouse scroll and touch pad setting..."
    log "#================================================================"
    log "   Install App Scroll Reverser.app"
    log ""
    log "#================================================================"
    log "# Window snaping tools"
    log "#================================================================"
    log "   Install App Better touch tool.app"
    log ""
    log "#================================================================"
    log "# Keybind tools"
    log "#================================================================"
    log "   Install App Karabiner.app"
    log ""
    log "#================================================================"
    log "# Keybind setting"
    log "#================================================================"
    log "  caps lock to command."
    log "    System Enviroments - Keyboard - modification key"
    log ""
    log "#================================================================"
    log "# Mission Control disable."
    log "#================================================================"
    log "  System Enviroments - Keyboard - shortcut - Mission Control"
    log ""
    log "#================================================================"
    log "# Change KeyMap for change window of same App "
    log "#================================================================"
    log "  System Enviroments - Keyboard - modification key - shortcut - keyboard - 次のウィンドウを操作対処にする"
    log ""
}
