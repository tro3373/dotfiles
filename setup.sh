#!/bin/bash

################################################### SETTING START
#all_apps="git ctags curl tree global zsh tmux vim tig ssh ag _peco _fzf _gomi _zplug"
all_apps="git ctags curl tree global zsh tmux vim tig ssh nkf ag"
################################################### SETTING END git.io/tr3d

is_exist_app() {
    echo $all_apps |grep $1 > /dev/null 2>&1
    return $?
}

################################################### INITIALIZE START
# Rootディレクトリ
export DIR_ROOT=$(cd $(dirname $0); pwd)

# インストール用関数 ロード
source $DIR_ROOT/setup/setup_funcs.sh

# 起動引数設定
debug=0
dry_run=1
dry_run_commoands=""
# インストールコマンド 強制実行
force=0
# インストール対象アプリ
target_apps=()

for arg in "$@"
do
    case "$arg" in
        help|--help|-h)
            cat <<EOF

setup.sh [Option] [App App...]

  exec|--exec|-e
    execute install/setup process.
  force|--force|-f
    install process will be executed forcibly if already installed, and also setup process will be executed.
  debug|--debug|-d
    whith debug option

available Apps..
    $all_apps

EOF
            exit 0
            ;;
        exec|--exec|-e)
            dry_run=0
            ;;
        force|--force|-f)
            force=1
            ;;
        debug|--debug|-d)
            debug=1
            ;;
        *)
            if ! `is_exist_app $arg`; then
                echo "Unknow app $arg" 1>&2
                exit 1
            fi
            target_apps+=("$arg")
            ;;
    esac
done

if [[ ${#target_apps[@]} -eq 0 ]]; then
    # 指定無し時は全インストール
    for app in $all_apps; do
        target_apps=("${target_apps[@]}" $app)
    done
fi

if [[ $debug -eq 1 ]]; then
    for ((i = 0; i < ${#target_apps[@]}; i++)) {
        echo "target_apps[$i] = ${target_apps[i]}"
    }
    echo force=$force
    echo dry=$dry_run
fi
################################################### INITIALIZE END

# セットアップ開始
setup
echo "Done!"

