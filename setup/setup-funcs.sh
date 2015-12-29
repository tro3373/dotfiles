#!/bin/bash

# echo するのみ
log() {
    echo "$*"
}
logescape() {
    echo -e "$*"
}

# コマンド実行
# log メソッドを呼びつつ実行する
vexec() {
    cmd="$*"
    log " Exec: $cmd"
    eval $cmd
    if [ $? -eq 0 ]; then
        log "    => Command Sucessfully."
    else
        log "    => Command Failed......"
    fi
}

# コマンドダミー実行
# echoするのみ
dry_vexec() {
    cmd="$*"
    log " Dummy Exec: $cmd"
}

# コマンドがインストールされているかチェックする
testcmd() {
    cmd=`which $1`
    if [ -n "`echo "${cmd}" | grep 'not found'`" ]; then
        return 1
    elif [ "$cmd" = "" ]; then
        return 1
    else
        return 0
    fi
}

# $* が存在するかどうか判定する
isexist() {
    file="$*"
    count=`ls -a "$file" 2>/dev/null |wc -l|sed 's/ //g'`
    if [ "$count" == "0" ]; then
        # 存在しない場合は bash 内で false の意味を表す 1 を応答する.
        return 1
    fi
    # 存在する場合は bash 内で true の意味を表す 0 を応答する.
    return 0
}

# $1のファイルを$2へリンクを作成する
make_link() {
    from=$1
    to=$2
    dvexec "ln -s \"$from\" \"$to\""
}

# Dry run 実行用の関数定義
dvexec() {
    cmd="$*"
    if [ "$dry_run" = "0" ]; then
        vexec $cmd
    else
        dry_vexec $cmd
        dry_run_commoands="$dry_run_commoands\n Dummy Exec: $cmd"
    fi
}

# $* のリンクを 絶対パスで表示する（readlink -f の代用（For Mac））
# echo 結果がパスとして使用される為、log 実行時は正しく動作しない
readlink_path() {
    target="$*"
    if [ "$target" = "" ]; then
        echo "Error!!! readlink_path Error!!!!!!!! argument is blank!!"
        return
    fi
    #log "@@@@@@@@@@@@@@@@@@@@@ Start is $target"
    buf="`echo $target`"
    pre=""
    while [ "$buf" != "" ]; do
        pre="`echo $buf`"
        buf="`readlink "$buf"`"
    done
    #log "@@@@@@@@@@@@@@@@@@@@@ pre is $pre"
    echo "$pre"
}

# $* ディレクトリ配下の dot file をHOMEへリンクを作成する
make_link_dot2home() {
    local dir="$*"
    for file in `cd "$dir" && /bin/ls -a | grep -v ^.git$ | grep -v ^.gitignore$ | grep -v ^.gitkeep$ | egrep '^\.[^.]+'`; do
        make_link_bkupable "$dir/$file" "${HOME}/$file"
    done
}

# 同じリンクかどうか
issamelink() {
    src1=$1
    src2=$2
    if [ "$src1" = "$src2" ]; then
        return 1
    fi
    if [ "$src1/" = "$src2" ]; then
        return 1
    fi
    if [ "$src1" = "$src2/" ]; then
        return 1
    fi
    return 0
}

# $1のファイルを$2へリンクを作成する
make_link_bkupable() {
    local src=$1
    local lnk=$2
    local need_backup=0
    [[ $debug -eq 1 ]] && log " make_link_bkupable Start lnk=$lnk src=$src"
    #if [ -e "${lnk}" ]; then
    if isexist "${lnk}"; then
        # log "   @@@@@@ exist!"
        # ファイルタイプ(ファイル、ディレクトリ、リンク)をチェック
        #if [ -n "`find "${lnk}" -maxdepth 0 -type l`" ]; then
        if [ -L "${lnk}" ]; then
            # リンク
            # log "   @@@@@@ Link!"
            local fullpath_lnk="`readlink_path "${lnk}"`"
            local fullpath_src="`readlink_path "${src}"`"
            # log "    lnk:$lnk => fullpath_lnk=$fullpath_lnk"
            # log "    src:$src => fullpath_src=$fullpath_src"
            if ! issamelink "$fullpath_lnk" "$fullpath_src"; then
                # 既に自分へのリンクの場合はなにもしない
                [[ $debug -eq 1 ]] && log "  => Already linked. Skip it. path=${lnk}"
                return 0
            else
                # 他ファイルへのリンクなのでバックアップする
                log "  => Not match link. backup it. old link is ${fullpath_lnk} => new link is ${fullpath_src}"
                need_backup=1
            fi
        elif [ -d "${lnk}" ]; then
            # ディレクトリはバックアップする
            # log "   @@@@@@ Dir!"
            log "  => Directory exist. Backup it. path=$lnk"
            need_backup=1
        elif [ -f "${lnk}" ]; then
            # 既存のファイルをバックアップする
            # log "   @@@@@@ File!"
            log "  => File exist. Backup it. path=$lnk"
            need_backup=1
        else
            # log "   @@@@@@ little bit!"
            # ないと思う
            log "  => Little bit strange exist. path=${lnk} ... Do nothing"
            return 0
        fi
    fi
    # バックアップが必要ならバックアップする
    if [ $need_backup -eq 1 ]; then
        # log "   @@@@@@ Backup!"
        bkup_orig_file "${lnk}"
    fi
    make_link "$src" "$lnk"
}

# $* のファイルを${DIR_BACKUP}に移動する
bkup_orig_file() {
    local bkuptarget="$*"
    # バックアップ先のディレクトリがない場合は作成する
    if [ ! -e "${DIR_BACKUP}" ]; then
        dvexec "mkdir -p \"${DIR_BACKUP}\""
    fi

    # バックアップ先ディレクトリにmv
    dvexec "mv -fv \"$bkuptarget\" \"${DIR_BACKUP}\"/"
    delifexist $bkuptarget
    BACKUP="${BACKUP}\nbackup to ${DIR_BACKUP}/`basename $1`"
}

