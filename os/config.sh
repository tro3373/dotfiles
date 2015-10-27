#!/bin/bash

setconfig() {
    if ! test -d "${HOME}/.anyenv"; then
        dvexec "git clone https://github.com/riywo/anyenv ~/.anyenv"
    fi
    log "  see anyenv setting..."
    log "    http://qiita.com/luckypool/items/f1e756e9d3e9786ad9ea"
    log "    https://github.com/riywo/anyenv"
    log "  see powerline setting..."
    log "    http://qiita.com/qurage/items/4edda8559cc4c98758ee"
    if ! test -d "${HOME}/.anyenv/envs/pyenv"; then
        dvexec "export PATH=\"$HOME/.anyenv/bin:$PATH\""
        eval "$(anyenv init -)"
        dvexec "anyenv install pyenv"
        dvexec "export PATH=\"$HOME/.anyenv/envs/pyenv/bin:$PATH\""
        eval "$(pyenv init -)"
        if [ "$OS" = "mac" ]; then
            dvexec "xcode-select --install"
            dvexec "brew install readline; brew link readline;"
        elif [ "$OS" = "ubuntu" ]; then
            dvexec "sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev"
        fi
        dvexec "pyenv install 2.7.10"
        dvexec "pyenv global 2.7.10"
        dvexec "pip install --user git+git://github.com/powerline/powerline"
        dvexec "mkdir -p ~/.config/powerline"
        dvexec "cp -R ~/.local/lib/python2.7/site-packages/powerline/config_files/* ~/.config/powerline/"
        dvexec "cd \"$script_dir\""
        dvexec "cp -f ./default.json ~/.config/powerline/themes/tmux/default.json"
        dvexec "cp -f ./powerline.json ~/.config/powerline/themes/powerline.json"
    fi
}
