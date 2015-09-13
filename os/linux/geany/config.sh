#!/bin/bash

install(){
    log "  => (FIXME) Do nothing."
}

setconfig() {
    log "  => (FIXME) Do nothing."
    return

    app=geany
    if ! testcmd $app; then
        log "  => $app Not installed. (FIXME)How to install it."
        dry_vexec sudo add-apt-repository ppa:geany-dev/ppa
        dry_vexec sudo apt-get update
        dry_vexec sudo apt-get upgrade
        dry_vexec sudo apt-get install -y geany
    fi
    log "#================================================================"
    log "# Geany Setting(FIXME)."
    log "#================================================================"
    geanyconfdir=$HOME/.config/geany
    dvexec "mv \"$geanyconfdir/geany.conf\" \"$geanyconfdir/geany.conf.org\""
    dvexec "mv \"$geanyconfdir/keybindings.conf\" \"$geanyconfdir/keybindings.conf.org\""
    dvexec "cp \"$script_dir/geany.conf\" \"$geanyconfdir/geany.conf\""
    dvexec "cp \"$script_dir/keybindings.conf\" \"$geanyconfdir/keybindings.conf\""

    dvexec "cd ~/.config/geany/filedefs"
    dvexec "tar xvfpz \"$script_dir/oblivion2.tar.gz\""
    dvexec "cat filetypes.xml > filetypes.html"
    dvexec "sed 's/^selection.+$/selection=0x000;0x33B5E5;false;true/g' filetypes.common"

    log "- Themeを[ここ](http://www.geany.org/Download/Extras)からダウンロード"
    log "- [色設定の為、最新にUPDATE](http://enwarblog.blogspot.jp/2012/08/geany.html)"
    log "- oblivion2.tar.gz"
    log "    - 解凍し、~/.config/geany/filedefs へ配置"
    log "- htmlの色変更"
    log "    - htmlファイルがバグっているので、filetype.htmlは、filetype.xmlからコピーし貼付け"
    log "- 選択時の色を赤から変更"
    log "    - filetypes.commom"
    log "#selection=0x000;0xA52A2A;false;true"
    log "selection=0x000;0x33B5E5;false;true"
}
