_init() {
  # Environment
  ######################################################
  export DOTPATH="$HOME/.dot"
  export CACHE_D="$HOME/.cache/zsh"
  export GOPATH=$HOME/go
  if is_vagrant; then
    export IS_VAGRANT=1
  fi
  export TERM=xterm-256color
  umask 0002 # umask settnig
  #bindkey -d                  # デフォルト設定に戻す
  bindkey -v               # <ESC>を押した時にvi風のキー操作ができるようにする
  setopt auto_cd           # 'cd'を打たなくてもディレクトリ名だけで移動できるようにする
  setopt auto_pushd        # 移動ディレクトリ管理 ex) cd -3 ex) cd -<TAB> で履歴
  setopt correct           # コマンドの打ち間違い(typo)を訂正してくれるようにする
  setopt list_packed       # TAB補完時の候補を詰めて表示(一度にたくさん表示)
  setopt noautoremoveslash # パス名の最後につく'/'を自動的に削除しない
  setopt nolistbeep        # 補完機能実行時にビープ音を鳴らさない
  setopt complete_aliases  # エイリアスを展開してもとのコマンドをみつけて, そのコマンドに応じた補完

  # LANG
  ######################################################
  export LANGUAGE="en_US.UTF-8" # LANGUAGE must be set by en_US
  # export LANGUAGE="ja_JP.UTF-8"
  [[ $UID -eq 0 ]] && LANGUAGE=C
  export LANG="${LANGUAGE}"
  # export LC_CTYPE="${LANGUAGE}"
  # export LC_CTYPE=ja_JP.UTF-8
  # export LC_MESSAGES=ja_JP.UTF-8
  # export LC_ALL="${LANGUAGE}"
  # export LC_TIME=en_DK.UTF8 # for time format: YYYY-MM-DD
  export LC_COLLATE=C # for default sort

  # Editor
  ######################################################
  export EDITOR=vim
  has nvim && export EDITOR=nvim
  export CVSEDITOR="${EDITOR}"
  export SVN_EDITOR="${EDITOR}"
  export GIT_EDITOR="${GIT_EDITOR:-${EDITOR}}"

  # Pager
  ######################################################
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

  # History
  ######################################################
  setopt share_history # コマンド履歴ファイルを複数のzshプロセス間で共有
  #setopt hist_ignore_dups         # 直前のコマンドの重複を削除する。
  #setopt hist_ignore_all_dups     # 重複するコマンドが記録される時、古い方を削除する。
  #setopt hist_save_no_dups        # 重複するコマンドが保存される時、古い方を削除する。
  #setopt hist_expire_dups_first   # 古い履歴を削除する必要がある場合、まず重複しているものから削除する。
  #setopt hist_find_no_dups        # 履歴検索で重複しているものを表示しない。
  setopt append_history     # 履歴を上書きしないで追加する。
  setopt inc_append_history # Add comamnds as they are typed, don't wait until shell exit
  #setopt hist_no_store            # historyコマンドは除去する。
  setopt extended_history # 履歴保存時に時刻情報も記録する。
  export HISTTIMEFORMAT='%Y-%M-%D %H:%M:%S '
  export HISTFILE=$HOME/.zsh_history # History file
  export HISTSIZE=50000              # History size in memory
  export SAVEHIST=1000000            # The number of histsize
  export LISTMAX=50                  # The size of asking history
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
  bindkey '\ep' history-beginning-search-backward-end
  bindkey '\en' history-beginning-search-forward-end
  bindkey "\e[Z" reverse-menu-complete # <TAB>での補完候補の変更時に、<Shift-TAB>で逆順に変更する

  # プロンプト
  ######################################################
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

      # path>
      # PROMPT=$'%{\e[38;5;%(?.012.013)m%}%* %/>%{\e[m%} '
      # time>
      # PROMPT="${fg[white]}%D{%H:%M:%S}>${reset_color} "

      ## Use 256 color
      # start: \e[38;5;詳細前景色m
      #   end: \e[m
      ## Use hard escape
      # start: %{\e[38;5;詳細前景色m%}
      #   end: %{\e[m%}
      ## Use color name
      # start: ${fg[white]}
      #   end: ${reset_color}
      # YYYY-MM-DD HH:mm:ss: %D{%Y-%m-%d %H:%M:%S}
      # h:mm:ss: %*
      # full path: %/
      # current path from home: %~
      # current directory: %c
      PROMPT=$'%{\e[38;5;%(?.012.013)m%}%D{%H:%M:%S} %c>%{\e[m%} '
      PROMPT2=$'%{\e[38;5;%(?.012.013)m%}%_> %{\e[m%} '
      SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
      [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
        #PROMPT="%{${fg[magenta]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
        PROMPT="%{${fg[magenta]}%}$(echo ${HOST%%.*}) ${PROMPT}"

      # if [[ ${OSTYPE} != "msys" ]]; then
      #   setopt prompt_subst
      #   zstyle ':vcs_info:git:*' check-for-changes true
      #   zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
      #   zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
      #   zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
      #   zstyle ':vcs_info:*' actionformats '[%b|%a]'
      #   precmd () { vcs_info }
      #   RPROMPT=$RPROMPT'${vcs_info_msg_0_}'
      # fi
      ;;
  esac
}
_init
