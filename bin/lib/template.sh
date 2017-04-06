#!/usr/bin/env bash

current_dir=$(pwd)
script_dir=$(cd $(dirname $0); pwd)
command_name=$(basename $0)

usage() {
    cat <<EOF
Description for this command.
  Usage:
      $command_name [option]
    Options
      -h|--help : Show this usage
EOF
}

has() {
    which ${1} >/dev/null 2>&1
    return $?
}

add_args() {
    args=("${args[@]}" "$@")
}

set_args() {
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                usage
                exit 0
                ;;
            # -f*|--file*)
            #     file=${arg#*=}
            #     ;;
            *)
                add_args "$arg"
                ;;
        esac
    done
}

initialize() {
    args=()
    set_args "$@"
}

main() {
    initialize "$@"
    for arg in "${args[@]}"; do
        echo "Arguments: $arg"
    done
}
main "$@"

