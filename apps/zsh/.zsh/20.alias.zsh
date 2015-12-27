##############################################
# Alias
##############################################
alias vi=vim
case "${OSTYPE}" in
    # for MAC-OS
    darwin*)
        #alias ls="ls -G -w"
        alias ls='gls --color=auto'
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
        alias ls="ls --color"
        alias nt=nautilus                               # 指定ディレクトリをnautilusで開く
        alias open=nautilus                             # 指定ディレクトリをnautilusで開く
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
        alias open='cygstart'                           # 指定ディレクトリをwindowエクスプローラで開く
        alias apt-get='apt-cyg'                         # apt-get emulate
        alias tmux='tmux -2'                            # 256Color有効化
        alias sudo='echo "No sudo...";'                 # sudo がないので、エイリアスで逃げる
esac

alias la="ls -a"
alias lf="ls -F"
alias l="ls -l"
alias ll="ls -la"
alias lla="ls -la"
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
# --------------------------------------------------------
# ag 設定
# --------------------------------------------------------
if type ag > /dev/null 2>&1; then
    # Smart Case による検索を有効に設定する
    alias ag='ag -S'
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

