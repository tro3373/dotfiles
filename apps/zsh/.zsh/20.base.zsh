## Environment variable configuration
## Default shell configuration

# umask settnig
umask 0002

# source zsh plugins. defined at 10.init.zsh.
source_pkg https://github.com/zsh-users/zsh-completions.git
source_pkg https://github.com/zsh-users/zsh-history-substring-search.git 1
source_pkg https://github.com/zsh-users/zsh-syntax-highlighting.git 1

#limit coredumpsize 0
#bindkey -d
#
# N-/ : means no add if not exist.
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

# keybind ^X^X
# export ONELINER_FILE="$DOTPATH/doc/misc/commands.txt"

setopt auto_cd              # 'cd'を打たなくてもディレクトリ名だけで移動できるようにする
setopt auto_pushd           # 移動ディレクトリ管理 ex) cd -3 ex) cd -<TAB> で履歴
setopt correct              # コマンドの打ち間違い(typo)を訂正してくれるようにする
setopt list_packed          # TAB補完時の候補を詰めて表示(一度にたくさん表示)
setopt noautoremoveslash    # パス名の最後につく'/'を自動的に削除しない
setopt nolistbeep           # 補完機能実行時にビープ音を鳴らさない
bindkey -v                  # <ESC>を押した時にvi風のキー操作ができるようにする

## コマンド履歴
# History
# History file
export HISTFILE=$HOME/.zsh_history
# History size in memory
export HISTSIZE=50000
# The number of histsize
export SAVEHIST=1000000
# The size of asking history
export LISTMAX=50
## Do not add in root
#if [ $UID = 0 ]; then
#    unset HISTFILE
#    export SAVEHIST=0
#fi
# コマンド履歴の検索時に <Ctrl-p>で履歴をさかのぼり、<Ctrl-n>で履歴を下る
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end
bindkey "\e[Z" reverse-menu-complete # <TAB>での補完候補の変更時に、<Shift-TAB>で逆順に変更する
setopt share_history            # コマンド履歴ファイルを複数のzshプロセス間で共有
#setopt hist_ignore_dups         # 直前のコマンドの重複を削除する。
#setopt hist_ignore_all_dups     # 重複するコマンドが記録される時、古い方を削除する。
#setopt hist_save_no_dups        # 重複するコマンドが保存される時、古い方を削除する。
#setopt hist_expire_dups_first   # 古い履歴を削除する必要がある場合、まず重複しているものから削除する。
#setopt hist_find_no_dups        # 履歴検索で重複しているものを表示しない。
setopt append_history           # 履歴を上書きしないで追加する。
setopt inc_append_history       # Add comamnds as they are typed, don't wait until shell exit
#setopt hist_no_store            # historyコマンドは除去する。
setopt extended_history         # 履歴保存時に時刻情報も記録する。
export HISTTIMEFORMAT='%Y-%M-%D %H:%M:%S '


## 補完機能
setopt complete_aliases         # エイリアスを展開してもとのコマンドをみつけて, そのコマンドに応じた補完
autoload zed                    # zsh editorを有効にする
# fpath=(${HOME}/.zsh/functions/Completion ${fpath})
# autoload -U compinit            # 補完機能を有効にする
# compinit
## 先方予測によるコマンド補完機能の設定
#autoload predict-on
#predict-off


## プロンプト
# 使用できる色は以下で確認できる
# ('\e[38;5;詳細前景色コードm'と'\e[m'で文字を囲むと文字が256色の設定ができる
# 文字色を変える場合は最初の数字を 38、背景の場合は 48を利用する)
#
#   for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done;echo
#  または
#   for c in {016..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($((c-16))%6)) -eq 5 ] && echo;done;echo
#
# colors: これ以降は${fg[色指定]}と${reset_color}で囲んだ部分がカラー表示になる。
# -U: 呼び出し側のシェルで alias 設定を設定していたとしても、中の関数側ではその影響を受けなくなる
# -z: 関数を zsh 形式で読み込む
autoload -Uz colors
colors
case ${UID} in
0)
    PROMPT="%{${fg[red]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') %B%{${fg[red]}%}%/#%{${reset_color}%}%b "
    PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
    SPROMPT="%B%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
    ;;
*)
    #PROMPT="%{${fg[cyan]}%}%/$%{${reset_color}%} "
    #PROMPT2="%{${fg[red]}%}%_%%%{${reset_color}%} "
    #SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
    # ???
    #PROMPT=$'%{\e[38;5;030m%}%m%(!.#.$)%{\e[m%} '
    # cyan
    #PROMPT=$'%{\e[38;5;030m%}%/$%{\e[m%} '
    PROMPT=$'%{\e[38;5;%(?.012.013)m%}%/>%{\e[m%} '
    PROMPT2=$'%{\e[38;5;%(?.012.013)m%}%_> %{\e[m%} '
    SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
        #PROMPT="%{${fg[magenta]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
        PROMPT="%{${fg[magenta]}%}$(echo ${HOST%%.*}) ${PROMPT}"
    ;;
esac


## ターミナル
case "${TERM}" in
screen)
    TERM=xterm
    ;;
esac

case "${TERM}" in
xterm|xterm-color)
    export LSCOLORS=exfxcxdxbxegedabagacad
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    # zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    # zshの補完にも同じ色を設定
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    ;;
kterm-color)
    stty erase '^H'
    export LSCOLORS=exfxcxdxbxegedabagacad
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
kterm)
    stty erase '^H'
    ;;
cons25)
    unset LANG
    export LSCOLORS=ExFxCxdxBxegedabagacad
    export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
jfbterm-color)
    export LSCOLORS=gxFxCxdxBxegedabagacad
    export LS_COLORS='di=01;36:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;36;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
esac

# dircolors 設定
#
if [[ -L ${HOME}/.dircolors || -e ${HOME}/.dircolors ]]; then
    if type dircolors > /dev/null 2>&1; then
        eval $(dircolors ${HOME}/.dircolors)
    elif type gdircolors > /dev/null 2>&1; then
        eval $(gdircolors ${HOME}/.dircolors)
    fi
fi

# ターミナルの時はタイトル部分にカレントディレクトリを表示する
#
case "${TERM}" in
xterm|xterm-color|kterm|kterm-color)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# --------------------------------------------------------
# zsh powerline 設定
# --------------------------------------------------------
#zshpowerline=${HOME}/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
#[ -f ${zshpowerline} ] && source ${zshpowerline}

