#!/bin/bash

setconfig() {
    if ! test -d "${HOME}/.anyenv"; then
        dvexec git clone https://github.com/riywo/anyenv ~/.anyenv
    fi
    log "==================================================================="
    log "  see anyenv setting..."
    log "    http://qiita.com/luckypool/items/f1e756e9d3e9786ad9ea"
    log "    https://github.com/riywo/anyenv"
    log "  see powerline setting..."
    log "    http://qiita.com/qurage/items/4edda8559cc4c98758ee"
    log "==================================================================="
    if ! test -d ${HOME}/.anyenv/envs/pyenv; then
        dvexec "export PATH=\"$HOME/.anyenv/bin:$PATH\""
        eval "$(anyenv init -)"
        dvexec anyenv install pyenv
        dvexec "export PATH=\"$HOME/.anyenv/envs/pyenv/bin:$PATH\""
        eval "$(pyenv init -)"
        if [ "$OS" = "mac" ]; then
            if ! testcmd xcode-select; then
                dvexec "xcode-select --install"
            fi
            dvexec "brew install readline; brew link readline;"
        elif [ "$OS" = "ubuntu" ]; then
            dvexec sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev
        fi
        cmd_pyenv=~/.anyenv/envs/pyenv/shims/pyenv
        cmd_pip=~/.anyenv/envs/pyenv/shims/pip
        dvexec pyenv install 2.7.10
        dvexec pyenv global 2.7.10
        dvexec $cmd_pip install --user git+git://github.com/powerline/powerline
        dvexec mkdir -p ~/.config/powerline
        dvexec cp -R ~/.local/lib/python2.7/site-packages/powerline/config_files/* ~/.config/powerline/
        dvexec ln -sf $script_dir/default.json ~/.config/powerline/themes/tmux/default.json
        dvexec ln -sf $script_dir/powerline.json ~/.config/powerline/themes/powerline.json
    fi
}
