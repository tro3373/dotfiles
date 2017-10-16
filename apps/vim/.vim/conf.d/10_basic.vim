"######################################################################
"   basic.vim
"           基本設定
"           エディタ機能やVim自体の動作に関わる設定を行う
"######################################################################

" カレントディレクトリを自動的に変更
" set autochdir
" UTF-8をデフォルト文字コードセットに設定
" encoding(enc)
"   vimの内部で使用されるエンコーディングを指定する。
"   編集するファイル内の全ての文字を表せるエンコーディングを指定するべき。
set encoding=utf-8
" fileencoding(fenc)
"   そのバッファのファイルのエンコーディングを指定する。
"   バッファにローカルなオプション。これに encoding と異なる値が設定されていた場合、
"   ファイルの読み書き時に文字コードの変換が行なわれる。
"   fencが空の場合、encodingと同じ値が指定されているものとみなされる。(つまり、変換は行なわれない。)
set fileencoding=utf-8
" fileencodings(fencs)
"   既存のファイルを編集する際に想定すべき文字コードのリストをカンマ区切りで列挙したものを指定する。
"   編集するファイルを読み込む際には、「指定された文字コード」→「encodingの文字コード」の変換が試行され、
"   最初にエラー無く変換できたものがそのバッファの fenc に設定される。
"   fencsに列挙された全ての文字コードでエラーが出た場合、fencは空に設定され、その結果、
"   文字コードの変換は行われないことになる。fencsにencodingと同じ文字コードを途中に含めると、
"   その文字コードを試行した時点で、「 encoding と同じ」→「文字コード変換の必要無し」→「常に変換成功」→「fencに採用」となる。
" set fileencodings=ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,cp932,sjis,utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
" 新規、読込時の改行設定(複数で自動判定)
set fileformats=unix,dos,mac
set helplang=ja,en
" ビープ音を鳴らさない
set vb t_vb=
" Backspace を有効にする
set backspace=indent,eol,start
" 自動読み直し
set autoread
" ターミナル時でもマウスを使えるようにする
set mouse=a
set guioptions+=a
set ttymouse=xterm2
" C-vの矩形選択で行末より後ろもカーソルを置ける
set virtualedit=block

" ~/.vim/_viminfo を viminfo ファイルとして指定
set viminfo+=n~/.vim/_viminfo
" ~/.vim/backupをバックアップ先ディレクトリに指定する
set backup
set backupdir=$HOME/.vim/backup
let &directory = &backupdir
" Undoファイルの出力先を設定
set undodir=$HOME/.vim/undo
" スワップがあるときは常にRead-Onlyで開く設定
" スワップのメッセージを見たいという時は、:noa e [filename] のように
" :noa(utocmd)コマンド
" http://itchyny.hatenablog.com/entry/2014/12/25/090000
augroup swapchoice-readonly
  autocmd!
  autocmd SwapExists * let v:swapchoice = 'o'
augroup END

" ファイルオープン時に元の位置を開く
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END

" インクリメンタルサーチを有効にする
set incsearch
" 検索結果のハイライト表示を有効にする
set hlsearch
" 大文字と小文字を区別しない
set ignorecase
" 検索時に大文字を含んでいたら大/小を区別
set smartcase

" ヤンクした際にクリップボードへ配置する
set clipboard=unnamed

if !has("mac") && has("unix")
  let s:ostype = substitute(system("echo $OSTYPE"), '\n', '', '')
  if "msys" != s:ostype
    set clipboard=unnamedplus
    vmap <C-c> :w !xsel -ib<CR><CR>
    vmap <C-y> :w !xsel -ib<CR><CR>
  endif
endif

" 挿入モードからノーマルモードに戻る時にペーストモードを自動で解除
autocmd InsertLeave * set nopaste

" html5.vim
if g:plug.is_installed("html5.vim")
  let g:html5_event_handler_attributes_complete = 1
  let g:html5_rdfa_attributes_complete = 1
  let g:html5_microdata_attributes_complete = 1
  let g:html5_aria_attributes_complete = 1
endif

"-----------------------------------------------------
" インデント設定
"-----------------------------------------------------
" Ｃ言語スタイルのインデントを使用する
set cindent
" オートインデント
set autoindent
" 賢いインデント
set smartindent
"フォーマット揃えをコメント以外有効にする
set formatoptions-=c
" ts  = tabstop     ファイル中の<TAB>を見た目x文字に展開する(既に存在する<TAB>の見た目の設定)
" sts = softtabstop TABキーを押した際に挿入される空白の量を設定
" sw  = shiftwidth  インデントやシフトオペレータで挿入/削除されるインデントの幅を設定
" tw  = textwidth
" ft  = filetype
" expandtab         <TAB>を空白スペース文字に置き換える
set ts=4 sts=4 sw=4 expandtab
if has("autocmd")
  " ファイル種別による個別設定
  autocmd FileType vim,html,xhtml,css,javascript,yaml,ruby,coffee setlocal ts=2 sts=2 sw=2

  " ファイルを開いた時、読み込んだ時にファイルタイプを設定する
  autocmd BufNewFile,BufRead *.js setlocal ft=javascript
  autocmd BufNewFile,BufRead *.ejs setlocal ft=html
  autocmd BufNewFile,BufRead *.py setlocal ft=python
  autocmd BufNewFile,BufRead *.rb setlocal ft=ruby
  autocmd BufNewFile,BufRead *.erb setlocal ft=ruby
  autocmd BufNewFile,BufRead Gemfile setlocal ft=ruby
  autocmd BufNewFile,BufRead *.coffee setlocal ft=coffee
  autocmd BufNewFile,BufRead *.ts setlocal ft=typescript
  autocmd BufNewFile,BufRead *.md setlocal ft=markdown
  autocmd BufNewFile,BufRead *.jade setlocal ft=markdown
  autocmd BufNewFile,BufRead *.gyp setlocal ft=json
  autocmd BufNewFile,BufRead *.cson setlocal ft=json
  autocmd BufNewFile,BufRead *.yml setlocal ft=yaml
  autocmd BufNewFile,BufRead *.yaml setlocal ft=yaml
  " ctagsファイルの設定ファイル
  " autocmd BufNewFile,BufRead *.rb set tags+=;$HOME/.ruby.ctags;
  " autocmd BufNewFile,BufRead *.js set tags+=;$HOME/.javascript.ctags;
endif

" コマンド補完機能
set wildmenu
" zsh like な補完に
set wildmode=longest:full,full

" cana/vim-smartinput, cohama/vim-smartinput-endwise
" http://cohama.hateblo.jp/entry/2013/11/08/013136
if g:plug.is_installed("vim-smartinput")
  call smartinput_endwise#define_default_rules()
endif

" ctags 設定
" set tags+=./tags;
" set tags=./tags,./TAGS,tags,TAGS " original?
" set tags=./tags;./.git/tags;
set tags=**1/.git/tags;./.git/tags;./tags;

