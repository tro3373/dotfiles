"######################################################################
"   plug.vim
"           プラグイン設定ファイル
"           vim-plug を使用してプラグインを管理する
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
  " vim-plug
  Plug 'junegunn/vim-plug',
        \ {'dir': '~/.vim/plugged/vim-plug/autoload'}
  " カラースキーム
  Plug 'altercation/vim-colors-solarized'           " Solarized
  Plug 'chriskempson/vim-tomorrow-theme'            " tomorrow

  "" airline
  Plug 'bling/vim-airline'
  "" Powerline
  " Plug 'powerline/powerline', {
  "   \ 'rtp': 'powerline/bindings/vim/'}

  Plug 'sudo.vim'                                   " sudo
  Plug 'banyan/recognize_charcode.vim'              " 文字コード判定
  Plug 'kana/vim-submode'                           " vim-submode(キーマップ plugin)
  Plug 'nathanaelkane/vim-indent-guides'            " indent guide

  Plug 'kana/vim-smartchr'                          " = 等の便利入力
  Plug 'kana/vim-smartinput'                        " () 等の入力補完
  Plug 'cohama/vim-smartinput-endwise'              " vim-endwise (ruby 用 end 補完)
  Plug 'tyru/caw.vim'                               " コメントアウトプラグイン <Leader>+c
  " Plug 'Shougo/neocomplcache.vim'                   " 補完候補を自動でポップアップ(old)
  Plug 'Shougo/neocomplete.vim'                     " Next generation completion framework after neocomplcache
  " Plug 'Lokaltog/vim-easymotion'                    " カーソル移動プラグイン(fコマンドが効かなくなるので無効)

  Plug 'airblade/vim-gitgutter'                     " Shows a git diff in the gutter!!!!!
  Plug 'cohama/agit.vim'                            " gitk-like repository viewer ex) type :Agit

  Plug 'Shougo/neosnippet'                          " Ctrl+k でスニペットを用意
  Plug 'Shougo/neosnippet-snippets'                 " 基本スニペット for neosnippet
  Plug 'honza/vim-snippets'                         " snipMate UltiSnip Snippets
  " Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
  Plug 'vim-scripts/Align'                          " CSV,TSV整形
  Plug 'taglist.vim'                                " ソースコードブラウザ

  Plug 'scrooloose/nerdtree', {
    \ 'on':  ['NERDTreeToggle'] }                   " NERDTree tree view コマンド実行時に読み込む

  Plug 'vim-scripts/gtags.vim'                      " GNU Global
  Plug 'rking/ag.vim'                               " SilverSearcher
  Plug 'junegunn/fzf', { 'dir': '~/.fzf',
    \ 'do': './install --all' }                     " FZF
  Plug 'junegunn/fzf.vim'

  " Unite関連
  Plug 'Shougo/unite.vim'                           " ユーザインタフェース統合
  Plug 'Shougo/neomru.vim'                          " 最近使用したファイルの一覧管理
  Plug 'ujihisa/unite-colorscheme'                  " カラースキーム変更
  Plug 'Shougo/vimproc.vim', { 'do': 'make' }
  " Plug 'Shougo/vimproc.vim', {
  "   \ 'build' : {
  "   \     'windows' : 'tools\\update-dll-mingw',
  "   \     'cygwin' : 'make -f make_cygwin.mak',
  "   \     'mac' : 'make',
  "   \     'linux' : 'make',
  "   \     'unix' : 'gmake',
  "   \    },
  "   \ }



  " TODO 勉強中 =======
  Plug 'tpope/vim-surround'                         " 囲文字入力アシスト
  Plug 'Shougo/unite-ssh'                           "
  " Plug 'Shougo/vimshell'                            " uniteインターフェースでシェル使用できる
  " http://qiita.com/kinef/items/ddbccdacaf9507d9dd24
  " Plug 'sjl/gundo.vim'                              " UNDO履歴を管理
  " Plug 'fuenor/qfixhowm'                            " メモプラグイン
  " Plug 'h1mesuke/unite-outline'                     " 関数一覧とかを表示
  " Plug 'thinca/vim-quickrun'                        " 現在のファイルを実行して quickfix に表示
  " Plug 'tpope/vim-fugitive'                         " Git wrapper so awesome
  " Plug 'junegunn/seoul256.vim'
  " 指定したファイルタイプを開いたときに読み込む
  " Plug 'tpope/vim-fireplace', { 'for': ['clojure'] }
  " TODO 勉強中 =======

call plug#end()

" VimPlug plugin install 判定関数
let g:plug = {
    \ "plugs": get(g:, 'plugs', {})
    \ }
function! g:plug.is_installed(name)
    return has_key(self.plugs, a:name) ? isdirectory(self.plugs[a:name].dir) : 0
endfunction

