#!/bin/bash

# echo するのみ
log() {
    echo "$*"
}
dlog() {
    [[ $debug -eq 1 ]] && log "$*"
    :
}
logescape() {
    echo -e "$*"
}

# コマンド実行
# log メソッドを呼びつつ実行する
vexec() {
    cmd="$*"
    dlog "===> Executing: $cmd"
    eval $cmd
    if [ $? -eq 0 ]; then
        dlog "    => Command Sucessfully."
    else
        dlog "    => Command Failed......"
    fi
}

# コマンドダミー実行
# echoするのみ
dry_vexec() {
    cmd="$*"
    dlog " Dummy Exec: $cmd"
}

# コマンドがインストールされているかチェックする
test_cmd() {
    which "$1" >/dev/null 2>&1
    return $?
}

# $* が存在するかどうか判定する
isexist() {
    local file="$*"
    local count=`ls -a "$file" 2>/dev/null |wc -l|sed 's/ //g'`
    if [ "$count" == "0" ]; then
        # 存在しない場合は bash 内で false の意味を表す 1 を応答する.
        return 1
    fi
    # 存在する場合は bash 内で true の意味を表す 0 を応答する.
    return 0
}

# $1のファイルを$2へリンクを作成する
make_link() {
    local from=$1
    local to=$2
    dvexec "ln -s \"$from\" \"$to\""
}

# Dry run 実行用の関数定義
dvexec() {
    local cmd="$*"
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
    local target="$*"
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
    local src1=$1
    local src2=$2
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
    dlog " make_link_bkupable Start lnk=$lnk src=$src"
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
                dlog "  => Already linked. Skip it. path=${lnk}"
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
    BACKUP="${BACKUP}\nbackup to ${DIR_BACKUP}/`basename "$bkuptarget"`"
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
    DETECT_OS=`$DIR_ROOT/bin/dist_ditect`
    # 32bit判定
    DETECT_BIT=`$DIR_ROOT/bin/os_bit`
    is_32bit=0
    if [[ "$DETECT_BIT" != "x86_64" ]]; then
        is_32bit=1
    fi
    # Install command
    instcmd="sudo apt-get install -y"
    if [ "$DETECT_OS" = "mac" ]; then
        instcmd="brew install"
    elif [ "$DETECT_OS" = "redhat" ]; then
        instcmd="sudo yum install -y"
    elif [ "$DETECT_OS" = "cygwin" ]; then
        instcmd="apt-cyg install"
    elif [ "$DETECT_OS" = "msys" ]; then
        instcmd="pacman -S --noconfirm"
    fi
}

initialize() {
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

initialize_mac() {
    if ! test_cmd brew; then
        log '================================================'
        log ' HomeBrew is Not Installed!'
        log '  => Execute this and Install it!'
        log ''
        log '  echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile'
        log '  sudo mkdir /usr/local/'
        log '  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"'
        log '  source ~/.bash_profile'
        log '  brew update'
        log '  brew -v'
        log ''
        exit 1
    fi
}

initialize_msys2() {
    if [ -z $WINHOME ]; then
        WINHOME="$(cd /c/Users/`whoami` && pwd)"
    fi
    [ ! -e $WINHOME/bin ] && mkdir $WINHOME/bin
    [ ! -e $WINHOME/tools ] && mkdir $WINHOME/tools
    [ ! -e $WINHOME/works ] && mkdir $WINHOME/works
    local msys64=$WINHOME/AppData/Local/msys64
    local msys64ag=$msys64/mingw64/bin/ag.exe
    [ -e $msys64ag ] && return
    if [ ! -e $msys64 ]; then
        local tmp=${DIR_ROOT}/tmp
        if [ ! -e "${tmp}" ]; then
            dvexec "mkdir -p \"${tmp}\""
        fi
        dvexec cd $tmp
        local target=msys2-x86_64-latest.tar.xz
        if [ ! -e $target ]; then
            dvexec curl -fsSLO http://repo.msys2.org/distrib/$target
        fi
        if [ ! -e $tmp/msys64 ]; then
            dvexec tar Jxfv msys2-x86_64-latest.tar.xz
        fi
        if [ ! -e $msys64 ]; then
            dvexec mv msys64 $msys64
        fi
        dvexec cd -
    fi
    echo "Start setup_msys2.bat"
    exit 0
}

# セットアップ開始
setup() {
    initialize

    # スクリプトが置かれているパスに移動する
    cd $DIR_ROOT

    # Mac 用 Brew インストールチェック
    if [ "$DETECT_OS" = "mac" ]; then
        initialize_mac
    elif [ "$DETECT_OS" = "msys" ]; then
        initialize_msys2
    fi

    # -e: Exit when error occur.
    # -u: Exit when using undefined variable.
    set -eu

    # app ディレクトリ配下のディレクトリに対して、インストール処理を実行
    # mac/linux にかかわらず、実行される
    for ((i = 0; i < ${#target_apps[@]}; i++)) {
        # ディレクトリ名＝アプリ名の前提
        local app=${target_apps[i]}

        dlog "================================================"
        log "===> $app"

        # 各スクリプト内で以下コマンドでパスを取得できていたが、、、
        # ここで定義しておけば良いことに気づいたので設定しておく
        # # source されるスクリプトを考慮した ファイルの存在するディレクトリ
        # script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE}}")"; pwd)"
        script_dir="$DIR_APP/$app"

        # デフォルトのインストールコマンド設定
        def_instcmd="$instcmd $app"
        # デフォルト関数ロード
        # 下記 vexec source $script_path にて、install, setconfig メソッドが
        # 上書き定義される為、ここで初期化する
        source $DIR_ROOT/setup/default_config.sh

        # 個別インストール設定ファイルが存在する場合は、それを実行する為
        # config.sh ファイルを読み込み、install, setconfigメソッドをロード
        local script_path=$DIR_APP/$app/$FIL_CONF
        [[ -e "$script_path" ]] && source "$script_path"

        if [[ $force -eq 1 ]] || ! test_cmd $app; then
            # 強制インストールまたは、インストールされていない場合は実行
            # 読み込んだ install コマンドの実行
            install
        fi
        if test_cmd $app; then
            # install された、されている場合
            # 読み込んだ setconfig コマンドの実行
            setconfig
        fi
    }

    if [[ $dry_run -eq 1 ]]; then
        log ""
        log ""
        log "===================================================="
        log "==>  This is Dry-run mode."
        log "==>     Specify 'exec/--exec/-e' option for execute."
        if [[ ! -z $dry_run_commoands ]]; then
            log "==>     Below commands will be execute."
            logescape $dry_run_commoands
        fi
        log "===================================================="
    else
        logescape $dry_run_commoands
        if [[ ! "$BACKUP" == "" ]]; then
            log "======================================>"
            log " Below files is backuped."
            logescape $BACKUP
        fi
    fi
}
