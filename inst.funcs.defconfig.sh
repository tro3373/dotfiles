#!/bin/bash

# デフォルトのインストールメソッド定義
install() {
    log " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    log "   Default install called. execute default install command."
    log " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    dvexec $def_instcmd
}

# デフォルトの設定メソッド定義
setconfig() {
    log "  Default setconfig called. do nothing."
}
