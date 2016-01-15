##############################################
# functions
##############################################

#
# "up"コマンドは、ディレクトリ階層を非常に簡単に上れるようにする為のコマンドです。
# "up"コマンドを単体で利用した場合、「cd ../」コマンドと同一です。
# "up 2"のように、引数に数値を与えて実行した場合、その階層分だけ上に移動する事ができます。
# By https://github.com/m-yamashita/up
#
function up(){
    cpath=./
    for i in `seq 1 1 $1`; do
        cpath=$cpath../
    done
    cd $cpath
}

#
# プロセスのkill
# By http://k0kubun.hatenablog.com/entry/2014/07/06/033336
#
function peco-pkill() {
    for pid in `ps aux | peco | awk '{ print $2 }'`; do
        kill $pid
        echo "Killed ${pid}"
    done
}
alias pk="peco-pkill"

##
## historyからの絞り込み実行
## By http://k0kubun.hatenablog.com/entry/2014/07/06/033336
##
#function peco-select-history() {
#    typeset tac
#    if which tac > /dev/null; then
#        tac=tac
#    else
#        tac='tail -r'
#    fi
#    BUFFER=$(fc -l -n 1 | eval $tac | peco --query "$LBUFFER")
#    CURSOR=$#BUFFER
#    zle redisplay
#}
## http://qiita.com/wada811/items/78b14181a4de0fd5b497
#
#function peco-select-history() {
#    local tac
#    if which tac > /dev/null; then
#        tac="tac"
#    else
#        tac="tail -r"
#    fi
#    BUFFER=$(history -n 1 | eval $tac | awk '!a[$0]++' | peco --query "$LBUFFER")
#    CURSOR=$#BUFFER
#    # zle clear-screen
#}
#zle -N peco-select-history
#bindkey '^r' peco-select-history

#
# git add fzf select
#
fzf-select-gitadd() {
    local selected_file_to_add
    selected_file_to_add="$(
    git status --porcelain \
        | perl -pe 's/^( ?.{1,2} )(.*)$/\033[31m$1\033[m$2/' \
        | fzf --ansi --exit-0 \
        | awk -F ' ' '{print $NF}' \
        | tr "\n" " "
    )"

    if [ -n "$selected_file_to_add" ]; then
        BUFFER="git add $selected_file_to_add"
        CURSOR=$#BUFFER
        zle accept-line
    fi
    zle reset-prompt
}
zle -N fzf-select-gitadd
#bindkey '^g^a' fzf-select-gitadd


##
## 検索してCD
##
#function peco-findcd() {
#    # 何階層下までリスティングするか
#    local depth="5"
#    # .で始まるディレクトリは除外
#    local selected_dir="$(find . -maxdepth ${depth} -type d ! -path "*/.*" 2>/dev/null | peco)"
#    if [ -d "$selected_dir" ]; then
#        BUFFER="cd \"${selected_dir}\""
#        CURSOR=$#BUFFER
#        zle accept-line
#    fi
#    zle clear-screen
# }
#zle -N peco-findcd
#bindkey '^k' peco-findcd

##
## Find した結果見つかったファイルをVimで開く
##
#function peco_findvim() {
#    # 何階層下までリスティングするか
#    local depth="5"
#    # .で始まるディレクトリは除外
##    local file="$(find . -maxdepth ${depth} -type f ! -path "*/.*" 2>/dev/null | peco)"
##    [ ! "$file" = "" ] && vim "$file"
#    BUFFER=$(find . -maxdepth ${depth} -type f ! -path "*/.*" 2>/dev/null | peco --query "$LBUFFER")
#    CURSOR=$#BUFFER
#    zle redisplay
# }
#zle -N peco_findvim
##bindkey '^g' peco_findvim

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


#
#
#
bd () {
  (($#<1)) && {
    print -- "usage: $0 <name-of-any-parent-directory>"
    return 1
  } >&2
  # Get parents (in reverse order)
  local parents
  local num=${#${(ps:/:)${PWD}}}
  local i
  for i in {$((num+1))..2}
  do
    parents=($parents "$(echo $PWD | cut -d'/' -f$i)")
  done
  parents=($parents "/")
  # Build dest and 'cd' to it
  local dest="./"
  local parent
  foreach parent (${parents})
  do
    if [[ $1 == $parent ]]
    then
      cd $dest
      return 0
    fi
    dest+="../"
  done
  print -- "bd: Error: No parent directory named '$1'"
  return 1
}
_bd () {
  # Get parents (in reverse order)
  local num=${#${(ps:/:)${PWD}}}
  local i
  for i in {$((num+1))..2}
  do
    reply=($reply "`echo $PWD | cut -d'/' -f$i`")
  done
  reply=($reply "/")
}
compctl -V directories -K _bd bd

##
## Markdown 検索
##
#function find_vim_markdown() {
#    local markdown_dir="$HOME/md"
#    if [ ! -e "$markdown_dir" ]; then
#        return
#    fi
#    local file="$(find ~/md -name "*.md" 2>/dev/null | peco)"
#    [ ! "$file" = "" ] && vim "$file"
#}
#alias fvm="find_vim_markdown"

#
# ssh 時のWindow名を元に戻す
#
#function ssh() {
#    local window_name=$(tmux display -p '#{window_name}')
#    command ssh $@
#    tmux rename-window $window_name
#}

#
# agした結果をpecoで選択してvimで開く
#
function agvim () {
  vim $(ag "$@" | peco --query "$LBUFFER" | awk -F : '{print "-c " $2 " " $1}')
}

#
# history
#
function hisall () { history -E 1 }

#
# Git Diff Alias
#
function gdiff() {
    local DIFF
    if type -p git >/dev/null 2>&1; then
        DIFF="git diff --no-index --binary"
    else
        DIFF="diff -u"
    fi
    if [[ $# -eq 1 ]]; then
        $DIFF "$1~" "$1"
    else
        $DIFF "$@"
    fi
}

#
# fshow - git commit browser
#
fshow() {
  local out sha q
  while out=$(
      git log --graph --color=always \
          --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --multi --no-sort --reverse --query="$q" --print-query); do
    q=$(head -1 <<< "$out")
    while read sha; do
      git show --color=always $sha | less -R
    done < <(sed '1d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
  done
}

#
# available check
#
export FILTER="fzf:peco"
available () {
    local x candidates
    candidates="$1:"
    while [ -n "$candidates" ]
    do
        x=${candidates%%:*}
        candidates=${candidates#*:}
        if type "$x" >/dev/null 2>&1; then
            #echo "$x is enabled."
            return 0
        else
            continue
        fi
    done
    return 1
}
#available $FILTER

