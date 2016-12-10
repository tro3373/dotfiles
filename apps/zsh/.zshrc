##          _              
##  _______| |__  _ __ ___ 
## |_  / __| '_ \| '__/ __|
##  / /\__ \ | | | | | (__ 
## /___|___/_| |_|_|  \___|
##                         
##
#
umask 0002
#limit coredumpsize 0
#bindkey -d
#
# NOTE: set fpath before compinit
fpath=(${HOME}/.zsh/Completion(N-/) $fpath)
fpath=(${HOME}/.zsh/functions/*(N-/) $fpath)
fpath=(${HOME}/.zsh/plugins/zsh-completions(N-/) $fpath)
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

if [ -d ${HOME}/.zsh ]; then
    for z in `ls ${HOME}/.zsh/*.zsh`; do
        source $z
    done
fi
[ -f ${HOME}/.works.zsh ] && source ${HOME}/.works.zsh
[ -f ${HOME}/.fzf.zsh ] && source ${HOME}/.fzf.zsh

