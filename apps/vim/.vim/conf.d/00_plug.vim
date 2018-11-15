"######################################################################
"   plug.vim
"           プラグイン設定ファイル
"           vim-plug を使用してプラグインを管理する
"           @see https://github.com/junegunn/vim-plug
"######################################################################

let g:is_windows = has('win16') || has('win32') || has('win64')
let g:is_cygmsys2 = has('win32unix') " Msys2 is true
let g:is_mac = !g:is_windows && !g:is_cygmsys2
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') &&
      \     system('uname') =~? '^darwin'))
let g:is_linux = !g:is_windows && !g:is_cygmsys2 && !g:is_mac && has('unix')
if g:is_windows
  " Exchange path separator.
  set shellslash
endif

if has('vim_starting')
  set rtp+=$HOME/.vim/plugged/vim-plug
  if !isdirectory(expand('$HOME/.vim/plugged/vim-plug'))
    echo 'install vim-plug...'
    call system('mkdir -p $HOME/.vim/plugged/vim-plug')
    call system('git clone https://github.com/junegunn/vim-plug.git ' . expand('$HOME/.vim/plugged/vim-plug/autoload'))
  end
endif

call plug#begin('$HOME/.vim/plugged')
  " vim-plug
  Plug 'junegunn/vim-plug',
        \ {'dir': '$HOME/.vim/plugged/vim-plug/autoload'}

  " color-scheme
  Plug 'romainl/Apprentice'
  " Plug 'morhetz/gruvbox'
  " Plug 'w0ng/vim-hybrid'
  " Plug 'chriskempson/vim-tomorrow-theme'
  " Plug 'altercation/vim-colors-solarized'
  " Plug 'nanotech/jellybeans.vim'
  " Plug 'AlessandroYorba/Alduin'
  " Plug 'joshdick/onedark.vim'
  " Plug 'AlessandroYorba/Sierra'
  " Plug 'vim-scripts/twilight'
  " Plug 'jeetsukumaran/vim-nefertiti'

  " status-line
  Plug 'itchyny/lightline.vim'
  Plug 'nathanaelkane/vim-indent-guides'                  " indent guide

  " Unite関連
  function! BuildVimproc(info) abort
    " info is a dictionary with 3 fields
    " - name:   name of the plugin
    " - status: 'installed', 'updated', or 'unchanged'
    " - force:  set on PlugInstall! or PlugUpdate!
    if a:info.status == 'installed' || a:info.force
        if g:is_windows
            !make -f make_mingw64.mak
        elseif g:is_cygmsys2
            !make -f make_mingw64.mak
            " !make -f make_cygwin.mak
        elseif g:is_mac
            !make
        elseif g:is_linux
            !make
        else
            !gmake
        endif
    endif
  endfunction
  Plug 'Shougo/vimproc.vim',
      \ { 'do': function('BuildVimproc') }
  " Plug 'Shougo/vimfiler'                                  " :VimFiler
  Plug 'Shougo/unite.vim'                                 " ユーザインタフェース統合
  Plug 'Shougo/neomru.vim'                                " 最近使用したファイルの一覧管理
  Plug 'ujihisa/unite-colorscheme'                        " カラースキーム変更

  " Fuzzy Finder
  Plug 'ctrlpvim/ctrlp.vim'                               " Fuzzy file, buffer, mru, tag, etc finder.
  " if !g:is_windows
  "   Plug 'nixprime/cpsm' , {'do': './install.sh' }        " Plugins for ctrlp.vim A CtrlP matcher, specialized for paths.
  " endif
  " Plug 'mattn/ctrlp-filer'                                " Plugins for ctrlp.vim Filer (After start, Ctrl+D will not work bug occure.)
  Plug 'vim-scripts/ctrlp-funky'                          " Plugins for ctrlp.vim Jump to a function
  Plug 'suy/vim-ctrlp-commandline'                        " Plugins for ctrlp.vim command line history navigation
  Plug 'sgur/ctrlp-extensions.vim'                        " Plugins for ctrlp.vim cmdline : cmdline history,
                                                          " yankring : yank history, menu : extension selector menu
  Plug 'rhysd/accelerated-jk'                             " Accelareted-jk

  Plug 'rking/ag.vim'                                     " SilverSearcher
  if !g:is_windows && !g:is_cygmsys2
      Plug 'junegunn/fzf', { 'dir': '$HOME/.fzf',
        \ 'do': './install --all' }                       " FZF
      Plug 'junegunn/fzf.vim'
  endif


  Plug 'banyan/recognize_charcode.vim'                    " 文字コード判定
  Plug 'kana/vim-submode'                                 " vim-submode(キーマップ plugin)
  Plug 'vim-scripts/sudo.vim'                             " sudo
  Plug 'airblade/vim-gitgutter'                           " Shows a git diff in the gutter!!!!!

  Plug 'Shougo/neosnippet'                                " Ctrl+k でスニペットを用意
  Plug 'Shougo/neosnippet-snippets'                       " 基本スニペット for neosnippet
  Plug 'honza/vim-snippets'                               " snipMate UltiSnip Snippets
  " Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

  " Plug 'Shougo/neocomplcache.vim'                         " 補完候補を自動でポップアップ(old)
  Plug 'Shougo/neocomplete.vim'                           " Next generation completion framework after neocomplcache
  Plug 'terryma/vim-expand-region'                        " visually select increasingly larger regions of text

  Plug 'tyru/caw.vim'                                     " コメントアウトプラグイン <Leader>+c
  Plug 'tpope/vim-surround'                               " 囲文字入力アシスト
  " Plug 'kana/vim-smartchr'                                " = 等の便利入力
  Plug 'kana/vim-smartinput'                              " () 等の入力補完
  Plug 'cohama/vim-smartinput-endwise'                    " vim-endwise (ruby 用 end 補完)
  Plug 'vim-scripts/Align'                                " CSV,TSV整形
  Plug 'junegunn/vim-easy-align'                          " Align text
  Plug 'rhysd/clever-f.vim'                               " f検索
  " Plug 'terryma/vim-multiple-cursors'                     " MultiCursor

  " ソース解析
  Plug 'Shougo/unite-outline'                             " 関数一覧とかを表示
  Plug 'vim-scripts/gtags.vim'                            " GNU Global
  if !g:is_windows
      Plug 'vim-scripts/taglist.vim'                      " ソースコードブラウザ
  endif
  Plug 'scrooloose/syntastic'                             " 構文解析

  " コードフォーマッター
  " Plug 'google/vim-maktaba'                               " GoogleCodeFormatter depends
  " Plug 'google/vim-codefmt'                               " GoogleCodeFormatter
  " Plug 'google/vim-glaive'                                " GoogleCodeFormatter depends

  " Markdown Preview 関連
  Plug 'plasticboy/vim-markdown'
  " Plug 'rcmdnk/vim-markdown'
  " Plug 'kannokanno/previm'
  Plug 'tyru/open-browser.vim'

  if g:is_windows
    " Plug 'mattn/webapi-vim'                               " vim interface to Web API
      Plug 'mattn/excelview-vim'
      Plug 'mattn/startmenu-vim'
  endif

  " Plug 'othree/html5.vim'                                 " For erb tab indent
  " Plug 'vim-scripts/nginx.vim'                            " Nginx Syntax
  " Plug 'mattn/learn-vimscript.git'                        " Learn VimScript (:help learn-vimscript)
  " Plug 'vim-jp/vital.vim'                                 " A comprehensive Vim utility functions for Vim plugins
  " Plug 'mattn/wwwrenderer-vim'                            " www renderer for vim
  " Plug 'Shougo/unite-ssh'                                 "
  " Plug 'Shougo/vimshell'                                  " uniteインターフェースでシェル使用できる
  " Plug 'sjl/gundo.vim'                                    " UNDO履歴を管理 http://qiita.com/kinef/items/ddbccdacaf9507d9dd24
  " Plug 'fuenor/qfixhowm'                                  " メモプラグイン
  Plug 'thinca/vim-quickrun'                              " 現在のファイルを実行して quickfix に表示
  " Plug 'tpope/vim-fugitive'                               " Git wrapper so awesome
  " Plug 'junegunn/seoul256.vim'
  " Plug 'tpope/vim-fireplace', { 'for': ['clojure'] }      " 指定したファイルタイプを開いたときに読み込む
  " migemo
  " ================================== drop
  " Plug 'Lokaltog/vim-easymotion'                          " カーソル移動プラグイン(fコマンドが効かなくなるので無効)
  " Plug 'bling/vim-airline'
  " Plug 'powerline/powerline',
  "     \ {'rtp': 'powerline/bindings/vim/'}
  " Plug 'glidenote/memolist.vim'                           " simple memo plugin for Vim. No use
  " Plug 'cocopon/vaffle.vim'                               " SimpleFiler nouse
  " Plug 'scrooloose/nerdtree', {
  "   \ 'on':  ['NERDTreeToggle'] }                         " NERDTree tree view コマンド実行時に読み込む
  " Plug 'cohama/agit.vim'                                  " gitk-like repository viewer ex) type :Agit
  " Plug 'vim-scripts/gitignore'                            " Vim plugin that add the entries in a .gitignore file to 'wildignore'
call plug#end()

" GoogleCodeFormatter depends
" the glaive#Install() should go after the "call vundle#end()"
" call glaive#Install()
" Optional: Enable codefmt's default mappings on the <Leader>= prefix.
" Glaive codefmt plugin[mappings]
" Glaive codefmt google_java_executable="java -jar /path/to/google-java-format-VERSION-all-deps.jar"

" VimPlug plugin install 判定関数
let g:plug = {
    \ "plugs": get(g:, 'plugs', {})
    \ }
function! g:plug.is_installed(name)
  return has_key(self.plugs, a:name) ? isdirectory(self.plugs[a:name].dir) : 0
endfunction

