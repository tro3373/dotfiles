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
has() { command -v ${1} >&/dev/null; }
#===========================================
# zprof debug
#===========================================
ZPOFDEBUG=0
[[ $ZPOFDEBUG -eq 1 ]] && zmodload zsh/zprof && zprof

#===========================================
# debug zsh load
#===========================================
LOADDEBUG=0
now_msec() {
  echo "$(date +%s)$(printf "%03d" $(($(date +%N) / 1000000)))"
}
debug_load() {
  [[ $LOADDEBUG -ne 1 ]] && return
  [[ -z $LOADST ]] && return
  local t=$(($(now_msec) - LOADST))
  echo "==> $(printf "%05d" $t) msec $1"
}
if [[ $LOADDEBUG -eq 1 ]]; then
  export LOADST=$(now_msec)
  debug_load ".zshrc load start"
fi

load_zsh() {
  [[ ! -e $1 ]] && return
  _zcompile_ifneeded $1
  source $1
}
_zcompile_ifneeded() {
  if [[ ! -e $1.zwc || $1 -nt $1.zwc ]]; then
    echo "==> zcompiling $1 .."
    zcompile $1
  fi
}
_zcompile_ifneeded ~/.zshrc

debug_load ".zsh/ load start"
for z in $(find ~/.zsh/??\.*\.zsh -type f); do
  debug_load "$z load start"
  load_zsh $z
done
debug_load ".zsh/ load end"

[[ $ZPOFDEBUG -eq 1 ]] && zprof | less
debug_load "done"
