##############################################
# Alias
##############################################
case "${OSTYPE}" in
darwin*)
  #alias ls="ls -G -w"
  alias ls='gls -F --color=auto'
  alias xcode='open -a Xcode' # コマンドラインからXcode起動
  # alias gvim='open -a MacVim'         # コマンドラインからMacVim起動
  ;;
linux*)
  alias ls='ls -F --color=auto'
  alias pbcopy='xsel --clipboard --input'       # Mac OS-Xのpbcopyの代わり
  alias pbpaste='xsel --clipboard --output'     # Mac OS-Xのpbpasteの代わり
  alias tmux-copy='tmux save-buffer - | pbcopy' # tmuxのコピーバッファとクリップボードを連携
  alias tmux='tmux -2'                          # Ubuntu12.04で256を使用するため
  alias git='nocorrect git'                     # Ubuntuで_gitと誤解されるため
  if [[ -e /etc/arch-release ]]; then
    if has yay; then
      alias y=yay
    elif has yaourt; then
      alias y=yaourt
    fi
    if has powerpill; then
      alias p='sudo powerpill'
    else
      alias p='sudo pacman'
    fi
  fi
  ;;
freebsd*)
  alias ls="ls -G -w"
  ;;
cygwin*)
  alias ls='ls -F --color=auto'
  alias apt-get='apt-cyg'         # apt-get emulate
  alias tmux='tmux -2'            # 256Color有効化
  alias sudo='echo "No sudo...";' # sudo がないので、エイリアスで逃げる
  ;;
msys*)
  alias ls='ls -F --color=auto'
  alias pbcopy='cat - >/dev/clipboard'
  alias pbpaste='cat /dev/clipboard'
  alias tmux='tmux -2'            # 256Color有効化
  alias sudo='echo "No sudo...";' # sudo がないので、エイリアスで逃げる
  alias nvim=$(which vim)
  alias vim=gvim
  alias git="PATH=/usr/bin winpty git"
  ;;
esac

alias l="ls -lFh"
alias ll="ls -laFh"
alias lla="ls -laFh"
alias la="ls -a"
alias lf="ls -F"
alias du="du -h"
alias df="df -h"
alias su="su -l"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias pod='nocorrect pod'
alias where="command -v"
alias diff="diff -Nru"
alias gp="git pull --rebase"
alias gb="git branch -vv"
alias gt="git tag"
alias gc="git commit"
alias gr="git remote -v"
alias gs="git status"
alias v=vim
alias vi=vim
alias f="find -name"
alias j="jobs -l"
alias cddot="cd $DOTPATH"
alias history="history -i"

# --------------------------------------------------------
# ag 設定
# --------------------------------------------------------
if type ag >/dev/null 2>&1; then
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
  if type fzf >/dev/null 2>&1; then
    # Setting ag as the default source for fzf
    export FZF_DEFAULT_COMMAND='ag --hidden -g ""'
    # To apply the command to CTRL-T as well
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

if type pt >/dev/null 2>&1; then
  if [ "${OSTYPE}" = "msys" ]; then
    # . が最後につかないと固まるので暫定
    org_pt=$(which pt)
    function mymsys_pt() {
      winpty $org_pt -S $* .
    }
    alias pt="mymsys_pt"
  else
    # Smart Case による検索を有効に設定する
    alias pt='pt -S'
  fi
  alias pth='pt --hidden'
fi

# http://qiita.com/yuku_t/items/4ffaa516914e7426419a
function ssh() {
  TERM=xterm
  if [[ -z $TMUX ]]; then
    command ssh $@
  else
    local window_name=$(tmux display -p '#{window_name}')
    [[ $@ == vag ]] && tmux_dog
    command ssh $@
    [[ $@ == vag ]] && tmux_dog -r
    tmux rename-window $window_name
  fi
}

alias tmux_a='tmux set-option -g prefix C-a'
alias tmux_b='tmux set-option -g prefix C-b'

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

## EnterKey bindings
##
#_success_enter() {
#  zle accept-line
#  if [[ -z "$BUFFER" ]]; then
#      :
#  fi
#}
#zle -N _success_enter
#bindkey "\C-m" _success_enter

#
# 'cd ..' する
#
function cd_up() {
  cd ../
  zle reset-prompt
}
zle -N cd_up
bindkey '^f' vi-kill-line # デフォルトのキーバインド(^U)を変更
bindkey '^u' cd_up