# 存在する場合のみ削除
delifexist() {
    local rmtarget="$*"
    if [ "$rmtarget" = "/" ]; then
        log "invalid rm path $rmtarget"
        return
    fi
    if isexist "$rmtarget"; then
        dvexec "rm -rf \"$rmtarget\""
    fi
}

# instcmd 設定
setup_instcmd() {
    # OS 種類取得
    OS=`$DIR_ROOT/bin/dist_ditect`
    # Install command
    instcmd="sudo apt-get install -y"
    if [ "$OS" = "mac" ]; then
         instcmd="brew install"
    elif [ "$OS" = "redhat" ]; then
         instcmd="sudo yum install -y"
    elif [ "$OSTYPE" = "cygwin" ]; then
         instcmd="apt-cyg install"
    fi
}

initialize() {
    if [ "$DIR_ROOT" = "" ]; then
        DIR_ROOT=~/dotfiles
    fi
    # 各アプリ個別設定用のファイル名
    FIL_CONF=config.sh
    # インストールアプリディレクトリ
    DIR_APP=$DIR_ROOT/apps
    # バックアップ先ディレクトリ
    DIR_BACKUP="${DIR_ROOT}/bkup/`date +%Y%m%d%H%M%S`"
    # バックアップしたファイルを後でまとめて表示する
    BACKUP=""
    # instcmd 設定
    setup_instcmd
    # ~/bin 作成
    if [ ! -e ~/bin ]; then
        mkdir ~/bin
    fi
}
initialize

# Function 初期化
initialize_funcs() {
    # デフォルト関数ロード
    source $DIR_ROOT/setup/default-config.sh
}

# セットアップ開始
setup() {
    initialize

    # -e: Exit when error occur.
    # -u: Exit when using undefined variable.
    set -eu

    # スクリプトが置かれているパスに移動する
    cd $DIR_ROOT

    # Mac 用 Brew インストールチェック
    if [ "$OS" = "mac" ]; then
        if ! testcmd brew; then
            log "================================================"
            log " HomeBrew is Not Installed!"
            log "  => Execute this and Install it!"
            log ""
            log '  echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile'
            log "  sudo mkdir /usr/local/"
            log '  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"'
            log "  source ~/.bash_profile"
            log "  brew update"
            log "  brew -v"
            log ""
            exit 1
        fi
    fi

    # app ディレクトリ配下のディレクトリに対して、インストール処理を実行
    # mac/linux にかかわらず、実行される
    for ((i = 0; i < ${#target_apps[@]}; i++)) {
        # ディレクトリ名＝アプリ名の前提
        app=${target_apps[i]}

        if [ ! -d $DIR_APP/$app ]; then
            # ディレクトリ以外は無視
            continue
        fi

        # デフォルト関数ロード
        # 下記 vexec source $instshell にて、install, setconfig メソッドが
        # 上書き定義される為、ここで初期化する
        initialize_funcs

        [[ $debug -eq 1 ]] && log "================================================"
        log "===> $DIR_APP/$app"
        whith_install=0
        if ! testcmd $app; then
            [[ $debug -eq 1 ]] && log "    => Not Installed..."
            whith_install=1
        fi

        # デフォルトのインストールコマンド
        def_instcmd="$instcmd $app"
        instshell=$DIR_APP/$app/$FIL_CONF
        if [ -e "$instshell" ]; then
            # 個別インストール設定ファイルが存在する場合は、それを実行
            # shell を読み込み、install, setconfigメソッドをロード
            source $instshell

            # 各スクリプト内で以下コマンドでパスを取得できていたが、、、
            # ここで定義しておけば良いことに気づいたので設定しておく
            # # source されるスクリプトを考慮した ファイルの存在するディレクトリ
            # script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE}}")"; pwd)"
            script_dir=$DIR_APP/$app

            if [ "$whith_install" = "1" ] || [ "$force_install" = "1" ]; then
                # インストールされていない場合は実行
                # 読み込んだ install コマンドの実行
                install
            fi
            if testcmd $app; then
                # install されている場合
                # 読み込んだ setconfig コマンドの実行
                setconfig
            fi
        else
            # 個別インストール設定ファイルが存在しない場合は
            # デフォルトのインストールコマンド実行
            if [ "$whith_install" = "1" ]; then
                # インストールされていない場合は実行
                [[ $debug -eq 1 ]] && log " Execute Default install command"
                dvexec $def_instcmd
            fi
        fi
    }

#    # powerlineインストール処理を実行
#    powerlineconfig=$DIR_ROOT/powerline/$FIL_CONF
#    if [ "$EXE_POWERLINE" = "1" ] && [ -e "$powerlineconfig" ]; then
#        source $powerlineconfig
#        script_dir=$DIR_ROOT/powerline
#        # 読み込んだ setconfig コマンドの実行
#        log "================================================"
#        log "===> $powerlineconfig"
#        setconfig
#    fi

    if [ "$dry_run" = "1" ]; then
        log ""
        log ""
        log "===================================================="
        log "==>  This is Dry-run mode."
        log "==>     Specify 'exec/--exec/-e' option for execute."
        log "==>     Below commands will be execute."
        logescape $dry_run_commoands
        log "===================================================="
    else
        logescape $dry_run_commoands
        if [ ! "$BACKUP" = "" ]; then
            log "======================================>"
            log " Below files is backuped."
            logescape $BACKUP
        fi
    fi
}
