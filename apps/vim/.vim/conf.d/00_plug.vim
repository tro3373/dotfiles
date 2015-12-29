"######################################################################
"   plug.vim
"           プラグイン設定ファイル
"           を使用してプラグインを管理する
"           @see https://github.com/junegunn/vim-plug
"######################################################################

if has('vim_starting')
  set rtp+=~/.vim/plugged/vim-plug
  if !isdirectory(expand('~/.vim/plugged/vim-plug'))
    echo 'install vim-plug...'
    call system('mkdir -p ~/.vim/plugged/vim-plug')
    call system('git clone https://github.com/junegunn/vim-plug.git ~/.vim/plugged/vim-plug/autoload')
  end

endif

call plug#begin('~/.vim/plugged')
  Plug 'banyan/recognize_charcode.vim'       " 文字コード判定
  Plug 'vim-scripts/gtags.vim'               " GNU Global
  Plug 'Align'                               " テキスト整形
  Plug 'taglist.vim'                         " ソースコードブラウザ
  Plug 'sudo.vim'                            " sudo
  Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle'] } " NERDTree tree view コマンド実行時に読み込む
  Plug 'nathanaelkane/vim-indent-guides'     " indent guide
  Plug 'kana/vim-submode'                    " vim-submode(キーマップ plugin)
  Plug 'airblade/vim-gitgutter'              " Shows a git diff in the gutter!!!!!
  Plug 'Shougo/neocomplete.vim'              " Next generation completion framework after neocomplcache

  Plug 'rking/ag.vim'                        " SilverSearcher
  " Plugin outside ~/.vim/plugged with post-update hook
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

  " Unite関連
  Plug 'Shougo/unite.vim'                    " ユーザインタフェース統合
  Plug 'Shougo/neomru.vim'                   " 最近使用したファイルの一覧管理
  Plug 'ujihisa/unite-colorscheme'           " カラースキーム変更
  Plug 'Shougo/vimproc.vim', { 'do': 'make' }
  " Plug 'Shougo/vimproc.vim', {
  "             \ 'build' : {
  "             \     'windows' : 'tools\\update-dll-mingw',
  "             \     'cygwin' : 'make -f make_cygwin.mak',
  "             \     'mac' : 'make',
  "             \     'linux' : 'make',
  "             \     'unix' : 'gmake',
  "             \    },
  "             \ }

  " カラースキーム
  Plug 'altercation/vim-colors-solarized'    " Solarized
  " Plug 'tomasr/molokai'                      " molokai
  " Plug 'w0ng/vim-hybrid'                     " hybrid
  Plug 'chriskempson/vim-tomorrow-theme'     " tomorrow

  "" Powerline
  " ==> Older Powerline source.
  " Plug 'alpaca-tc/alpaca_powertabline'
  " Plug 'Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}
  " Plug 'Lokaltog/powerline-fontpatcher'
  " ==> The Newer powerline source.
  " Plug 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}

  "" airline
  Plug 'bling/vim-airline'

  " TODO 勉強中 =======
  " http://qiita.com/kinef/items/ddbccdacaf9507d9dd24
  Plug 'Shougo/neocomplcache'                " 補完候補を自動でポップアップ
  " Plug 'Shougo/vimshell'                     " uniteインターフェースでシェル使用できる
  " Plug 'gitv'                                " gitのログをキレイにツリー形式表示
  " Plug 'sjl/gundo.vim'                       " UNDO履歴を管理
  " Plug 'fuenor/qfixhowm'                     " メモプラグイン
  " Plug 'h1mesuke/unite-outline'              " 関数一覧とかを表示
  Plug 'Lokaltog/vim-easymotion'             " カーソル移動プラグイン
  " Plug 'vim-scripts/Align'                   " CSV,TSV整形
  " Plug 'Shougo/unite-ssh'
  " Plug 'thinca/vim-quickrun'                 " 現在のファイルを実行して quickfix に表示
  " Plug 'Shougo/neosnippet'                   " Ctrl+k でスニペットを用意
  Plug 'tpope/vim-fugitive'                  " Git wrapper so awesome
  " Plug 'junegunn/seoul256.vim'
  " 指定したファイルタイプを開いたときに読み込む
  " Plug 'tpope/vim-fireplace', { 'for': ['clojure'] }
  " X | Y の時, X をインストールした後に Y をインストール
  " Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
  " TODO 勉強中 =======

call plug#end()

" For fzf plugin.
" set rtp+=~/.fzf

