# Inisialize
export DOTPATH="$HOME/.dot"
export GENPATHF=$HOME/.path
export GENMANPATHF=$HOME/.manpath
export WORKPATHF=$HOME/.work.path
[ ${OSTYPE} = "msys" ] && export WINHOME=/c/Users/$(whoami)

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
  local nm=${url##*/}
  nm=${nm%%.git}
  local dst=~/.zsh/plugins/$nm
  if [[ ! -e $dst ]]; then
    echo "==> cloning $nm .."
    #git clone -q $url $dst
    git clone --depth 1 $url $dst
    echo "==> zcompiling $nm .."
    find $dst/ -name "*.zsh" | while read -r line; do zcompile $line; done
  fi
  local src=$dst/$nm.zsh
  if [[ $with_source -eq 1 && -e $src ]]; then
    source $src
  fi
}

source_pkgs() {
  source_pkg https://github.com/zsh-users/zsh-completions.git
  source_pkg https://github.com/zsh-users/zsh-history-substring-search.git 1
  source_pkg https://github.com/zsh-users/zsh-syntax-highlighting.git 1
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
  # for .works.zsh
  [[ -e $GENPATHF ]] && return
  export PATH="$@:$PATH"
}

add_manpath() {
  # for .works.zsh
  [[ -e $GENMANPATHF ]] && return
  export MANPATH="$@:$MANPATH"
}

gen_path_file() {
  local work_path=
  if [[ -e $WORKPATHF ]]; then
    echo "==> $WORKPATHF loaded."
    work_path="$(cat $WORKPATHF)"
  fi
  echo "$work_path:$PATH" |
    _uniq_path >$GENPATHF
  echo "==> $GENPATHF generated." 1>&2
}

gen_manpath_file() {
  echo "$MANPATH" |
    _uniq_path >$GENMANPATHF
  echo "==> $GENMANPATHF generated." 1>&2
}

_uniq_path() {
  local _path=
  IFS='$\n'
  cat - |
    tr ":" "\n" |
    while read -r p; do
      [[ -z $p ]] && continue
      [[ ! -e $p ]] && continue
      echo "==> p: $p" 1>&2
      if ! echo ":$_path:" | grep ":$p:" >&/dev/null; then
        # add if not added
        [[ -n $_path ]] && _path="$_path:"
        _path="$_path$p"
      fi
    done
  echo "$_path"
}

gen_path_file_ifneeded() {
  if [[ -e $GENPATHF ]]; then
    return
  fi
  # add_path ${JAVA_HOME}/bin # for java
  # add_path ${M2_HOME}/bin # for maven
  # add_path /opt/bin # for docker-machine
  # add_path /usr/local/heroku/bin # for heroku
  # add_path ${HOME}/Library/Android/sdk/platform-tools # for Android Mac.
  # add_path ${HOME}/Android/Sdk/platform-tools # for Android Linux.
  # add_path ${HOME}/android-studio/bin # for android

  # For Win.
  add_path "/mingw64/bin" # for silver searcher ag
  add_path "/c/Program Files (x86)/Google/Chrome/Application"
  add_path "/c/Program Files/Google/Chrome/Application"
  # add_path $HOME/win/tools/sublime-text-3
  # add_path $HOME/win/tools/atom/resources/app/apm/bin
  add_path "${HOME}/win/scoop/shims" # scoop

  # For Mac sed
  add_path "/usr/local/opt/coreutils/libexec/gnubin"
  add_path "/usr/local/opt/findutils/libexec/gnubin"
  add_path "/usr/local/opt/gnu-sed/libexec/gnubin"
  add_path "/usr/local/opt/gnu-tar/libexec/gnubin"
  add_path "/usr/local/opt/grep/libexec/gnubin"
  add_path "/usr/local/opt/gnu-indent/libexec/gnubin"
  add_path "/usr/local/opt/gnu-which/libexec/gnubin"

  # add main env path
  add_path ${HOME}/.local/bin
  add_path ${DOTPATH}/bin
  add_path ${HOME}/bin

  # load for add_path in .works.zsh
  load_zsh ~/.works.zsh

  # generate path file.
  gen_path_file
}

gen_manpath_file_ifneeded() {
  if [[ -e $GENMANPATHF ]]; then
    return
  fi

  # For Mac sed
  add_manpath "/usr/local/opt/coreutils/libexec/gnuman"
  add_manpath "/usr/local/opt/findutils/libexec/gnuman"
  add_manpath "/usr/local/opt/gnu-sed/libexec/gnuman"
  add_manpath "/usr/local/opt/gnu-tar/libexec/gnuman"
  add_manpath "/usr/local/opt/grep/libexec/gnuman"
  add_manpath "/usr/local/opt/gnu-indent/libexec/gnuman"
  add_manpath "/usr/local/opt/gnu-which/libexec/gnuman"

  # generate path file.
  gen_manpath_file
}

load_my_env() {
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

  gen_path_file_ifneeded
  export PATH="$(cat <$GENPATHF)"

  gen_manpath_file_ifneeded
  export MANPATH="$(cat <$GENMANPATHF)"
}

# is_vagrant() { hostname |grep archlinux.vagrant |grep -v grep >& /dev/null; }
is_vagrant() { pwd | grep /home/vagrant >&/dev/null; }

_initialize() {
  zcompile_ifneeded ~/.zshrc
  for z in $(ls ~/.zsh/*.zsh); do
    zcompile_ifneeded $z
  done
  load_my_env
  # is_vagrant && source ${DOTPATH}/bin/start_xvfb
  if is_vagrant; then
    export DISPLAY=:0
    ${DOTPATH}/bin/start_xvfb
  else
    ${DOTPATH}/bin/start_clipper
  fi
  # ${DOTPATH}/bin/tmux_dog
  load_zsh ~/.works.zsh
  #[ -f ~/.secret ] && . ~/.secret
  # source zsh plugins.
  source_pkgs
}
_initialize
