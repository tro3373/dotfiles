#
# tmux start settings
#
is_exists() { type "$1" >/dev/null 2>&1; return $?; }
is_osx() { [[ $OSTYPE == darwin* ]]; }
is_screen_running() { [ ! -z "$STY" ]; }
is_tmux_runnning() { [ ! -z "$TMUX" ]; }
is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
shell_has_started_interactively() { [ ! -z "$PS1" ]; }
auto_exit_shell() { echo "Auto exiting.." && sleep 0.5 && exit; }
is_enabled() {
    #[[ -z "$SSH_CONNECTION" ]] && return 0 # always run in local
    local _enabled=~/.tmux_enabled
    local _disabled=~/.tmux_disabled
    [[ -e $_enabled ]] && return 0 # tmux enabled
    [[ -e $_disabled ]] && return 1 # tmux disabled

    # gen process
    echo "==> enable tmux?(yN)"
    read res
    local ret=1
    local gen_file=$_disabled
    [[ $res =~ (y|Y) ]] && gen_file=$_enabled && ret=0
    touch $gen_file
    return $ret
}

tmux_automatically_attach_session() {

    ! shell_has_started_interactively && return 0
    ! is_enabled && return 0
    is_screen_running && echo "This is on screen." && return 1
    ! is_exists 'tmux' && echo 'Error: tmux command not found' 2>&1 && return 1

    # already tmux running.
    is_tmux_runnning && return 0

    # echo
    # echo "${fg_bold[red]} _____ __  __ _   ___  __ ${reset_color}"
    # echo "${fg_bold[red]}|_   _|  \/  | | | \ \/ / ${reset_color}"
    # echo "${fg_bold[red]}  | | | |\/| | | | |\  /  ${reset_color}"
    # echo "${fg_bold[red]}  | | | |  | | |_| |/  \  ${reset_color}"
    # echo "${fg_bold[red]}  |_| |_|  |_|\___//_/\_\ ${reset_color}"
    # echo

    if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
        # detached session exists
        tmux list-sessions
        echo -n "Tmux: attach? (y/N/num) "
        read
        if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
            tmux attach-session
            if [ $? -eq 0 ]; then
                echo "$(tmux -V) attached session"
                return 0
            fi
        elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
            tmux attach -t "$REPLY"
            if [ $? -eq 0 ]; then
                echo "$(tmux -V) attached session"
                return 0
            fi
        fi
    fi
    # tmux new-session && auto_exit_shell
    tmux new-session
    exit
}
tmux_automatically_attach_session

