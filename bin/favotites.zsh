#!/bin/zsh

#######################################################################
# 良く使うコマンドの有無をチェックする                                #
# 未インストールの場合は通知する                                      #
#######################################################################

# チェックしたいコマンドをここにスペース区切りで書く
CMD="vim git tig tmux tree curl ag ctags gtags peco subl apm"

# スペース区切りの文字列を配列化
ARRAY=${(z)CMD}

# 各要素毎に処理
for cmd in ${ARRAY}; do
    # インストールされていなかったら通知
    if [ -n "`which "${cmd}" | grep 'not found'`" ]; then
        echo "[!] '${cmd}' is not installed"
    fi
done

