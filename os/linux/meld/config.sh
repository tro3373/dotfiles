#!/bin/bash

install(){
    log "  => (FIXME) Do nothing."
}

setconfig() {
    app=meld
    if ! testcmd $app; then
        log "  => $app Not installed. skip it."
        return
    fi
    log "#================================================================"
    log "# How to create Meld Desktop Icon Sample"
    log "#================================================================"
    log "  Create file ~/Desktop/meld.desktop"
    log "  ---------------------"
    log "  [Desktop Entry]"
    log "  Type=Application"
    log "  Name=Meld"
    log "  GenericName=meld"
    log "  Icon=/path/to/meld/src/meld-x.x.x/data/icons/hicolor/48x48/apps/meld.png"
    log "  Exec=/path/to/meld/src/meld-1.8.6/bin/meld"
    log "  Terminal=false"
    log "  ---------------------"
}
