#!/bin/bash

install() {
    # 通常のインストールを実行
    dvexec $def_instcmd
    if [ "$OS" = "mac" ]; then
        # GNU系コマンド集のインストール（gdircolors 用）
        dvexec "$instcmd coreutils"
    fi
}

setconfig() {
    # LS_COLORS 設定
    # http://qiita.com/yuyuchu3333/items/84fa4e051c3325098be3
    # https://github.com/seebi/dircolors-solarized
    # ソースコード取得
    workdir="$script_dir/tmp"
    if [ ! -e $workdir ]; then
        dvexec "mkdir -p \"$workdir\""
    fi
    if [ ! -e "$workdir/dircolors-solarized" ]; then
        dvexec "cd \"$workdir\""
        dvexec git clone https://github.com/seebi/dircolors-solarized.git
    fi
    if [ "$OS" = "mac" ] && [ ! -e "$workdir/solarized.git" ]; then
        dvexec "cd \"$workdir\""
        dvexec git clone https://github.com/tomislav/osx-terminal.app-colors-solarized solarized.git
    fi
    # setcolortheme=dircolors.256dark
    setcolortheme=dircolors.ansi-dark
    # setcolortheme=dircolors.ansi-light
    # setcolortheme=dircolors.ansi-universal
    make_link_bkupable "${workdir}/dircolors-solarized/${setcolortheme}" "${HOME}/.dircolors"

    # その他ドットファイルリンク作成
    make_link_dot2home $script_dir
}
