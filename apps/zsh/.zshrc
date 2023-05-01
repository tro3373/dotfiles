###############################################################################
##          _
##  _______| |__  _ __ ___
## |_  / __| '_ \| '__/ __|
##  / /\__ \ | | | | | (__
## /___|___/_| |_|_|  \___|
##
###############################################################################
use_cache=1
export zshrcc=~/.zshrcc
has() { command -v ${1} >&/dev/null; }
log() { echo "$*" 1>&2; }
[[ $use_cache -eq 1 ]] && [[ -e $zshrcc ]] && source $zshrcc && return

zprof_debug=0
load_debug=0
# is_vagrant() { hostname |grep archlinux.vagrant |grep -v grep >& /dev/null; }
is_vagrant() { pwd | grep /home/vagrant >&/dev/null; }
#is_wsl() { [[ -n $WSL_DISTRO_NAME ]]; }
# is_wsl() { [[ -e /proc/version ]] && grep -qE "(Microsoft | WSL)" /proc/version; }
is_wsl() { [[ -e /proc/version ]] && grep -qi microsoft /proc/version; }
is_msys() { [[ ${OSTYPE} == "msys" ]]; }
is_mac() { [[ ${OSTYPE} =~ ^darwin.*$ ]]; }
now_msec() { echo "$(date +%s)$(printf "%03d" $(($(date +%N) / 1000000)))"; }
debug_load() {
  [[ $load_debug -ne 1 ]] && return
  [[ -z $LOADST ]] && return
  local t=$(($(now_msec) - LOADST))
  log "==> $(printf "%05d" $t) msec $1"
}
load_zsh() {
  [[ ! -e $1 ]] && return
  _zcompile_ifneeded $1
  source $1
}
_zcompile_ifneeded() {
  [[ -e $1.zwc ]] && return
  [[ ! $1 -nt $1.zwc ]] && return
  log "==> zcompiling $1 .."
  zcompile $1
}
_zshrc() {
  #===========================================
  # zprof debug
  #===========================================
  [[ $zprof_debug -eq 1 ]] && zmodload zsh/zprof && zprof

  #===========================================
  # debug zsh load
  #===========================================
  if [[ $load_debug -eq 1 ]]; then
    export LOADST=$(now_msec)
    debug_load ".zshrc load start"
  fi

  _zcompile_ifneeded ~/.zshrc

  debug_load ".zsh/ load start"
  for z in $(find ~/.zsh/??\.*\.zsh -type f); do
    debug_load "$z load start"
    load_zsh $z
  done
  debug_load ".zsh/ load end"

  [[ $zprof_debug -eq 1 ]] && zprof | less
  debug_load "done"
}
_zshrc
