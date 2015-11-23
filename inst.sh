#!/bin/bash

################################################### SETTING START
# OS 個別設定を実行するかどうか
EXE_OSCONF=1
# インストールコマンド DEBUG 実行
TEST_INSCMD=0
################################################### SETTING END

################################################### INITIALIZE START
# Rootディレクトリ
cd `dirname $0`
DIR_ROOT=${PWD}
# 各アプリ個別設定用のファイル名
FIL_CONF=config.sh

# インストールアプリディレクトリ
DIR_APP=$DIR_ROOT/apps
# バックアップ先ディレクトリ
DIR_BACKUP="${DIR_ROOT}/bkup/`date +%Y%m%d%H%M%S`"
# バックアップしたファイルを後でまとめて表示する
BACKUP=""

# インストール用関数 ロード
source $DIR_ROOT/inst.funcs.sh

# 起動引数設定
DRYRUN=1
DRYRUNCMD=""
INSTAPP=""
# ${@:3}
if [ $# -eq 2 ] && [ "$1" = "exec" ]; then
    DRYRUN=0
    INSTAPP=$2
elif [ "$1" = "exec" ]; then
    DRYRUN=0
elif [ $# -eq 1 ]; then
    # 引数1、ダミー実行
    INSTAPP=$1
fi
################################################### INITIALIZE END

# Function 初期化
initialize_funcs() {
    # デフォルト関数ロード
    source $DIR_ROOT/inst.funcs.defconfig.sh
}

# Dry run 実行用の関数定義
dvexec() {
    cmd="$*"
    if [ "$DRYRUN" = "0" ]; then
        vexec $cmd
    else
        dry_vexec $cmd
        DRYRUNCMD="$DRYRUNCMD\n Dummy Exec(echo only): $cmd"
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
    dir="$*"
    for file in `cd "$dir" && ls -a | grep -v ^.git$ | grep -v ^.gitignore$ | grep -v ^.gitkeep$ | egrep '^\.[^.]+'`; do
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
    src=$1
    lnk=$2
    need_backup=0
    log " make_link_bkupable Start lnk=$lnk src=$src"
    #if [ -e "${lnk}" ]; then
    if isexist "${lnk}"; then
        # log "   @@@@@@ exist!"
        # ファイルタイプ(ファイル、ディレクトリ、リンク)をチェック
        #if [ -n "`find "${lnk}" -maxdepth 0 -type l`" ]; then
        if [ -L "${lnk}" ]; then
            # リンク
            # log "   @@@@@@ Link!"
            fullpath_lnk="`readlink_path "${lnk}"`"
            fullpath_src="`readlink_path "${src}"`"
            # log "    lnk:$lnk => fullpath_lnk=$fullpath_lnk"
            # log "    src:$src => fullpath_src=$fullpath_src"
            if ! issamelink "$fullpath_lnk" "$fullpath_src"; then
                # 既に自分へのリンクの場合はなにもしない
                log "  => Already linked. Skip it. path=${lnk}"
                return
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
            return
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
    bkuptarget="$*"
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
    rmtarget="$*"
    if [ "$rmtarget" = "/" ]; then
        log "invalid rm path $rmtarget"
        return
    fi
    if isexist "$rmtarget"; then
        dvexec "rm -rf \"$rmtarget\""
    fi
}

# OS 種類取得
OS=`get_os_distribution`
# Install command
instcmd="sudo apt-get install -y"
if [ "$OS" = "mac" ]; then
     instcmd="brew install"
elif [ "$OS" = "redhat" ]; then
     instcmd="sudo yum install -y"
elif [ "$OSTYPE" = "cygwin" ]; then
     instcmd="apt-cyg install"
fi

start() {
    # -e: Exit when error occur.
    # -u: Exit when using undefined variable.
    set -eu

    # スクリプトが置かれているパスに移動する
    cd $DIR_ROOT

    # Mac 用 Brew インストールチェック
    if [ "$OS" = "mac" ]; then
        if ! testcmd brew; then
            log ' HomeBrew is Not Installed!'
            log '  => Execute this and Install it!'
            log ''
            log '  echo '\''export PATH=/usr/local/bin:$PATH'\'' >> ~/.bash_profile'
            log '  sudo mkdir /usr/local/'
            log '  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"'
            log '  source ~/.bash_profile'
            log '  brew update'
            log '  brew -v'
            log ''
            exit 1
        fi
    fi

    log "###########################################"
    log "            App Setting Start"
    log "###########################################"
    # app ディレクトリ配下のディレクトリに対して、インストール処理を実行
    # mac/linux にかかわらず、実行される
    apps=`ls -1 $DIR_APP |grep -v '^_' |grep -v git`
    apps="git $apps"
    for dir in $apps; do

        # _ から始まらないディレクトリに対して実行

        if [ ! -d $DIR_APP/$dir ]; then
            # ディレクトリ以外は無視
            continue
        fi

        # ディレクトリ名＝アプリ名の前提
        app=$dir

        if [ ! "$INSTAPP" = "" ] && [ ! "$INSTAPP" = "$dir" ]; then
            # アプリ指定の場合、指定アプリ以外は無視
            continue
        fi

        # デフォルト関数ロード
        # 下記 vexec source $instshell にて、install, setconfig メソッドが
        # 上書き定義される為、ここで初期化する
        initialize_funcs

        log "---------------------------------------------- path=$DIR_APP/$dir"
        log "    $app"
        log "----------------------------------------------"
        whith_install=0
        if ! testcmd $app; then
            log "    => Not Installed..."
            whith_install=1
        fi

        # デフォルトのインストールコマンド
        def_instcmd="$instcmd $app"
        instshell=$DIR_APP/$dir/$FIL_CONF
        if [ -e "$instshell" ]; then
            # 個別インストール設定ファイルが存在する場合は、それを実行
            # shell を読み込み、install, setconfigメソッドをロード
            source $instshell

            # 各スクリプト内で以下コマンドでパスを取得できていたが、、、
            # ここで定義しておけば良いことに気づいたので設定しておく
            # # source されるスクリプトを考慮した ファイルの存在するディレクトリ
            # script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE}}")"; pwd)"
            script_dir=$DIR_APP/$dir

            if [ "$whith_install" = "1" ] || [ "$TEST_INSCMD" = "1" ]; then
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
                log " Execute Default install command"
                dvexec $def_instcmd
            fi
        fi
    done

    # os ディレクトリ配下のディレクトリに対して、インストール処理を実行
    log "###########################################"
    log "          OS Common Setting Start"
    log "###########################################"
    osconfig=$DIR_ROOT/os/$FIL_CONF
    if [ "$EXE_OSCONF" = "1" ] && [ -e "$osconfig" ]; then
        if [ "$INSTAPP" = "" ] || [ "$INSTAPP" = "os" ]; then
            source $osconfig
            script_dir=$DIR_ROOT/os
            # 読み込んだ OS共通 setconfig コマンドの実行
            log "---------------------------------------------- path=$osconfig"
            log "    os"
            log "----------------------------------------------"
            setconfig
        fi
    fi

    log "###########################################"
    log "      OS Characteristic Setting Start"
    log "###########################################"
    osdir=$DIR_ROOT/os/linux
    if [ "$OS" = "mac" ]; then
        osdir=$DIR_ROOT/os/mac
    fi
    for file in `find $osdir -name $FIL_CONF |sort`; do
        # ディレクトリ名＝ターゲット名の前提
        script_dir="$(dirname $file)"
        target="$(basename $script_dir)"
        if [ ! "$INSTAPP" = "" ] && [ ! "$INSTAPP" = "$target" ]; then
            # アプリ指定の場合、指定アプリ以外は無視
            continue
        fi
        # 変数初期化
        instshell=$file
        # デフォルトのインストールコマンド
        def_instcmd="$instcmd $target"
        # デフォルト関数ロード
        initialize_funcs
        whith_install=0
        # 設定ファイル読み込み
        source $file
        if [ "$osdir/$FIL_CONF" = "$file" ]; then
            # OS 設定 の場合
            if [ ! "$EXE_OSCONF" = "1" ]; then
                # EXE_OSCONF=1 以外は無視
                continue
            fi
        else
            # アプリ設定の場合
            if ! testcmd $target; then
                log "    => Not Installed..."
                whith_install=1
            fi
        fi

        # OS設定、App設定共に、 setconfig コマンドの実行
        log "---------------------------------------------- path=$file"
        log "    $target"
        log "----------------------------------------------"
        if [ "$whith_install" = "1" ] || [ "$TEST_INSCMD" = "1" ]; then
            install
        fi
        setconfig
    done

    if [ "$DRYRUN" = "1" ]; then
        log ""
        log ""
        log "================================================"
        log " Below commands will be execute."
        logescape $DRYRUNCMD
        log "================================================"
        log "   ===> This is Dry-run mode."
        log "   ===>   Specify 'exec' option for execute."
        log "================================================"
        log ""
        log ""
    else
        if [ ! "$BACKUP" = "" ]; then
            log "================================================"
            log " Below files is backuped."
            logescape $BACKUP
        fi
    fi
}

start
