#=====================================================================
#  zplug
#=====================================================================
# http://qiita.com/b4b4r07/items/cd326cd31e01955b788b
# http://blog.b4b4r07.com/entry/2015/12/13/174209
#
#  as: コマンドかプラグインかを指定する
#  of: source するファイルへの相対パスかパスを通すコマンドへの相対パスを指定する（glob パターンでも可）
#  from: 外部からの取得を行う
#  at: ブランチ/タグを指定したインストールをサポートする
#  file: リネームしたい名前（コマンド時に有用）
#  dir: インストール先のディレクトリパス
#  if: 真のときダウンロードしたコマンド/プラグインを有効化する
#  do: インストール後に実行するコマンド
#  frozen: 直接指定しないかぎりアップデートを禁止する
#  commit: コミットを指定してインストールする ($ZPLUG_SHALLOW が真かどうかに関わらず)
#  on: 依存関係
#  nice: 優先度（高 -20 〜 19 低）の設定をする。優先度の高いものから読み込む。10 以上を設定すると compinit のあとにロードされる
#
if [ -d ~/.zplug ] || [ -L ~/.zplug ]; then
    source ~/.zplug/zplug
    # Local loading
    zplug "~/.zsh",     from:local, nice:2

    # Remote loading
    zplug "b4b4r07/zplug"
    zplug "b4b4r07/zsh-gomi",   as:command, of:bin/gomi
    zplug "b4b4r07/http_code",  as:command, of:bin
    zplug "b4b4r07/enhancd",    of:enhancd.sh
    zplug "stedolan/jq", from:gh-r, as:command \
            | zplug "b4b4r07/emoji-cli", if:"which jq"
    zplug "mrowa44/emojify",    as:command
    zplug "zsh-users/zsh-completions"
    zplug "zsh-users/zsh-history-substring-search"
    zplug "zsh-users/zsh-syntax-highlighting", nice:19
    zplug "mollifier/cd-gitroot"
    zplug "junegunn/fzf-bin", as:command, from:gh-r, file:fzf
    zplug "junegunn/fzf", as:command, of:bin/fzf-tmux

    zplug "peco/peco", as:command, from:gh-r, of:"*amd64*"
    zplug "b4b4r07/dotfiles", as:command, of:bin/peco-tmux

    # check コマンドで未インストール項目があるかどうか verbose にチェックし
    # false のとき（つまり未インストール項目がある）y/N プロンプトで
    # インストールする
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi
    # プラグインを読み込み、コマンドにパスを通す
    zplug load --verbose
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

