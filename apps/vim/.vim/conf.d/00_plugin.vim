"######################################################################
"   plugin.vim
"           プラグイン設定ファイル
"           NeoBundleを使用してプラグインを管理する
"           @see https://github.com/Shougo/neobundle.vim
"######################################################################

" NeoBundleを使用するためのスニペット
set nocompatible
filetype off
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#begin(expand('~/.vim/bundle/'))
  NeoBundleFetch 'Shougo/neobundle.vim'

  " インストールしたいプラグインのリストを書く
  "   - GitHUBの場合は {ユーザ名}/{リポジトリ名}
  "   - その他のgitリポジトリの場合はフルパスで
  "   - SVN, Marcural も使える
  "
  " ここから #############################################################

  " 一般プラグイン
  NeoBundle 'banyan/recognize_charcode.vim'       " 文字コード判定
  NeoBundle 'vim-scripts/gtags.vim'               " GNU Global
  NeoBundle 'Align'                               " テキスト整形
  NeoBundle 'taglist.vim'                         " ソースコードブラウザ
  NeoBundle 'rking/ag.vim'                        " SilverSearcher
  NeoBundle 'sudo.vim'                            " sudo
  NeoBundle 'scrooloose/nerdtree'                 " NERDTree tree view
  NeoBundle 'nathanaelkane/vim-indent-guides'     " indent guide

  " TODO 勉強中 =======
  " http://qiita.com/kinef/items/ddbccdacaf9507d9dd24
  NeoBundle 'Shougo/neocomplcache'                " 補完候補を自動でポップアップ
  " NeoBundle 'Shougo/vimshell'                     " uniteインターフェースでシェル使用できる
  " NeoBundle 'gitv'                                " gitのログをキレイにツリー形式表示
  " NeoBundle 'sjl/gundo.vim'                       " UNDO履歴を管理
  " NeoBundle 'fuenor/qfixhowm'                     " メモプラグイン
  " NeoBundle 'h1mesuke/unite-outline'              " 関数一覧とかを表示
  NeoBundle 'Lokaltog/vim-easymotion'             " カーソル移動プラグイン
  " NeoBundle 'vim-scripts/Align'                   " CSV,TSV整形
  " NeoBundle 'Shougo/unite-ssh'
  " NeoBundle 'thinca/vim-quickrun'                 " 現在のファイルを実行して quickfix に表示
  " NeoBundle 'Shougo/neosnippet'                   " Ctrl+k でスニペットを用意
  " TODO 勉強中 =======

  " Unite関連
  NeoBundle 'Shougo/unite.vim'                    " ユーザインタフェース統合
  NeoBundle 'Shougo/neomru.vim'                   " 最近使用したファイルの一覧管理
  NeoBundle 'ujihisa/unite-colorscheme'           " カラースキーム変更
  NeoBundle 'Shougo/vimproc.vim', {
              \ 'build' : {
              \     'windows' : 'tools\\update-dll-mingw',
              \     'cygwin' : 'make -f make_cygwin.mak',
              \     'mac' : 'make',
              \     'linux' : 'make',
              \     'unix' : 'gmake',
              \    },
              \ }

  " vim-submode
  NeoBundle 'kana/vim-submode'                    " keymap

  " カラースキーム
  NeoBundle 'altercation/vim-colors-solarized'    " Solarized
  NeoBundle 'tomasr/molokai'                      " molokai
  NeoBundle 'w0ng/vim-hybrid'                     " hybrid
  NeoBundle 'chriskempson/vim-tomorrow-theme'     " tomorrow

  "" powerline
  "NeoBundle 'alpaca-tc/alpaca_powertabline'
  "" NeoBundle 'https://github.com/Lokaltog/powerline.git'
  "NeoBundle 'Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}
  "NeoBundle 'Lokaltog/powerline-fontpatcher'

  " ############################################################# ここまで
  call neobundle#end()
endif

" NeoBundleを使用するためのスニペット
filetype plugin indent on

" For fzf plugin.
set rtp+=~/.fzf

