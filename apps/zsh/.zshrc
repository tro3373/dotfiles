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
#
## It is necessary for the setting of DOTPATH
#if [[ -f ~/.path ]]; then
#    source ~/.path
#else
#    export DOTPATH="${0:A:t}"
#fi
#
## DOTPATH environment variable specifies the location of dotfiles.
## On Unix, the value is a colon-separated string. On Windows,
## it is not yet supported.
## DOTPATH must be set to run make init, make test and shell script library
## outside the standard dotfiles tree.
#if [[ -z $DOTPATH ]]; then
#    echo "$fg[red]cannot start ZSH, \$DOTPATH not set$reset_color" 1>&2
#    return 1
#fi
#
## Vital
## vital.sh script is most important file in this dotfiles.
## This is because it is used as installation of dotfiles chiefly and as shell
## script library vital.sh that provides most basic and important functions.
## As a matter of fact, vital.sh is a symbolic link to install, and this script
## change its behavior depending on the way to have been called.
#export VITAL_PATH="$DOTPATH/etc/lib/vital.sh"
#if [[ -f $VITAL_PATH ]]; then
#    source "$VITAL_PATH"
#fi
#
#antigen=~/.antigen
#antigen_plugins=(
##"b4b4r07/cli-finder"
#"b4b4r07/emoji-cli"
#"b4b4r07/enhancd"
#"b4b4r07/tmuxlogger"
#"b4b4r07/zsh-gomi"
#"b4b4r07/ssh-keyreg"
#"b4b4r07/zsh-vimode-visual"
#"brew"
#"hchbaw/opp.zsh"
#"zsh-users/zsh-completions"
#"zsh-users/zsh-history-substring-search"
#"zsh-users/zsh-syntax-highlighting"
#)
#
#setup_bundles() {
#    echo -e "$fg[blue]Starting $SHELL....$reset_color\n"
#
#    modules() {
#        e_arrow $(e_header "Setup modules...")
#
#        local -a modules_path
#        modules_path=(
#        ~/.zsh/[0-9]*.(sh|zsh)(N^*)
#        ~/.modules/*.(sh|zsh)(N^*)
#        )
#
#        local f
#        for f ($modules_path) source "$f" && echo "loading $f" | e_indent 2
#    }
#
#    # has_plugin returns true if $1 plugin are installed and available
#    has_plugin() {
#        #(( ${antigen_plugins[(I)$1]} ))
#        (( ${antigen_plugins[(I)${${(M)1:#*/*}:-"*"/${1#*/}}|${1#*/}]} ))
#        return $status
#    }
#
#    # bundle_install installs antigen and runs bundles command
#    bundle_install() {
#        # install antigen
#        git clone https://github.com/zsh-users/antigen $antigen
#        # run bundles
#        bundles
#    }
#
#    # bundles checks if antigen plugins are valid and available
#    bundles() {
#        if [[ -f $antigen/antigen.zsh ]]; then
#            e_arrow $(e_header "Setup antigen...")
#            source $antigen/antigen.zsh
#
#            # check plugins installed by antigen
#            local p
#            for p in ${antigen_plugins[@]}
#            do
#                echo "checking... $p" | e_indent 2
#                antigen-bundle "$p"
#            done
#
#            # apply antigen
#            antigen-apply
#        else
#            has "git" && echo "$fg[red]To make your shell strong, run 'bundle_install'.$reset_color"
#        fi
#    }
#
#    bundles; echo
#    modules; echo
#}
#
#zsh_zplug() {
#    [[ -d ~/.zplug ]] || {
#        git clone https://github.com/b4b4r07/zplug ~/.zplug
#        source ~/.zplug/zplug
#        zplug update --self
#    }
#
#    # For development
#    source ~/Dropbox/zplug/zplug
#
#    has_plugin() {
#        (( $+functions[zplug] )) || return 1
#        zplug check "${1:?too few arguments}"
#        return $status
#    }
#
#    zplug "b4b4r07/zplug"
#
#    # Local loading
#    zplug "~/.modules", from:local, nice:1, use:"*.sh"
#    zplug "~/.zsh",     from:local, nice:2
#
#    # Remote loading
#    zplug "b4b4r07/zsh-gomi",   as:command, use:bin/gomi
#    zplug "b4b4r07/http_code",  as:command, use:bin
#    zplug "b4b4r07/enhancd",    use:enhancd.sh
#    zplug "b4b4r07/emoji-cli",  if:"which jq"
#    zplug "mrowa44/emojify",    as:command
#    zplug "junegunn/fzf-bin",   as:command, from:gh-r, rename-to:fzf, frozen:1
#    zplug "zsh-users/zsh-completions"
#    zplug "zsh-users/zsh-history-substring-search"
#    zplug "zsh-users/zsh-syntax-highlighting", nice:19
#
#    if ! zplug check --verbose; then
#        printf "Install? [y/N]: "
#        if read -q; then
#            echo; zplug install
#        else
#            echo
#        fi
#    fi
#    zplug load --verbose
#}
#
#zsh_startup() {
#    # Exit if called from vim
#    [[ -n "$VIMRUNTIME" ]] && return
#
#    # Check whether the vital file is loaded
#    if ! vitalize 2>/dev/null; then
#        echo "$fg[red]cannot vitalize$reset_color" 1>&2
#        return 1
#    fi
#
#    # tmux_automatically_attach attachs tmux session automatically when your are in zsh
#    $DOTPATH/bin/tmuxx
#
#    zsh_zplug
#    # setup_bundles return true if antigen plugins and some modules are valid
#    # setup_bundles || return 1
#
#    # Display Zsh version and display number
#    echo -e "\n$fg_bold[cyan]This is ZSH $fg_bold[red]${ZSH_VERSION}$fg_bold[cyan] - DISPLAY on $fg_bold[red]$DISPLAY$reset_color\n"
#}
#
#if zsh_startup; then
#    # Important
#    zstyle ':completion:*:default' menu select=2
#
#    # Completing Groping
#    zstyle ':completion:*:options' description 'yes'
#    zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'
#    zstyle ':completion:*' group-name ''
#
#    # Completing misc
#    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
#    zstyle ':completion:*' verbose yes
#    zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
#    zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'
#    zstyle ':completion:*' use-cache true
#    zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
#
#    # Directory
#    zstyle ':completion:*:cd:*' ignore-parents parent pwd
#    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
#    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#
#    # default: --
#    zstyle ':completion:*' list-separator '-->'
#    zstyle ':completion:*:manuals' separate-sections true
#
#    # Menu select
#    zmodload -i zsh/complist
#    bindkey -M menuselect '^h' vi-backward-char
#    bindkey -M menuselect '^j' vi-down-line-or-history
#    bindkey -M menuselect '^k' vi-up-line-or-history
#    bindkey -M menuselect '^l' vi-forward-char
#    #bindkey -M menuselect '^k' accept-and-infer-next-history
#fi
#
## vim:fdm=marker fdc=3 ft=zsh ts=4 sw=4 sts=4:
#=====================================================================
#  zplug
#=====================================================================
# http://qiita.com/b4b4r07/items/cd326cd31e01955b788b
# http://blog.b4b4r07.com/entry/2015/12/13/174209
#
#  as: コマンドかプラグインかを指定する
#  use: source するファイルへの相対パスかパスを通すコマンドへの相対パスを指定する（glob パターンでも可）
#  from: 外部からの取得を行う
#  at: ブランチ/タグを指定したインストールをサポートする
#  rename-to: リネームしたい名前（コマンド時に有用）
#  dir: インストール先のディレクトリパス
#  if: 真のときダウンロードしたコマンド/プラグインを有効化する
#  hook-build: インストール後に実行するコマンド
#  frozen: 直接指定しないかぎりアップデートを禁止する
#  commit: コミットを指定してインストールする ($ZPLUG_SHALLOW が真かどうかに関わらず)
#  on: 依存関係
#  nice: 優先度（高 -20 〜 19 低）の設定をする。優先度の高いものから読み込む。10 以上を設定すると compinit のあとにロードされる
#
if [ -d ~/.zplug ] || [ -L ~/.zplug ]; then
    source ~/.zplug/init.zsh

    # Remote loading
    zplug "b4b4r07/zplug"
    zplug "b4b4r07/http_code", \
        as:command, \
        use:bin
    zplug "zsh-users/zsh-completions"
    local target
    local native_install=1
    case "$OSTYPE" in
        *'linux'*)
            target='*linux*amd64*'
            target_massren=$target
            ;;
        *'darwin'*)
            target='*darwin*amd64*'
            target_massren='*osx*'
            ;;
        *)
            target='os'
            target_massren='*win*'
            native_install=0
            ;;
    esac

    if [[ $native_install -eq 1 ]]; then
        zplug "b4b4r07/enhancd", \
            use:enhancd.sh
        zplug "stedolan/jq", \
            from:gh-r, \
            as:command, \
            rename-to:jq
        zplug "b4b4r07/emoji-cli", \
            on:"stedolan/jq"
        zplug "mrowa44/emojify", \
            as:command
        zplug "mollifier/cd-gitroot"
        zplug "zsh-users/zsh-history-substring-search"
        zplug "zsh-users/zsh-syntax-highlighting", nice:19
        zplug "yoshikaw/ClipboardTextListener", \
            as:command, \
            use:clipboard_text_listener.pl
        zplug "junegunn/fzf-bin", \
            from:gh-r, \
            at:0.13.2, \
            as:command, \
            use:"$target", \
            rename-to:fzf
        # zplug "b4b4r07/easy-oneliner" \
        #     on:"junegunn/fzf"
        zplug "b4b4r07/gomi", \
            as:command, \
            from:gh-r, \
            use:"$target", \
            rename-to:gomi
        zplug "junegunn/fzf", \
            as:command, \
            use:bin/fzf-tmux
        zplug "junegunn/fzf", \
            use:"shell/*.zsh"
        zplug "peco/peco", \
            as:command, \
            from:gh-r, \
            use:"$target"
        zplug "b4b4r07/dotfiles", \
            as:command, \
            use:bin/peco-tmux
        # file name 一括置換
        zplug "laurent22/massren", \
            as:command, \
            from:gh-r, \
            at:v1.3.0, \
            use:"$target_massren", \
            hook-build:"./massren --config editor vim"
    fi

    # Local loading
    zplug "~/.zsh", \
        from:local, \
        ignore:"*vcs-info.zsh", \
        nice:2

    # check コマンドで未インストール項目があるかどうか verbose にチェックし
    # false のとき（つまり未インストール項目がある）y/N プロンプトで
    # インストールする
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi
    # プラグインを読み込み、コマンドにパスを通す
    zplug load --verbose
fi

[ -f ~/.works.zsh ] && source ~/.works.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

