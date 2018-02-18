##          _
##  _______| |__  _ __ ___ 
## |_  / __| '_ \| '__/ __|
##  / /\__ \ | | | | | (__ 
## /___|___/_| |_|_|  \___|
##
## 高速化
# https://qiita.com/vintersnow/items/c29086790222608b28cf
##

# umask settnig
umask 0002

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

# LANGUAGE must be set by en_US
export LANGUAGE="en_US.UTF-8"
# export LANGUAGE="ja_JP.UTF-8"
case ${UID} in
0)
    LANGUAGE=C
    ;;
esac
export LANG="${LANGUAGE}"
export LC_ALL="${LANGUAGE}"
export LC_CTYPE="${LANGUAGE}"

# Editor
export EDITOR=vim
export CVSEDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export GIT_EDITOR="${EDITOR}"

# Pager
export PAGER=less
# Less status line
export LESS='-R -f -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]'
export LESSCHARSET='utf-8'

# LESS man page colors (makes Man pages more readable).
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[00;44;37m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# ls command colors
export LSCOLORS=exfxcxdxbxegedabagacad

if grep -qE "(Microsoft | WSL)" /proc/version &> /dev/null ; then
    export WSL=1
    unsetopt BG_NICE
fi

# declare the environment variables
# export CORRECT_IGNORE='_*'
# export CORRECT_IGNORE_FILE='.*'
#
# export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
# export WORDCHARS='*?.[]~&;!#$%^(){}<>'
#
# fzf - command-line fuzzy finder (https://github.com/junegunn/fzf)
# export FZF_DEFAULT_OPTS="--extended --ansi --multi"
#
# Cask
#export HOMEBREW_CASK_OPTS="--appdir=/Applications"
#
# available $INTERACTIVE_FILTER
# export INTERACTIVE_FILTER="fzf:peco:percol:gof:pick"

export DOTPATH="$HOME/.dot"
# keybind ^X^X
# export ONELINER_FILE="$DOTPATH/doc/misc/commands.txt"

# Set in .zshrc, because Not work in .zshenv.
[ ${OSTYPE} = "msys" ] && export WINHOME=/c/Users/`whoami`


source_pkg() {
    local url=$1
    local with_source=$2
    local nm=${url##*/}; nm=${nm%%.git}
    local dst=~/.zsh/plugins/$nm
    if [[ ! -e $dst ]]; then
        echo "==> cloning $nm .."
        git clone --depth 1 -q $url $dst
        echo "==> zcompiling $nm .."
        find $dst -name "*.zsh" |while read -r line; do zcompile $line ; done
    fi
    local src=$dst/$nm.zsh
    if [[ $with_source -eq 1 && -e $src ]]; then
        source $src
    fi
}
source_pkg https://github.com/zsh-users/zsh-completions.git
source_pkg https://github.com/zsh-users/zsh-history-substring-search.git 1
source_pkg https://github.com/zsh-users/zsh-syntax-highlighting.git 1

#limit coredumpsize 0
#bindkey -d
#
# NOTE: set fpath before compinit
fpath=(~/.zsh/Completion(N-/) $fpath)
fpath=(~/.zsh/functions/*(N-/) $fpath)
fpath=(~/.zsh/plugins/zsh-completions(N-/) $fpath)
#fpath=(/usr/local/share/zsh/site-functions(N-/) $fpath)
#
## autoload
autoload -U  run-help
#autoload -Uz add-zsh-hook
autoload -Uz cdr
#autoload -Uz colors; colors
autoload -Uz compinit; compinit -u
#autoload -Uz is-at-least
#autoload -Uz history-search-end
#autoload -Uz modify-current-argument
#autoload -Uz smart-insert-last-word
#autoload -Uz terminfo
#autoload -Uz vcs_info
#autoload -Uz zcalc
#autoload -Uz zmv
autoload     run-help-git
autoload     run-help-svk
autoload     run-help-svn

zcompile_ifneeded() {
    debug_load "Loading $1 .."
    if [[ ! -e $1.zwc || $1 -nt $1.zwc ]]; then
        echo "==> zcompiling $1 .."
        zcompile $1
    fi
}
load_zsh() {
    [[ ! -e $1 ]] && return
    zcompile_ifneeded $1
    source $1
}
zcompile_ifneeded ~/.zshrc

if [ -d ~/.zsh ]; then
    debug_load ".zsh/*.zsh load start"
    for z in `ls ~/.zsh/*.zsh`; do
        load_zsh $z
    done
    debug_load ".zsh/*.zsh load end"
fi
load_zsh ~/.works.zsh
load_zsh ~/.fzf.zsh
[ -f ~/.secret ] && . ~/.secret


if [[ $ZPOFDEBUG -eq 1 ]]; then
    if (which zprof > /dev/null) ;then
        zprof | less
    fi
fi
debug_load "done"
