_additional() {
  load_zsh ~/.works.zsh
  load_zsh ~/.fzf.zsh
  [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh
  #[ -f ~/.secret ] && . ~/.secret
  _load_sops_env ~/.config/sops/env/global.enc.env
}

# sops の暗号ファイルを復号して環境変数に載せる。平文はディスクに出さない (キャッシュもしない)。
_load_sops_env() {
  [[ -f $1 ]] && has sops && has direnv || return 0
  eval "$(sops exec-env "$1" 'direnv dump zsh')"
}
_additional

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

  if _remote_now; then
    # ! is_orb && return
    return
  fi

  # if ! test -e /tmp/clipd.pid; then
  #   # nohup ${DOTPATH}/bin/clip -d >&/dev/null &
  #   ${DOTPATH}/bin/clip -d >&/dev/null &
  # fi
  # ${DOTPATH}/bin/tmux_dog
}
_start_process
