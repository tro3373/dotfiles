# ターミナルの時はタイトル部分にカレントディレクトリを表示する
case "${TERM}" in
xterm|xterm-color|kterm|kterm-color)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

## ターミナル
[[ $TERM == "screen" ]] && export TERM="xterm"
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


# # --------------------------------------------------------
# # Java
# # --------------------------------------------------------
# export JAVA_HOME=${HOME}/bin/java/jdk1.8.0_20
# # --------------------------------------------------------
# # Maven
# # --------------------------------------------------------
# # see http://blog.beaglesoft.net/?p=762
# # wget http://ftp.riken.jp/net/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
# # tar xvfpz apache-maven-3.3.3-bin.tar.gz
# export M2_HOME=${HOME}/bin/apache-maven-3.3.3
# # --------------------------------------------------------
# # Gradle
# # --------------------------------------------------------
# local sdkmanhome="${HOME}/.sdkman"
# local sdkmaninit="${sdkmanhome}/bin/sdkman-init.sh"
# if [ -e $sdkmanhome ] && [ -s ${sdkmaninit} ]; then
#     export SDKMAN_DIR=$sdkmanhome
#     source ${sdkmaninit}
# fi
# --------------------------------------------------------
# For docker-machine etc.
# --------------------------------------------------------
# For docker-machine settings.
#if `which docker-machine > /dev/null 2>&1` &&
#    [ -e $HOME/.docker/machine/machines/dev ]; then
#    echo "# For start docker-machine name \"dev\" and docker env setting."
#    echo "#  docker-mahine start dev"
#    echo "#  docker-mahine env dev"
#    echo "#  eval \"\$(docker-mahine env dev)\""
#fi
# --------------------------------------------------------
# Android
# --------------------------------------------------------
# Android Studioでresponsがなくなる？
# Ubuntu の設定
# http://tools.android.com/knownissues/ibus
#IBUS_ENABLE_SYNC_MODE=1 ibus-daemon -xrd
