#!/usr/bin/env bash

current_dir=$(pwd)
script_dir=$(cd $(dirname $0); pwd)
tmux_home=~/.tmux

has() {
    which ${1} >/dev/null 2>&1
    return $?
}

get_settings_version() {
    local installed_version="$1"
    local version="$installed_version"
    for d in `find $tmux_home/ -maxdepth 1 -type d |egrep '[0-9]+\.[0-9]+' | sort -u`; do
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

gen_version_file() {
    if ! has bc; then
        echo "[[[!!!WARNING!!!]]]No bc command exists." 1>&2
        exit 2
    fi
    local version_file=$1
    local installed_version=$(tmux -V | cut -d' ' -f2)
    local use_settings_version=$(get_settings_version $installed_version)
    echo $use_settings_version > $version_file
    echo "====> $use_settings_version VERSION file created."
}

main() {
    local version_file=$tmux_home/VERSION
    if [[ ! -e $version_file ]]; then
        gen_version_file $version_file
    fi
    local version="$(cat $version_file)"
    local path="$tmux_home/$version/tmux.conf"
    local path2="$tmux_home/$version/tmux.conf.$(osconf)"
    tmux source-file "$path"
    tmux source-file "$path2"
}

main "$@"
