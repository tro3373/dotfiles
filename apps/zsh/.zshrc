###############################################################################
##          _
##  _______| |__  _ __ ___ 
## |_  / __| '_ \| '__/ __|
##  / /\__ \ | | | | | (__ 
## /___|___/_| |_|_|  \___|
##
###############################################################################
## 高速化
# https://qiita.com/vintersnow/items/c29086790222608b28cf
#
#===========================================
# zprof debug
#===========================================
ZPOFDEBUG=0
[[ $ZPOFDEBUG -eq 1 ]] && zmodload zsh/zprof && zprof

#===========================================
# debug zsh load
#===========================================
LOADDEBUG=0
function now_msec() {
    echo "$(date +%s)$(printf "%03d" $(($(date +%N)/1000000)))"
}
function debug_load() {
    [[ $LOADDEBUG -ne 1 ]] && return
    [[ -z $LOADST ]] && return
    local t=$(($(now_msec)-LOADST))
    echo "==> $(printf "%05d" $t) msec $1"
}
if [[ $LOADDEBUG -eq 1 ]]; then
    export LOADST=$(now_msec)
    debug_load ".zshrc load start"
fi

export TERM=xterm-256color
if [ -d ~/.zsh ]; then
    debug_load ".zsh/ load start"
    for z in $(ls ~/.zsh/??\.*\.zsh); do
        debug_load "$z load start"
        source $z
    done
    load_zsh ~/.fzf.zsh
    debug_load ".zsh/ load end"
fi

if [[ $ZPOFDEBUG -eq 1 ]]; then
    if (which zprof > /dev/null) ;then
        zprof | less
    fi
fi
debug_load "done"
