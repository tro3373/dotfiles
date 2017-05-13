##############################################
# Alias
##############################################
case "${OSTYPE}" in
    # for MAC-OS
    darwin*)
        #alias ls="ls -G -w"
        alias ls='gls -F --color=auto'
        alias xcode='open -a Xcode'         # コマンドラインからXcode起動
        alias gvim='open -a MacVim'         # コマンドラインからMacVim起動

        fnd() {                             # 指定ディレクトリをFinderで開く
            if [ $# = 0 ]; then
                open `pwd`
            else
                for arg in $@; do
                    if [ -d ${arg} ]; then
                        open ${arg}
                    else
                        open -R ${arg}
                    fi
                done
            fi
        }
        ;;

    # for Linux
    linux*)
        alias ls='ls -F --color=auto'
        _open() { nautilus 2>/dev/null }                # xdg-open command also useful.
        alias nt=_open                                  # 指定ディレクトリをnautilusで開く
        alias open=_open                                # 指定ディレクトリをnautilusで開く
        $ gv() {gvim -f $1 &!}                          # コマンドラインからgVim起動
        alias pbcopy='xsel --clipboard --input'         # Mac OS-Xのpbcopyの代わり
        alias pbpaste='xsel --clipboard --output'       # Mac OS-Xのpbpasteの代わり
        alias tmux-copy='tmux save-buffer - | pbcopy'   # tmuxのコピーバッファとクリップボードを連携
        alias tmux='tmux -2'                            # Ubuntu12.04で256を使用するため
        alias git='nocorrect git'                       # Ubuntuで_gitと誤解されるため
        ;;

    #for FreeBSD
    freebsd*)
        alias ls="ls -G -w"
        ;;

    #cygwin
    cygwin*)
        alias ls='ls -F --color=auto'
        alias open='cygstart'                           # 指定ディレクトリをwindowエクスプローラで開く
        alias apt-get='apt-cyg'                         # apt-get emulate
        alias tmux='tmux -2'                            # 256Color有効化
        alias sudo='echo "No sudo...";'                 # sudo がないので、エイリアスで逃げる
        ;;

    #msys
    msys*)
        alias ls='ls -F --color=auto'
        alias pbcopy='cat - >/dev/clipboard'
        alias pbpaste='cat /dev/clipboard'
        alias tmux='tmux -2'                            # 256Color有効化
        alias sudo='echo "No sudo...";'                 # sudo がないので、エイリアスで逃げる
        alias vim=gvim
        open() { local p=${1:-.}; explorer $p }
        alias nvim=$(which vim)
        ;;
esac

alias cddot="cd $DOTPATH"
alias la="ls -a"
alias lf="ls -F"
alias l="ls -lFh"
alias ll="ls -laFh"
alias lla="ls -laFh"
alias du="du -h"
alias df="df -h"
alias su="su -l"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias pod='nocorrect pod'
alias where="command -v"
alias diff="diff -Nru"
#alias j="jobs -l"
alias vi=vim
alias gp="git pull --rebase"
alias gb="git branch -vv"
alias gt="git tag"
alias gc="git commit"
alias gr="git remote -v"
alias gs="git status"
# --------------------------------------------------------
# ag 設定
# --------------------------------------------------------
if type ag > /dev/null 2>&1; then
    if [ "${OSTYPE}" = "msys" ]; then
        # . が最後につかないと固まるので暫定
        org_ag=$(which ag)
        function mymsys_ag() {
            $org_ag -S $* .
        }
        alias ag="mymsys_ag"
    else
        # Smart Case による検索を有効に設定する
        alias ag='ag -S'
    fi
    alias agh='ag --hidden'
    # --------------------------------------------------------
    # fzf 設定
    # --------------------------------------------------------
    if type fzf > /dev/null 2>&1; then
        # Setting ag as the default source for fzf
        export FZF_DEFAULT_COMMAND='ag --hidden -g ""'
        # To apply the command to CTRL-T as well
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

# http://qiita.com/yuku_t/items/4ffaa516914e7426419a
function ssh() {
    local window_name=$(tmux display -p '#{window_name}')
    command ssh $@
    tmux rename-window $window_name
}

## --------------------------------------------------------
## gtags (Pygments)
## --------------------------------------------------------
#if type pip > /dev/null 2>&1; then
#    if pip list | grep Pygments > /dev/null 2>&1; then
#        # System has Pygments.
#        # Which plugin parser in use? => type 'gtags --debug'.
#        export GTAGSLABEL=pygments
#    fi
#fi

