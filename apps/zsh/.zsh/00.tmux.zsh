#
# tmux start settings
#

# add_usr_local_bin_path() { if ! has tmux; then export PATH=/usr/local/bin:$PATH; fi; }
is_tmux_runnning() { [ ! -z "$TMUX" ]; }
shell_has_started_interactively() { [ ! -z "$PS1" ]; }
is_enabled() {
  local _enabled=~/.tmux_enabled
  local _disabled=~/.tmux_disabled
  [[ -e $_enabled ]] && return 0  # tmux enabled
  [[ -e $_disabled ]] && return 1 # tmux disabled

  # gen process
  log "==> enable tmux?(yN)"
  read res
  local ret=1
  local gen_file=$_disabled
  [[ $res =~ (y|Y) ]] && gen_file=$_enabled && ret=0
  touch $gen_file
  return $ret
}

tmux_automatically_attach_session() {

  # add_usr_local_bin_path
  ! shell_has_started_interactively && return 0
  ! is_enabled && return 0
  # is_screen_running && log "This is on screen." && return 1
  ! has tmux && log 'Error: tmux command not found' && return 1

  # already tmux running.
  is_tmux_runnning && return 0

  # log
  # log "${fg_bold[red]} _____ __  __ _   ___  __ ${reset_color}"
  # log "${fg_bold[red]}|_   _|  \/  | | | \ \/ / ${reset_color}"
  # log "${fg_bold[red]}  | | | |\/| | | | |\  /  ${reset_color}"
  # log "${fg_bold[red]}  | | | |  | | |_| |/  \  ${reset_color}"
  # log "${fg_bold[red]}  |_| |_|  |_|\___//_/\_\ ${reset_color}"
  # log

  if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
    # detached session exists
    tmux list-sessions
    log "Tmux: attach? (Y/n/num) "
    read
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ $REPLY == '' ]]; then
      tmux attach-session
      if [ $? -eq 0 ]; then
        log "$(tmux -V) attached session"
        return 0
      fi
    elif [[ $REPLY =~ ^[0-9]+$ ]]; then
      tmux attach -t "$REPLY"
      if [ $? -eq 0 ]; then
        log "$(tmux -V) attached session"
        return 0
      fi
    fi
  fi
  # tmux new-session && auto_exit_shell
  tmux new-session
  exit
}
tmux_automatically_attach_session
