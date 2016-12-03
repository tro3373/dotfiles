#!/bin/bash

install() {
    # 通常のインストールを実行
    dvexec $def_instcmd
    if [ "$DETECT_OS" = "mac" ]; then
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
    if [ ! -e "$workdir/tomorrow-theme" ]; then
        dvexec "cd \"$workdir\""
        dvexec git clone https://github.com/chriskempson/tomorrow-theme.git
        dvexec ./tomorrow-theme/Gnome-Terminal/setup-theme.sh
    fi
    if [ "$DETECT_OS" = "mac" ] && [ ! -e "$workdir/solarized.git" ]; then
        dvexec "cd \"$workdir\""
        dvexec git clone https://github.com/tomislav/osx-terminal.app-colors-solarized solarized.git
    fi
    if [ "$DETECT_OS" = "msys" ] && [ ! -e "$workdir/mintty-colors-solarized" ]; then
        dvexec "cd \"$workdir\""
        dvexec git clone https://github.com/mavnn/mintty-colors-solarized.git
    fi
    if [ ! -d ~/.zplug ] && [ ! -L ~/.zplug ]; then
        if [ "$DETECT_OS" = "ubuntu" ]; then
            dvexec "$instcmd gawk"
        fi
        export ZPLUG_HOME=~/.zplug
        dvexec git clone https://github.com/b4b4r07/zplug $ZPLUG_HOME
#        dvexec source ~/.zplug/zplug
#        dvexec zplug update --self
    fi
    local setcolortheme
    # setcolortheme=dircolors.256dark
    setcolortheme=dircolors.ansi-dark
    # setcolortheme=dircolors.ansi-light
    # setcolortheme=dircolors.ansi-universal
    make_link_bkupable "${workdir}/dircolors-solarized/${setcolortheme}" "${HOME}/.dircolors"

    dvexec touch ~/.works.zsh && chmod 755 ~/.works.zsh
    if [[ "$DETECT_OS" == "msys" ]]; then
        # その他ドットファイルリンク作成
        make_link_dot2home $script_dir/win
        make_link_bkupable "${script_dir}/.zshenv" "${HOME}/.zshenv"
        gen_zshrc_for_msys2 \
            .zsh/00.base.zsh \
            .zsh/10.path.zsh \
            .zsh/20.alias.zsh \
            .zsh/30.funcs.zsh \
            .zsh/50.ssh-agent.zsh \
            .zsh/60.tmux.zsh
    else
        # その他ドットファイルリンク作成
        make_link_dot2home $script_dir
    fi
}

gen_zshrc_for_msys2() {
    local outfile=~/.zshrc
    if [[ -e $outfile ]]; then
        bkup_orig_file $outfile
    fi
    for file in "$@"; do
        dvexec "cat $script_dir/$file >> $outfile"
    done
    dvexec "echo '[ -f ~/.works.zsh ] && source ~/.works.zsh' >> $outfile"
}
