#
# tmux start settings
#
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONNECTION" ]; }
function auto_exit_shell() { echo "Auto exiting.." && sleep 0.5 && exit; }

function tmux_automatically_attach_session() {

    ! shell_has_started_interactively && return 0
    #is_ssh_running && return 0
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
}
tmux_automatically_attach_session

