#=====================================================================
#  zplug
#=====================================================================
# http://qiita.com/b4b4r07/items/cd326cd31e01955b788b
# http://blog.b4b4r07.com/entry/2015/12/13/174209
#
#  as: コマンドかプラグインかを指定する
#  use: source するファイルへの相対パスかパスを通すコマンドへの相対パスを指定する（glob パターンでも可）
#  from: 外部からの取得を行う
#  at: ブランチ/タグを指定したインストールをサポートする
#  rename-to: リネームしたい名前（コマンド時に有用）
#  dir: インストール先のディレクトリパス
#  if: 真のときダウンロードしたコマンド/プラグインを有効化する
#  hook-build: インストール後に実行するコマンド
#  frozen: 直接指定しないかぎりアップデートを禁止する
#  commit: コミットを指定してインストールする ($ZPLUG_SHALLOW が真かどうかに関わらず)
#  on: 依存関係
#  defer: Defers the loading of a package. If the value is 2 or above,  zplug will source the plugin after compinit (0..3)
#
if [ -d ${HOME}/.zplug ] || [ -L ${HOME}/.zplug ]; then
    source ${HOME}/.zplug/init.zsh
    zstyle :zplug:tag depth 10

    # Remote loading
    zplug "zsh-users/zsh-completions"
    local target
    local native_install=1
    case "$OSTYPE" in
        *'linux'*)
            target='*linux*amd64*'
            target_massren=$target
            ;;
        *'darwin'*)
            target='*darwin*amd64*'
            target_massren='*osx*'
            ;;
        *)
            target='os'
            target_massren='*win*'
            native_install=0
            ;;
    esac

    if [[ $native_install -eq 1 ]]; then
        zplug "b4b4r07/enhancd", \
            use:enhancd.sh
        zplug "stedolan/jq", \
            from:gh-r, \
            as:command, \
            rename-to:jq
        zplug "b4b4r07/emoji-cli", \
            on:"stedolan/jq"
        zplug "mrowa44/emojify", \
            as:command
        zplug "mollifier/cd-gitroot"
        zplug "zsh-users/zsh-history-substring-search"
        zplug "zsh-users/zsh-syntax-highlighting", defer:2
        zplug "yoshikaw/ClipboardTextListener", \
            as:command, \
            use:clipboard_text_listener.pl
        zplug "junegunn/fzf-bin", \
            from:gh-r, \
            at:0.13.2, \
            as:command, \
            use:"$target", \
            rename-to:fzf
        # zplug "b4b4r07/easy-oneliner" \
        #     on:"junegunn/fzf"
        zplug "b4b4r07/gomi", \
            as:command, \
            from:gh-r, \
            use:"$target", \
            rename-to:gomi
        zplug "junegunn/fzf", \
            as:command, \
            use:bin/fzf-tmux
        zplug "junegunn/fzf", \
            use:"shell/*.zsh"
        zplug "peco/peco", \
            as:command, \
            from:gh-r, \
            use:"$target"
        zplug "b4b4r07/dotfiles", \
            as:command, \
            use:bin/peco-tmux
        # file name 一括置換
        zplug "laurent22/massren", \
            as:command, \
            from:gh-r, \
            at:v1.3.0, \
            use:"$target_massren", \
            hook-build:"./massren --config editor vim"
    fi

    # Local loading
    # zplug "${HOME}/.zsh", \
    #     from:local, \
    #     ignore:"*vcs-info.zsh", \
    #     nice:2

    # check コマンドで未インストール項目があるかどうか verbose にチェックし
    # false のとき（つまり未インストール項目がある）y/N プロンプトで
    # インストールする
    if ! zplug check; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi
    # プラグインを読み込み、コマンドにパスを通す
    zplug load
fi

