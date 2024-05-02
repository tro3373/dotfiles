_additional() {
  load_zsh ~/.works.zsh
  # load_zsh ~/.fzf.zsh
  #[ -f ~/.secret ] && . ~/.secret
}
_additional

_is_remote() { [[ -n "${REMOTEHOST}${SSH_CONNECTION}" ]]; }

_start_process() {
  if is_vagrant; then
    # is_vagrant && source ${DOTPATH}/bin/start_xvfb
    export DISPLAY=:0
    ${DOTPATH}/bin/start_xvfb
    return
  fi

  if is_wsl; then
    if ! test -e /tmp/dockerd.log; then
      ${DOTPATH}/bin/start_dockerd &
    fi
    if ! test -e /tmp/sshd.log && [[ $ENABLE_SSHD == 1 ]]; then
      ${DOTPATH}/bin/start_sshd
    fi
  fi

  if _is_remote; then
    # ! is_orb && return
    return
  fi

  if ! test -e /tmp/clipd.pid; then
    # nohup ${DOTPATH}/bin/clip -d >&/dev/null &
    ${DOTPATH}/bin/clip -d >&/dev/null &
  fi
  # ${DOTPATH}/bin/tmux_dog
}
_start_process
