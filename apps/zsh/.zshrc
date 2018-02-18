debug_load $0
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

# Set in .zshrc, because Not work in .zshenv.
[ ${OSTYPE} = "msys" ] && export WINHOME=/c/Users/`whoami`
if [ -d ~/.zsh ]; then
    for z in `ls ~/.zsh/*.zsh`; do
        if [ $z -nt $z.zwc ]; then
            echo "==> zcompiling $z .."
            zcompile $z
        fi
        debug_load $z
        source $z
    done
fi
if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
    zcompile ~/.zshrc
    find ~/.zplug/repos/ -name "*.zsh" |while read -r line; do zcompile $line ; done
fi
[ -f ~/.works.zsh ] && source ~/.works.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#if (which zprof > /dev/null) ;then
#  zprof | less
#fi
