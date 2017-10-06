#!/bin/bash

install() {
    # 通常のインストールを実行
    dvexec $def_instcmd
    if is_ubuntu; then
        # for .zplug
        dvexec $instcmd gawk
    fi
    if is_mac; then
        # GNU系コマンド集のインストール（gdircolors 用）
        dvexec $instcmd coreutils
    fi
}

setconfig() {
    # .works.zsh
    [ ! -e ~/.works.zsh ] && dvexec touch ~/.works.zsh && dvexec chmod 755 ~/.works.zsh

    # ZPlug
    local zplug_home=~/.zplug
    if [ ! -d $zplug_home ] && [ ! -L $zplug_home ]; then
        dvexec git clone https://github.com/zplug/zplug $zplug_home
    fi

    # LS_COLORS 設定
    # http://qiita.com/yuyuchu3333/items/84fa4e051c3325098be3
    # https://github.com/seebi/dircolors-solarized
    # ソースコード取得
    workdir=$app_dir/tmp
    if [ ! -e $workdir ]; then
        dvexec mkdir -p $workdir
    fi
    if [ ! -e "$workdir/dircolors-solarized" ]; then
        dvexec cd $workdir
        dvexec git clone https://github.com/seebi/dircolors-solarized.git
    fi
    local setcolortheme
    # setcolortheme=dircolors.256dark
    setcolortheme=dircolors.ansi-dark
    # setcolortheme=dircolors.ansi-light
    # setcolortheme=dircolors.ansi-universal
    if [ -e "${workdir}/dircolors-solarized/${setcolortheme}" ]; then
        make_link_bkupable "${workdir}/dircolors-solarized/${setcolortheme}" "${HOME}/.dircolors"
    fi

    if [ ! -e "$workdir/tomorrow-theme" ]; then
        dvexec cd $workdir
        dvexec git clone https://github.com/chriskempson/tomorrow-theme.git
        dvexec ./tomorrow-theme/Gnome-Terminal/setup-theme.sh
    fi

    if is_mac && [ ! -e "$workdir/solarized.git" ]; then
        dvexec cd $workdir
        dvexec git clone https://github.com/tomislav/osx-terminal.app-colors-solarized solarized.git
    fi
    if is_msys && [ ! -e "$workdir/mintty-colors-solarized" ]; then
        dvexec cd $workdir
        dvexec git clone https://github.com/mavnn/mintty-colors-solarized.git
    fi

    # その他ドットファイルリンク作成
    make_link_dot2home $app_dir
    if is_msys; then
        # その他ドットファイルリンク作成
        make_link_dot2home $app_dir/win
    fi
}

gen_zshrc_for_msys2() {
    # gen_zshrc_for_msys2 \
    #     .zsh/00.base.zsh \
    #     .zsh/10.path.zsh \
    #     .zsh/20.alias.zsh \
    #     .zsh/30.funcs.zsh \
    #     .zsh/50.ssh-agent.zsh \
    #     .zsh/60.tmux.zsh
    local outfile=~/.zshrc
    if [[ -e $outfile ]]; then
        bkup_orig_file $outfile
    fi
    for file in "$@"; do
        dvexec "cat $app_dir/$file >> $outfile"
    done
    dvexec "echo '[ -f ~/.works.zsh ] && source ~/.works.zsh' >> $outfile"
}
