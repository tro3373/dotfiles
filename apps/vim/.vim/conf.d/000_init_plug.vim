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
let g:is_wsl = !empty($WSL_DISTRO_NAME)
let g:is_orb = system('uname -r') =~? '^.*-orbstack-.*'
let g:is_ubuntu = g:is_linux && (!filereadable("/etc/debian_version") && !filereadable("/etc/lsb-release"))
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
  " Plug 'vim-airline/vim-airline-themes'                 " TODO: airline theme. sample: https://github.com/vim-airline/vim-airline/wiki/Screenshots
  Plug 'norcalli/nvim-colorizer.lua'                      " A high-performance color highlighter for Neovim which has no external dependencies!
  Plug 'nathanaelkane/vim-indent-guides'                  " indent guide

  Plug 'airblade/vim-gitgutter'                           " Shows a git diff in the gutter!!!!!
  Plug 'tveskag/nvim-blame-line'                          " Show git blame info inline
  Plug 'tpope/vim-fugitive'                               " TODO: Git wrapper so awesome

  Plug 'junegunn/goyo.vim'                                " TODO: Distraction-free writing in Vim. (Toggle with :Goyo)

  " =================================================================
  " Filer
  " =================================================================
  " Plug 'mattn/ctrlp-filer'                                " Plugins for ctrlp.vim Filer (After start, Ctrl+D will not work bug occure.)
  " Plug 'Shougo/vimfiler'                                  " :VimFiler
  Plug 'cocopon/vaffle.vim'                               " SimpleFiler nouse
  " Plug 'scrooloose/nerdtree', {
  "   \ 'on':  ['NERDTreeToggle'] }                         " NERDTree tree view コマンド実行時に読み込む
  " Plug 'lambdalisue/fern.vim'                             " TODO: fern.vim is a plugin to manage files and directories in Vim

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
  Plug 'Shougo/unite.vim'                                 " ユーザインタフェース統合
  Plug 'Shougo/neomru.vim'                                " 最近使用したファイルの一覧管理

  " Fuzzy Finder
  Plug 'ctrlpvim/ctrlp.vim'                               " Fuzzy file, buffer, mru, tag, etc finder.
  " if !g:is_windows
  "   Plug 'nixprime/cpsm' , {'do': './install.sh' }        " Plugins for ctrlp.vim A CtrlP matcher, specialized for paths.
  " endif
  Plug 'vim-scripts/ctrlp-funky'                          " Plugins for ctrlp.vim Jump to a function
  Plug 'suy/vim-ctrlp-commandline'                        " Plugins for ctrlp.vim command line history navigation
  Plug 'sgur/ctrlp-extensions.vim'                        " Plugins for ctrlp.vim cmdline : cmdline history,
                                                          " yankring : yank history, menu : extension selector menu
  Plug 'vim-scripts/sudo.vim'                             " sudo

  " =================================================================
  " Buggy
  " Plug 'banyan/recognize_charcode.vim'                    " 文字コード判定
  " =================================================================

  " =================================================================
  " Feature/Funcs Operation
  " =================================================================
  Plug 'thinca/vim-quickrun'                              " 現在のファイルを実行して quickfix に表示
  Plug 'thinca/vim-ambicmd'                               " ユーザ定義コマンドを自動展開
  Plug 'osyo-manga/shabadou.vim'                          " quick-run 用プラグイン

  Plug 'kana/vim-submode'                                 " vim-submode(キーマップ plugin)
  Plug 'rhysd/accelerated-jk'                             " Accelareted-jk
  Plug 'terryma/vim-expand-region'                        " visually select increasingly larger regions of text via `v`
  Plug 'iberianpig/tig-explorer.vim'                      " vimからtig
  " Plug 'iberianpig/ranger-explorer.vim'                   " vimからranger

  Plug 'thinca/vim-ambicmd'                               " 長いコマンド名を個別の設定なしで入力するためのプラグイン
  " Plug 'terryma/vim-multiple-cursors'                     " MultiCursor
  Plug 'ujihisa/unite-colorscheme'                        " カラースキーム変更
  Plug 't9md/vim-quickhl'                                 " quick highlight

  Plug 'j-hui/fidget.nvim'                                " Extensible UI for Neovim notifications and LSP progress messages.

  " =================================================================
  " Feature/Funcs Search/Finds/Analyze
  " =================================================================
  " Plug 'rking/ag.vim'                                     " SilverSearcher
  if !g:is_windows && !g:is_cygmsys2
      Plug 'junegunn/fzf', { 'dir': '$HOME/.fzf',
       \ 'do': './install --all' }                       " FZF
      Plug 'junegunn/fzf.vim'
  endif
  Plug 'rhysd/clever-f.vim'                               " f検索
  " Plug 'easymotion/vim-easymotion'
  Plug 'skanehira/jumpcursor.vim'

  " ソース解析
  Plug 'Shougo/unite-outline'                             " 関数一覧とかを表示
  " Plug 'vim-scripts/gtags.vim'                            " GNU Global
  if !g:is_windows
      Plug 'vim-scripts/taglist.vim'                      " ソースコードブラウザ
  endif

  " =================================================================
  " Feature/Funcs Edit
  " =================================================================
  " Plug 'kana/vim-smartchr'                                " = 等の便利入力
  Plug 'kana/vim-smartinput'                              " () 等の入力補完
  " Plug 'mattn/vim-lexiv'                                " () 等の入力補完
  " -----------------------------------------------------------------
  " cohama/lexima.vim
  " 括弧の自動展開プラグインです。
  " インサートモードで ( を打つと ) を自動で補完する、といった機能を提供します。
  " ドットリピートに対応している他、カスタマイズ性が非常に高く、括弧に限らず様々なものを展開できる点も特徴です。
  "<Space>や<Tab>で即座に展開できるsnippetを好きなように定義できる最強プラグインで、
  "他のエディタを使うとまず「lexima的なものはないのか」と探して結局再現できないものの筆頭です。
  " 一見括弧などを自動補完するのように振る舞い、プリセットもほとんどそのような物だが、
  " lexical imap(らしい)の名の通り、挿入モード（とコマンドラインモード）に文脈を条件とした展開を行うルールを定義できるプラグイン。
  " 汎用性が高く、条件さえ満たせば何でもできる。それこそスニペットのような物を突っ込んだり、カーソル飛ばしたり（これはおかしいけど）コマンド実行したりできる。
  " docで強く主張されてるが、ドットリピートを重視しているのでVimmerとしてはありがたい限り。
  " 括弧やクオーテーションを一発で書き足す事ができるため。
  " 括弧やクォートなどを保管してくれるので記述効率がよくなる
  " Plug 'cohama/lexima.vim'                              " TODO: 括弧の自動展開
  " -----------------------------------------------------------------
  Plug 'Shougo/context_filetype.vim'
  " [posva/vim-vue: Syntax Highlight for Vue.js components](https://github.com/posva/vim-vue#nerdcommenter)
  " > caw.vim features built-in support for file context through context_filetype.vim.
  " > Just install both plugins and context-aware commenting will work in most files.
  " > The fenced code is detected by predefined regular expressions.
  " Plug 'tyru/caw.vim'                                     " コメントアウトプラグイン <Leader>+c
  " Plug 'nvim-treesitter/nvim-treesitter'                  " TODO: Code syntax highlight(tryu/caw.vim lua uncomment errorの解消の為いれたけど、解消せず、そのまま)
  " Plug 'sheerun/vim-polyglot'                             " TODO: Syntax highlight
  Plug 'tpope/vim-commentary'                             " コメントアウトプラグイン <Leader>+c
  Plug 'tpope/vim-surround'                               " 囲文字入力アシスト
  Plug 'tpope/vim-repeat'                                 " .で繰り返し(vim-surround対応)
  Plug 'vim-scripts/Align'                                " CSV,TSV整形
  Plug 'junegunn/vim-easy-align'                          " Align text


  " =================================================================
  " Code Edit
  " =================================================================
  if empty($VIM_DISABLE_LINTER) || (!empty($VIM_DISABLE_LINTER) && $VIM_DISABLE_LINTER != 1)
    Plug 'github/copilot.vim'

    Plug 'dense-analysis/ale'                                 " 構文解析(非同期)
    Plug 'maximbaz/lightline-ale'                             " ALE indicator for the lightline vim plugin.
    Plug 'editorconfig/editorconfig-vim'                      " Official editorconfig
    Plug 'mattn/sonictemplate-vim'

    " Code Formatter
    " Plug 'google/vim-maktaba'                                 " vimscript plugin library(GoogleCodeFormatter depends)
    " Plug 'google/vim-glaive'                                  " utility for configuring maktaba plugins(GoogleCodeFormatter depends)
    " Plug 'google/vim-codefmt'                                 " GoogleCodeFormatter
    " Plug 'sgur/vim-editorconfig'                              " Not Official editorconfig(less depends)

    " Complete
    " Plug 'Shougo/neocomplcache.vim'                         " 補完候補を自動でポップアップ(old)
    " Plug 'Shougo/neocomplete.vim'                           " Next generation completion framework after neocomplcache
    " if has('nvim')
    "   Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    " else
    "   Plug 'Shougo/deoplete.nvim'
    "   Plug 'roxma/nvim-yarp'
    "   Plug 'roxma/vim-hug-neovim-rpc', { 'do': 'pip install pynvim' }
    " endif

    Plug 'prabirshrestha/async.vim'                           " NoNeeded?

    " Vim LSP!
    " @see https://mattn.kaoriya.net/?page=3
    Plug 'prabirshrestha/vim-lsp'                             " Vim Language Server Protocol
    Plug 'mattn/vim-lsp-settings'                             " use `:LspInstallServer`
    Plug 'mattn/vim-lsp-icons'
    Plug 'halkn/lightline-lsp'                                " Display the diagnostic result of vim-lsp in the statusline of lightline.vim

    " Async complete is needed
    Plug 'prabirshrestha/asyncomplete.vim'

    " Snip
    Plug 'hrsh7th/vim-vsnip'                                  " 穴あき形式補完候補用？
    Plug 'hrsh7th/vim-vsnip-integ'

    Plug 'Shougo/neosnippet'                                " Ctrl+k でスニペットを用意
    Plug 'Shougo/neosnippet-snippets'                       " 基本スニペット for neosnippet
    Plug 'honza/vim-snippets'                               " snipMate UltiSnip Snippets

    Plug 'prabirshrestha/asyncomplete-lsp.vim'
    Plug 'prabirshrestha/asyncomplete-neosnippet.vim'
    " Plug 'prabirshrestha/asyncomplete-buffer.vim'
    Plug 'akaimo/asyncomplete-around.vim'
    Plug 'prabirshrestha/asyncomplete-file.vim'

    " TODO
    " Plug 'SirVer/ultisnips'                               " TODO: スニペットを拡張し、高速に使えるようにするです。
    " Plug 'honza/vim-snippets'
    " " This plugin integrates neosnippet.vim in vim-lsp to provide Language Server Protocol snippets.
    " Plug 'thomasfaingnaert/vim-lsp-snippets'
    " Plug 'thomasfaingnaert/vim-lsp-neosnippet'

    " Plug 'Shougo/neco-syntax'
    " Plug 'prabirshrestha/asyncomplete-necosyntax.vim'
    " Plug 'Shougo/neco-vim'
    " Plug 'prabirshrestha/asyncomplete-necovim.vim'            " for neco-vim
  endif

  " =================================================================
  " Langs or Others
  " =================================================================
  Plug 'ekalinin/Dockerfile.vim'                            " Dockerfile syntax
  Plug 'cespare/vim-toml', { 'branch': 'main' }             " Toml syntax
  Plug 'hashivim/vim-terraform'                             " Terraform syntax
  Plug 'posva/vim-vue'                                      " vue syntax
  Plug 'mindriot101/vim-yapf'                               " for python
  Plug 'leafgarland/typescript-vim'                         " for typescript
  Plug 'jidn/vim-dbml'                                      " for dbml
  " NOTE: So slow `has('python3')`
  " if has('python3')
  " Plug 'davidhalter/jedi-vim'                               " for python completion
  " endif
  Plug 'cohama/vim-smartinput-endwise'                      " for ruby (end 補完)
  Plug 'digitaltoad/vim-pug'                                " pug
  Plug 'dart-lang/dart-vim-plugin'                          " dart
  Plug 'udalov/kotlin-vim'                                  " kotlin

  Plug 'tyru/open-browser.vim'                              " Open browser
  Plug 'rcmdnk/vim-markdown'                                " Markdown syntax
  Plug 'mattn/vim-sqlfmt'                                   " SQL

  " Markdown Preview 関連
  " Plug 'kannokanno/previm'
  " Plug 'plasticboy/vim-markdown'
  " MEMO: Not work all. render quit in the middle
  " Plug 'skanehira/preview-markdown.vim'                   " Preview in buffer. depends MichaelMure/mdr
  " MEMO: deno is cool, but layout is..
  " if executable('deno')
  "   Plug 'vim-denops/denops.vim'
  "   " Need chrome extension https://chrome.google.com/webstore/detail/cross-domain-cors/mjhpgnbimicffchbodmgfnemoghjakai/related?hl=ja
  "   Plug 'kat0h/bufpreview.vim'
  " endif
  " Preview in browser. via `:MarkdownPreview`
  " Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm i'  }
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
  " Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

  if g:is_windows
    " Plug 'mattn/webapi-vim'                               " vim interface to Web API
      Plug 'mattn/excelview-vim'
      Plug 'mattn/startmenu-vim'
  endif

  " ================================== todo
  " Plug 'amitds1997/remote-nvim.nvim'                      " Remote development plugin for neovim
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
  " Plug 'junegunn/seoul256.vim'
  " Plug 'tpope/vim-fireplace', { 'for': ['clojure'] }      " 指定したファイルタイプを開いたときに読み込む
  " migemo
  " ================================== drop
  " Plug 'Lokaltog/vim-easymotion'                          " カーソル移動プラグイン(fコマンドが効かなくなるので無効)
  " Plug 'bling/vim-airline'
  " Plug 'powerline/powerline',
  "     \ {'rtp': 'powerline/bindings/vim/'}
  " Plug 'glidenote/memolist.vim'                           " simple memo plugin for Vim. No use
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
