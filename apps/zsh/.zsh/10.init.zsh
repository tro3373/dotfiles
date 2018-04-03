# Inisialize
export DOTPATH="$HOME/.dot"
export GENPATHF=$HOME/.path
export WORKPATHF=$HOME/.work.path
[ ${OSTYPE} = "msys" ] && export WINHOME=/c/Users/`whoami`

has() { which ${1} >& /dev/null; }

zcompile_ifneeded() {
    if [[ ! -e $1.zwc || $1 -nt $1.zwc ]]; then
        echo "==> zcompiling $1 .."
        zcompile $1
    fi
}

load_zsh() {
    [[ ! -e $1 ]] && return
    zcompile_ifneeded $1
    source $1
}

source_pkg() {
    local url=$1
    local with_source=$2
    local nm=${url##*/}; nm=${nm%%.git}
    local dst=~/.zsh/plugins/$nm
    if [[ ! -e $dst ]]; then
        echo "==> cloning $nm .."
        #git clone -q $url $dst
        git clone --depth 1 $url $dst
        echo "==> zcompiling $nm .."
        find $dst -name "*.zsh" |while read -r line; do zcompile $line ; done
    fi
    local src=$dst/$nm.zsh
    if [[ $with_source -eq 1 && -e $src ]]; then
        source $src
    fi
}

# function is_exist_path() {
#     echo "$PATH:" |grep "$@:" >& /dev/null
# }
#
# add_path_uniq() {
#     local targetPath="$@"
#     #echo "==============> Add start!!!!!"
#     #echo "targetPath="$targetPath
#     if [ ! -f ${targetPath} ] &&
#         [ ! -d ${targetPath} ] &&
#         [ ! -L ${targetPath} ]; then
#         # 存在しないパスの場合無視する.
#         #echo "$targetPath is not exist. return."
#         return
#     fi
#     # 既にパスに追加されている場合は削除する.
#     if is_exist_path $targetPath; then
#         #echo "$targetPath is already pathed. remove it."
#         # $targetPath を $PATH から削除.
#         #PATH=${PATH#"$targetPath:"}
#         PATH=`echo $PATH |sed -e "s|$targetPath||g" |sed -e 's/::/:/g'`
#     fi
#     #echo "$targetPath is will be pathed."
#     export PATH=$targetPath:$PATH
# }

add_path() {
    [[ -e $GENPATHF ]] && return
    export PATH="$@:$PATH"
}

gen_path_file() {
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
            echo "==> p: $p"
            [[ ! -e $p ]] && continue
            if ! echo ":$_path:" |grep ":$p:" >& /dev/null; then
                # add if not added
                [[ -n $_path ]] && _path="$_path:"
                _path="$_path$p"
            fi
        done
    echo "$_path" > $GENPATHF
    echo "==> $GENPATHF generated."
}

load_my_env() {
    if [ -d ${HOME}/.anyenv ] ; then
        eval "$(anyenv init -)"
        # for D in `ls $HOME/.anyenv/envs`; do
        #     export PATH="$HOME/.anyenv/envs/$D/shims:$PATH"
        # done
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
    export JAVA_HOME=${HOME}/bin/java/jdk1.8.0_20
    # --------------------------------------------------------
    # Maven
    # --------------------------------------------------------
    # see http://blog.beaglesoft.net/?p=762
    # wget http://ftp.riken.jp/net/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
    # tar xvfpz apache-maven-3.3.3-bin.tar.gz
    export M2_HOME=${HOME}/bin/apache-maven-3.3.3
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
    # --------------------------------------------------------
    # Go
    # --------------------------------------------------------
    export GOPATH="$HOME/.go"
    export GOROOT=$GOPATH/lib/go
    export GOBIN="$GOPATH/bin"
}

is_vagrant() { hostname |grep archlinux.vagrant |grep -v grep >& /dev/null; }

_initialize() {
    zcompile_ifneeded ~/.zshrc
    for z in $(ls ~/.zsh/*.zsh); do
        zcompile_ifneeded $z
    done

    load_my_env

    if [[ ! -e $GENPATHF ]]; then
        add_path ${HOME}/.anyenv/bin # for anyenv
        add_path ${JAVA_HOME}/bin # for java
        add_path ${M2_HOME}/bin # for maven
        add_path /opt/bin # for docker-machine
        add_path /usr/local/heroku/bin # for heroku
        add_path ${HOME}/Library/Android/sdk/platform-tools # for Android Mac.
        add_path ${HOME}/Android/Sdk/platform-tools # for Android Linux.
        add_path ${HOME}/android-studio/bin # for android

        # For Win.
        add_path "/mingw64/bin" # for silver searcher ag
        add_path "/c/Program Files (x86)/Google/Chrome/Application"
        add_path "/c/Program Files/Google/Chrome/Application"
        add_path $HOME/win/tools/sublime-text-3
        add_path $HOME/win/tools/atom/resources/app/apm/bin

        add_path $GOBIN # for golang

        add_path ${HOME}/.local/bin
        add_path ${DOTPATH}/bin
        add_path ${HOME}/bin

        # load for add_path in .works.zsh
        load_zsh ~/.works.zsh

        # generate path file.
        gen_path_file
    fi
    export PATH="$(cat $GENPATHF)"

    is_vagrant && source ${DOTPATH}/bin/start_xvfb
    load_zsh ~/.works.zsh
    [ -f ~/.secret ] && . ~/.secret
}
_initialize

