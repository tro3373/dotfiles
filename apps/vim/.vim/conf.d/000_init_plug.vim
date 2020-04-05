" " Windows の場合は必要なパスを追加しておく
" if has('win32')
"   let $PATH='c:\dev\vim;c:\msys64\mingw64\bin;c:\msys64\usr\bin;'
"  \ .'c:\Program Files\Java\jdk1.8.0_221\bin;'.$PATH
" endif
let g:is_windows = has('win16') || has('win32') || has('win64')
let g:is_cygmsys2 = has('win32unix') " Msys2 is true
let g:is_mac = !g:is_windows && !g:is_cygmsys2
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') &&
      \     system('uname') =~? '^darwin'))
let g:is_linux = !g:is_windows && !g:is_cygmsys2 && !g:is_mac && has('unix')
if g:is_windows
  " Windows でもパスの区切り文字を / にする
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

" プラグインの読み込み
" let g:plug_shallow = 0
call plug#begin('$HOME/.vim/plugged')
  " vim-plug
  Plug 'junegunn/vim-plug',
        \ {'dir': '$HOME/.vim/plugged/vim-plug/autoload'}

  " =================================================================
  " View
  " =================================================================
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

  Plug 'itchyny/lightline.vim'                            " status-line
  Plug 'nathanaelkane/vim-indent-guides'                  " indent guide
  Plug 'airblade/vim-gitgutter'                           " Shows a git diff in the gutter!!!!!

  " =================================================================
  " Feature/Funcs Base
  " =================================================================
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


  Plug 'banyan/recognize_charcode.vim'                    " 文字コード判定
  Plug 'vim-scripts/sudo.vim'                             " sudo

  " =================================================================
  " Feature/Funcs Operation
  " =================================================================
  Plug 'thinca/vim-quickrun'                              " 現在のファイルを実行して quickfix に表示
  Plug 'osyo-manga/shabadou.vim'                          " quick-run 用プラグイン

  Plug 'kana/vim-submode'                                 " vim-submode(キーマップ plugin)
  Plug 'rhysd/accelerated-jk'                             " Accelareted-jk
  Plug 'terryma/vim-expand-region'                        " visually select increasingly larger regions of text via `v`
  Plug 'iberianpig/tig-explorer.vim'                      " vimからtig

  Plug 'thinca/vim-ambicmd'                               " 長いコマンド名を個別の設定なしで入力するためのプラグイン
  " Plug 'terryma/vim-multiple-cursors'                     " MultiCursor
  Plug 'ujihisa/unite-colorscheme'                        " カラースキーム変更

  " =================================================================
  " Feature/Funcs Search/Finds/Analyze
  " =================================================================
  Plug 'rking/ag.vim'                                     " SilverSearcher
  if !g:is_windows && !g:is_cygmsys2
      Plug 'junegunn/fzf', { 'dir': '$HOME/.fzf',
        \ 'do': './install --all' }                       " FZF
      Plug 'junegunn/fzf.vim'
  endif
  Plug 'rhysd/clever-f.vim'                               " f検索

  " ソース解析
  Plug 'Shougo/unite-outline'                             " 関数一覧とかを表示
  Plug 'vim-scripts/gtags.vim'                            " GNU Global
  if !g:is_windows
      Plug 'vim-scripts/taglist.vim'                      " ソースコードブラウザ
  endif

  if has('job') && has('channel') && has('timers')
    " Plug 'w0rp/ale'                                         " 構文解析(非同期)
    Plug 'dense-analysis/ale'                               " 構文解析(非同期)
  else
    Plug 'scrooloose/syntastic'                             " 構文解析
    " Plug 'vim-syntastic/syntastic'                        " 構文解析
  endif

  " コードフォーマッター
  " Plug 'google/vim-maktaba'                               " GoogleCodeFormatter depends
  " Plug 'google/vim-codefmt'                               " GoogleCodeFormatter
  " Plug 'google/vim-glaive'                                " GoogleCodeFormatter depends

  Plug 'editorconfig/editorconfig-vim'                      " Official editorconfig
  " Plug 'sgur/vim-editorconfig'                              " Not Official editorconfig(less depends)


  " =================================================================
  " Feature/Funcs Edit
  " =================================================================
  Plug 'Shougo/neosnippet'                                " Ctrl+k でスニペットを用意
  Plug 'Shougo/neosnippet-snippets'                       " 基本スニペット for neosnippet
  Plug 'honza/vim-snippets'                               " snipMate UltiSnip Snippets
  " Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

  " Plug 'Shougo/neocomplcache.vim'                         " 補完候補を自動でポップアップ(old)
  Plug 'Shougo/neocomplete.vim'                           " Next generation completion framework after neocomplcache

  " Plug 'kana/vim-smartchr'                                " = 等の便利入力
  Plug 'kana/vim-smartinput'                              " () 等の入力補完
  Plug 'tyru/caw.vim'                                     " コメントアウトプラグイン <Leader>+c
  Plug 'tpope/vim-surround'                               " 囲文字入力アシスト
  Plug 'vim-scripts/Align'                                " CSV,TSV整形
  Plug 'junegunn/vim-easy-align'                          " Align text


  " =================================================================
  " Langs or Others
  " =================================================================
  " Vim LSP!
  " @see https://mattn.kaoriya.net/?page=3
  Plug 'prabirshrestha/async.vim'
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-lsp.vim'
  Plug 'prabirshrestha/vim-lsp'                             " Vim Language Server Protocol
  Plug 'mattn/vim-lsp-settings'                             " use `:LspInstallServer`
  Plug 'mattn/vim-lsp-icons'
  Plug 'hrsh7th/vim-vsnip'                                  " 穴あき形式補完候補用？
  Plug 'hrsh7th/vim-vsnip-integ'


  Plug 'hashivim/vim-terraform'                             " Terraform syntax
  Plug 'posva/vim-vue'                                      " vue syntax
  Plug 'mindriot101/vim-yapf'                               " for python
  Plug 'cohama/vim-smartinput-endwise'                      " for ruby (end 補完)

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

  " ================================== memo
  " Plug 'othree/html5.vim'                                 " For erb tab indent
  " Plug 'vim-scripts/nginx.vim'                            " Nginx Syntax
  " Plug 'mattn/learn-vimscript.git'                        " Learn VimScript (:help learn-vimscript)
  " Plug 'vim-jp/vital.vim'                                 " A comprehensive Vim utility functions for Vim plugins
  " Plug 'mattn/wwwrenderer-vim'                            " www renderer for vim
  " Plug 'Shougo/unite-ssh'                                 "
  " Plug 'Shougo/vimshell'                                  " uniteインターフェースでシェル使用できる
  " Plug 'sjl/gundo.vim'                                    " UNDO履歴を管理 http://qiita.com/kinef/items/ddbccdacaf9507d9dd24
  " Plug 'fuenor/qfixhowm'                                  " メモプラグイン
  " Plug 'thinca/vim-openbuf'
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
