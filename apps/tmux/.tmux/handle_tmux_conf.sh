#!/usr/bin/env bash

current_dir=$(pwd)
script_dir=$(cd $(dirname $0); pwd)

get_setting_version() {
    local installed_version="$1"
    local version="$installed_version"
    local tmux_home=~/.tmux/
    for d in `find $tmux_home -maxdepth 1 -type d |egrep '[0-9]+\.[0-9]+' | sort -u`; do
        version=$(basename $d)
        local tmp=$(echo "$version >= $installed_version" | bc)
        if [[ $tmp -eq 1 ]]; then
            break
        fi
    done
    echo $version
}

osconf() {
    local ret=linux
    case "$(uname)" in
        *Darwin*) ret=macosx ;;
        *CYGWIN*) ret=cygwin ;;
        *MSYS*) ret=msys ;;
    esac
    echo $ret
}

main() {
    local tmux_home=~/.tmux
    local installed_version=$(tmux -V | cut -d' ' -f2)
    local version=$(get_setting_version $installed_version)
    local path="$tmux_home/$version/tmux.conf"
    local path2="$tmux_home/$version/tmux.conf.$(osconf)"
    tmux source-file "$path"
    tmux source-file "$path2"
}

main "$@"

