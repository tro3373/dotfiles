##############################################
# Alias
##############################################
case "${OSTYPE}" in
  darwin*)
    #alias ls="ls -G -w"
    alias ls='ls -F --color=auto'
    alias xcode='open -a Xcode' # コマンドラインからXcode起動
    # alias gvim='open -a MacVim'     # コマンドラインからMacVim起動
    alias sudo='sudo -E ' # E: 環境変数のリセット無効(sudo vim で個人設定反映など)
    ;;
  linux*)
    alias ls='ls -F --color=auto'
    alias pbcopy='xsel --clipboard --input'       # Mac OS-Xのpbcopyの代わり
    alias pbpaste='xsel --clipboard --output'     # Mac OS-Xのpbpasteの代わり
    alias tmux-copy='tmux save-buffer - | pbcopy' # tmuxのコピーバッファとクリップボードを連携
    alias tmux='tmux -2'                          # Ubuntu12.04で256を使用するため
    alias git='nocorrect git'                     # Ubuntuで_gitと誤解されるため
    alias sudo='sudo -E '                         # E: 環境変数のリセット無効(sudo vim で個人設定反映など)
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
    # alias nvim=$(which vim)
    alias vim=gvim
    alias git="PATH=/usr/bin winpty git"
    alias tig="PATH=/usr/bin winpty tig"
    ;;
esac

if has exa; then
  # alias ls="exa"
  function my_ls() {
    if [[ $* == "-ltra" ]]; then
      command exa -las modified
      return
    fi
    command exa "$@"
  }
  alias ls="my_ls"
fi
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
alias diffs="diff -Nru --strip-trailing-cr"
alias gp="git pull --rebase"
alias gb="git branch -vv"
alias gt="git tag"
alias gc="git commit"
alias gr="git remote -v"
alias gs="git status"
if has git-sim; then
  alias gsm="git-sim"
fi
if has sync_src; then
  alias ssn="sync_src"
fi
if has nvim; then
  alias vim="nvim"
fi
# alias v=vim
alias vi=vim
alias f="find -name"
alias j="jobs -l"
alias g="git"
alias d="docker"
alias s="systemctl"
alias cddot="cd $DOTPATH"
alias history="history -i"
if has speedtest; then
  alias st="speedtest"
fi
if has mmv; then
  mmv() {
    if [[ $# -ne 0 ]]; then
      command mmv "$@"
      return
    fi
    command mmv ./*
  }
fi

if has flutter; then
  alias fl="flutter"
fi

gm() {
  [[ -z $* ]] && echo "Specify commit message" 1>&2 && return
  git commit -m "$*"
}

# --------------------------------------------------------
# ag 設定
# --------------------------------------------------------
if has ag; then
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
fi

# --------------------------------------------------------
# pt 設定
# --------------------------------------------------------
if has pt; then
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

# --------------------------------------------------------
# rg 設定
# --------------------------------------------------------
if has rg; then
  alias rg='rg -S'
  rgf() {
    local args="$@"
    rg --files | rg -S "$args"
  }
fi

if has rga; then
  rga-fzf() {
    RG_PREFIX="rga --files-with-matches"
    local file
    file="$(
      FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
        fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
        --phony -q "$1" \
        --bind "change:reload:$RG_PREFIX {q}" \
        --preview-window="70%:wrap"
    )" &&
      echo "opening $file" &&
      open "$file"
  }
fi

# --------------------------------------------------------
# fzf 設定
# --------------------------------------------------------
if has fzf; then
  # Setting ag as the default source for fzf
  if has rg; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  elif has pt; then
    export FZF_DEFAULT_COMMAND='pt --hidden -g ""'
  elif has ag; then
    export FZF_DEFAULT_COMMAND='ag --hidden -g ""'
  fi
  if [[ -n $FZF_DEFAULT_COMMAND ]]; then
    # To apply the command to CTRL-T as well
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

if has shfmt; then
  alias shfmt="shfmt -i 2 -ci -s"
fi

# http://qiita.com/yuku_t/items/4ffaa516914e7426419a
function ssh() {
  TERM=xterm
  local window_name=$(tmux_ssh_dog -p "$@")
  command ssh "$@"
  tmux_ssh_dog -r "$window_name" "$@"
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
  zle reset-prompt # redraw prompt
}
zle -N cd_up              # redist `cd_up` as widget
bindkey '^f' vi-kill-line # デフォルトのキーバインド(^U)を変更
bindkey '^u' cd_up

function supported() {
  local cmd="$*"
  if ! has $cmd; then
    echo "Not supported(No $cmd command exist)" 1>&2
    return 1
  fi
  return 0
}
function cd_dir() {
  local d="$*"
  if [ -n "$d" ]; then
    BUFFER="cd $d"
    zle accept-line # execute buffer string
  fi
  zle -R -c # refresh
}
function _find_src_root() {
  # find $HOME/src/ -maxdepth 1 -mindepth 1 -type d
  # find $HOME/go/src -type d -name '.git' 2>/dev/null | xargs dirname
  {
    find $HOME/.dot/bin/lib/bootstrap -maxdepth 1 -mindepth 1 -type d
    find $HOME/.dot/bin/lib/setup -maxdepth 1 -mindepth 1 -type d
    find $HOME/.dot/apps -maxdepth 1 -mindepth 1 -type d
    ghq list --full-path 2>/dev/null
  } | tac
}
function cd_src_root() {
  supported fzf || return
  supported ghq || return
  preview_cmd="ls -laF {}"
  has onefetch && preview_cmd="onefetch --no-art {}"
  # LBUFFER: 現在のカーソル位置よりも左のバッファ
  # RBUFFER: 現在のカーソル位置を含む右のバッファ
  local src=$(
    _find_src_root |
      fzf --query "$LBUFFER" --preview "$preview_cmd"
  )
  cd_dir "$src"
}
zle -N cd_src_root
bindkey '^]' cd_src_root

function _find_dirs() {
  find . -type d -maxdepth 5 2>/dev/null |
    grep -E -v '/\.' |
    grep -v 'node_modules' |
    grep -v 'bower_components'
}
function cd_under_d() {
  supported fzf || return
  # LBUFFER: 現在のカーソル位置よりも左のバッファ
  # RBUFFER: 現在のカーソル位置を含む右のバッファ
  local src=$(
    _find_dirs |
      fzf --query "$LBUFFER" --preview "ls -laF {}"
  )
  cd_dir "$src"
}
zle -N cd_under_d
bindkey '^k' cd_under_d

function _paste_img() {
  has paste_img || return
  paste_img -d "$(pwd)"
  zle reset-prompt # redraw prompt
}
zle -N _paste_img
bindkey '^[p' _paste_img

rm_cache() {
  # rm -rf ~/.cache/zsh
  find ~/.cache/zsh/ -type f |
    fzf -m \
      --preview 'echo {}; echo "----------------------------------------"; head -100 {}' \
      --select-1 \
      --exit-0 \
      --bind 'ctrl-l:toggle-all,ctrl-g:toggle-preview' |
    xargs rm -v
}

fpath() {
  echo "${fpath[@]}" | tr ' ' '\n'
}

insert-date() {
  LBUFFER+=$(date +%Y%m%d)
}
zle -N insert-date
bindkey '^;' insert-date
