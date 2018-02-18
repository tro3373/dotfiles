## PATHの設定
#
export GENPATHF=~/.path
export WORKPATHF=~/.work.path
# function is_exist_path() {
#     echo "$PATH:" |grep "$@:" >& /dev/null
# }
function add_path() {
    [[ -e $GENPATHF ]] && return
    export PATH=$@:$PATH
    # local targetPath="$@"
    # #echo "==============> Add start!!!!!"
    # #echo "targetPath="$targetPath
    # if [ ! -f ${targetPath} ] &&
    #     [ ! -d ${targetPath} ] &&
    #     [ ! -L ${targetPath} ]; then
    #     # 存在しないパスの場合無視する.
    #     #echo "$targetPath is not exist. return."
    #     return
    # fi
    # # 既にパスに追加されている場合は削除する.
    # if is_exist_path $targetPath; then
    #     #echo "$targetPath is already pathed. remove it."
    #     # $targetPath を $PATH から削除.
    #     #PATH=${PATH#"$targetPath:"}
    #     PATH=`echo $PATH |sed -e "s|$targetPath||g" |sed -e 's/::/:/g'`
    # fi
    # #echo "$targetPath is will be pathed."
    # export PATH=$targetPath:$PATH
}

[ "${OSTYPE}" = "msys" ] && add_path "/mingw64/bin" # For silver searcher ag

# --------------------------------------------------------
# anyenv
# --------------------------------------------------------
if [ -d ${HOME}/.anyenv ] ; then
    add_path ${HOME}/.anyenv/bin
#    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init -)"
#     for D in `ls $HOME/.anyenv/envs`
#     do
#         export PATH="$HOME/.anyenv/envs/$D/shims:$PATH"
#     done
fi
## --------------------------------------------------------
## rbenv
## --------------------------------------------------------
#if [ -e ${HOME}/.rbenv ]; then
#    export PATH="$HOME/.rbenv/bin:$PATH"
#    eval "$(rbenv init -)"
#fi
## --------------------------------------------------------
## nvm
## --------------------------------------------------------
#if [ -e ${HOME}/.nvm ]; then
#    . ${HOME}/.nvm/nvm.sh
#    nvm use v0.10.38
#fi
## --------------------------------------------------------
## Python
## --------------------------------------------------------
#if [ "`which virtualenvwrapper.sh >/dev/null 2>&1; echo $?`" = "0" ]; then
#    export WORKON_HOME=$HOME/.virtualenvs
#    export PROJECT_HOME=$HOME/Devel
#    source virtualenvwrapper.sh
#fi
# --------------------------------------------------------
# Java
# --------------------------------------------------------
#javahome=${HOME}/bin/java/jdk1.6.0_45
#javahome=${HOME}/bin/java/jdk1.8.0_05
local javahome=${HOME}/bin/java/jdk1.8.0_20
if [ -e $javahome ]; then
    export JAVA_HOME=`echo "$javahome"`
    add_path ${JAVA_HOME}/bin
fi
# --------------------------------------------------------
# Maven
# --------------------------------------------------------
# see http://blog.beaglesoft.net/?p=762
# wget http://ftp.riken.jp/net/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
# tar xvfpz apache-maven-3.3.3-bin.tar.gz
local mvnhome=${HOME}/bin/apache-maven-3.3.3
if [ -e $mvnhome ]; then
    export M2_HOME=$mvnhome
    add_path ${M2_HOME}/bin
fi

# --------------------------------------------------------
# Gradle
# --------------------------------------------------------
local sdkmanhome="${HOME}/.sdkman"
local sdkmaninit="${sdkmanhome}/bin/sdkman-init.sh"
if [ -e $sdkmanhome ] && [ -s ${sdkmaninit} ]; then
    export SDKMAN_DIR=$sdkmanhome
    source ${sdkmaninit}
fi

# --------------------------------------------------------
# For docker-machine etc.
# --------------------------------------------------------
add_path /opt/bin
# For docker-machine settings.
#if `which docker-machine > /dev/null 2>&1` &&
#    [ -e $HOME/.docker/machine/machines/dev ]; then
#    echo "# For start docker-machine name \"dev\" and docker env setting."
#    echo "#  docker-mahine start dev"
#    echo "#  docker-mahine env dev"
#    echo "#  eval \"\$(docker-mahine env dev)\""
#fi

# --------------------------------------------------------
# Added by the Heroku Toolbelt
# --------------------------------------------------------
add_path /usr/local/heroku/bin

# --------------------------------------------------------
# Android
# --------------------------------------------------------
# Android Studioでresponsがなくなる？
# Ubuntu の設定
# http://tools.android.com/knownissues/ibus
#IBUS_ENABLE_SYNC_MODE=1 ibus-daemon -xrd
# For Mac.
add_path ${HOME}/Library/Android/sdk/platform-tools
# For Linux.
add_path ${HOME}/Android/Sdk/platform-tools
add_path ${HOME}/android-studio/bin

# For Win.
add_path "/c/Program Files (x86)/Google/Chrome/Application"
add_path "/c/Program Files/Google/Chrome/Application"
add_path $HOME/win/tools/sublime-text-3
add_path $HOME/win/tools/atom/resources/app/apm/bin

# Settings for golang
export GOPATH="$HOME/.go"
export GOROOT=$GOPATH/lib/go
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"

add_path ${HOME}/.local/bin
add_path ${DOTPATH}/bin
add_path ${HOME}/bin

function build_path() {
    if [[ -e $GENPATHF ]]; then
        export PATH="$(cat $GENPATHF)"
        return
    fi
    local work_path=
    if [[ -e $WORKPATHF ]]; then
        echo "==> $WORKPATHF loaded."
        work_path="$(cat $WORKPATHF)"
    fi
    PATH="$work_path:$PATH"
    local _path=
    IFS='$\n'
    echo $PATH |tr ":" "\n" |
        while read -r p; do
            [[ -z $p ]] && continue
            [[ ! -e $p ]] && continue
            # echo "==> p: $p"
            if ! echo "$_path:" |grep "$p:" >& /dev/null; then
                [[ -n $_path ]] && _path="$_path:"
                _path="$_path$p"
            fi
        done
    echo "$_path" > $GENPATHF
    echo "==> $GENPATHF generated."
    export PATH=$_path
}
build_path
