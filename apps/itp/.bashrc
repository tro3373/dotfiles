# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
umask 022
# red="1;31m"
blue="1;34m"
green="1;32m"
# cyan="1;36m"
# gray="0;37m"
open="\033["
close="${open}0m"
PS1="${open}${blue}\t${close} ${open}${green}interpreter${close} # "

# You may uncomment the following lines if you want `ls' to be colorized:
export SHELL=/bin/bash
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -la'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# shellcheck disable=SC1091
. "$HOME/.cargo/env"
