_initialize() {
  # Inisialize
  export DOTPATH="$HOME/.dot"
  export GENPATHF=$HOME/.path
  export GENMANPATHF=$HOME/.manpath
  export WORKPATHF=$HOME/.work.path
  export TERM=xterm-256color
  if grep -qE "(Microsoft | WSL)" /proc/version &>/dev/null; then
    export WSL=1
    unsetopt BG_NICE
  fi
  if is_vagrant; then
    export IS_VAGRANT=1
  fi
  if is_msys; then
    export WINHOME=/c/Users/$(whoami)
    export MSYS=winsymlinks:nativestrict # enable symbolic link in admined msys
  fi
  if is_wsl; then
    export WINHOME=/mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
  fi

  if [[ ! -e $GENPATHF ]]; then
    _gen_path_file
  fi
  export PATH="$(cat <$GENPATHF)"

  if [[ ! -e $GENMANPATHF ]]; then
    _gen_manpath_file
  fi
  export MANPATH="$(cat <$GENMANPATHF)"
}

_gen_path_file() {
  #------------------------------------------------------
  # NOTE: add_path: Added later has high priority
  #------------------------------------------------------

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

  # For Mac gnu command tools
  if is_mac; then
    find /opt/homebrew/opt/*/libexec/gnubin -type d 2>/dev/null |
      while read -r line; do
        add_path "$line"
      done
  fi

  # add main env path
  add_path /usr/local/sbin
  add_path /usr/local/bin
  add_path ${HOME}/.cargo/bin
  add_path ${HOME}/.local/bin
  add_path ${DOTPATH}/bin
  add_path ${HOME}/bin

  # NOTE: Load .works.zsh to execute add_path.
  # 90.additional.zsh load .works.zsh again.
  load_zsh ~/.works.zsh

  # generate path file.
  local work_path=
  if [[ -e $WORKPATHF ]]; then
    echo "==> $WORKPATHF loaded."
    work_path="$(cat $WORKPATHF)"
  fi
  echo "$work_path:$PATH" |
    _uniq_path >$GENPATHF
  echo "==> $GENPATHF generated." 1>&2
}

add_path() {
  # for .works.zsh
  [[ -e $GENPATHF ]] && return
  export PATH="$@:$PATH"
}

_gen_manpath_file() {
  # For Mac sed
  add_manpath "/usr/local/opt/coreutils/libexec/gnuman"
  add_manpath "/usr/local/opt/findutils/libexec/gnuman"
  add_manpath "/usr/local/opt/gnu-sed/libexec/gnuman"
  add_manpath "/usr/local/opt/gnu-tar/libexec/gnuman"
  add_manpath "/usr/local/opt/grep/libexec/gnuman"
  add_manpath "/usr/local/opt/gnu-indent/libexec/gnuman"
  add_manpath "/usr/local/opt/gnu-which/libexec/gnuman"

  echo "$MANPATH" |
    _uniq_path >$GENMANPATHF
  echo "==> $GENMANPATHF generated." 1>&2
}

add_manpath() {
  # for .works.zsh
  [[ -e $GENMANPATHF ]] && return
  export MANPATH="$@:$MANPATH"
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

# is_vagrant() { hostname |grep archlinux.vagrant |grep -v grep >& /dev/null; }
is_vagrant() { pwd | grep /home/vagrant >&/dev/null; }
#is_wsl() { [[ -n $WSL_DISTRO_NAME ]]; }
is_wsl() { [[ -e /proc/version ]] && grep -qi microsoft /proc/version; }
is_msys() { [[ ${OSTYPE} == "msys" ]]; }
is_mac() { [[ ${OSTYPE} =~ ^darwin.*$ ]]; }

_initialize
