#!/bin/bash

# デフォルトのインストールメソッド定義
install() {
    dlog " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    dlog "   Default install called. execute default install command."
    dlog " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    dvexec $def_instcmd
}

# デフォルトの設定メソッド定義
setconfig() {
    dlog " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    dlog "   Default setconfig called. do nothing."
    dlog " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}
