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


" カーソルが飛ぶ時間を0.1秒で設定
set matchtime=1
" ターミナル接続を高速にする
set ttyfast
" スクロールした際に余白が５行分残るようにする
set scrolloff=5
" 閉じ括弧が入力されたとき、対応する括弧を表示する
set showmatch
" vim -p で開ける最大タブ数
set tabpagemax=20
" コマンド補完機能
set wildmenu
" zsh like な補完に
set wildmode=longest:full,full
" https://stackoverflow.com/questions/6726783/changing-default-position-of-quickfix-window-in-vim
" For quickfix
set splitright
" デフォルトのdiffspritは縦分割指定
set diffopt+=vertical

" ターミナル時でもマウスを使えるようにする
set mouse=a
set guioptions+=a
if !has('nvim')
  set ttymouse=xterm2
endif
" ビープ音を鳴らさない
set vb t_vb=
" C-vの矩形選択で行末より後ろもカーソルを置ける
set virtualedit=block
" Backspace を有効にする
set backspace=indent,eol,start
" help の高さ
set helpheight=99999
" help の高さ
set helplang=ja,en


" 元のファイルの変更を Vim が検知し、かつバッファが変更されていなかった場合、バッファは自動的に再読み込み
set autoread


" インクリメンタルサーチを有効にする
set incsearch
" 検索結果のハイライト表示を有効にする
set hlsearch
" 大文字と小文字を区別しない
set ignorecase
" 検索時に大文字を含んでいたら大/小を区別
set smartcase
" ~/.vim/_viminfo を viminfo ファイルとして指定
if has('nvim')
  set viminfo+=n~/.vim/_nviminfo
else
  set viminfo+=n~/.vim/_viminfo
endif


" ヤンクした際にクリップボードへ配置する
" '*' register => x window clipboard
set clipboard=unnamed
if !has("mac") && has("unix")
  let s:ostype = substitute(system("echo $OSTYPE"), '\n', '', '')
  if "msys" != s:ostype
    " '+' register => x window clipboard
    set clipboard=unnamedplus
    vmap <C-c> :w !xsel -ib<CR><CR>
    vmap <C-y> :w !xsel -ib<CR><CR>
  endif
endif

" 挿入モードからノーマルモードに戻る時にペーストモードを自動で解除
autocmd InsertLeave * set nopaste


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
" setglobal fileformat=unix
" 新規、読込時の改行設定(複数で自動判定)
set fileformats=unix,dos,mac

"-----------------------------------------------------
" インデント設定
"-----------------------------------------------------
" C言語スタイルのインデントを使用
set cindent
" オートインデント
set autoindent
" 賢いインデント
set smartindent
"フォーマット揃えをコメント以外有効にする
set formatoptions-=c
" setglobal formatoptions+=mb

" ts  = tabstop     ファイル中の<TAB>を見た目x文字に展開する(既に存在する<TAB>の見た目の設定)
" sts = softtabstop TABキーを押した際に挿入される空白の量を設定
" sw  = shiftwidth  インデントやシフトオペレータで挿入/削除されるインデントの幅を設定
" tw  = textwidth
" ft  = filetype
" expandtab         <TAB>を空白スペース文字に置き換える
set ts=4 sts=4 sw=4 expandtab
if has("autocmd")
  " ファイル種別による個別設定
  autocmd FileType sh,zsh,bash,vim,html,xhtml,css,javascript,yaml,ruby,coffee,sql,vue setlocal ts=2 sts=2 sw=2
  " ファイルの先頭からパースしてハイライトを行う
  autocmd FileType vue syntax sync fromstart

  " ファイルを開いた時、読み込んだ時にファイルタイプを設定する
  autocmd BufNewFile,BufRead *.js setlocal ft=javascript
  autocmd BufNewFile,BufRead *.ejs setlocal ft=html
  " autocmd BufNewFile,BufRead *.vue setlocal ft=html
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
  autocmd BufNewFile,BufRead Jenkinsfile setlocal ft=groovy
  " ctagsファイルの設定ファイル
  " autocmd BufNewFile,BufRead *.rb set tags+=;$HOME/.ruby.ctags;
  " autocmd BufNewFile,BufRead *.js set tags+=;$HOME/.javascript.ctags;
endif



" ステータスラインの表示変更
"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}:%{&fenc!=''?&fenc:&enc}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
" Always display the statusline in all windows
set laststatus=2
" Always display the tabline, even if there is only one tab
set showtabline=2
" Hide the default mode text (e.g. -- INSERT -- below the statusline)
set noshowmode
" コマンドラインの高さ
setglobal cmdheight=2


" ターミナル環境用に256色を使えるようにする
set t_Co=256
if &term == 'screen-256color'
  " 背景の塗り潰しは行わない
  set t_ut=
endif
" autocmd VimEnter,ColorScheme * hi ColorColumn ctermbg=lightblue guibg=lightblue
" 検索結果ハイライト色設定
" autocmd VimEnter,ColorScheme * hi Search  xxx ctermfg=234 ctermbg=221 guifg=#1d1f21 guibg=#f0c674
autocmd VimEnter,ColorScheme * hi Search ctermfg=238 ctermbg=109 guifg=#646D75 guibg=#87afaf
" シンタックスハイライトを有効にする
syntax enable
" default syntax for No syntax
au BufNewFile,BufRead * if &syntax == '' | set syntax=sh | endif



" 補完メニューの高さ
set pumheight=10
" 長い行も表示
set display=lastline
" ■Unicodeで行末が変になる問題を解決
if &encoding == 'utf-8'
  set ambiwidth=double
endif
" 全角スペースを分かりやすく表示する
highlight ZenkakuSpace cterm=underline ctermfg=lightmagenta guibg=lightmagenta
match ZenkakuSpace /　/
" TAB文字/行末の半角スペースを表示する
set lcs=tab:\▸\ ,trail:_,extends:\
set list
highlight SpecialKey cterm=NONE ctermfg=cyan guifg=cyan

" 行番号を表示する
set number
" ルーラを表示
set ruler

" カーソル行・列表示設定
" " カーソル行・列を常に表示
" set cursorline cursorcolumn
" カーソル行・列を一定時間入力なし時、ウィンドウ移動直後に表示
augroup vimrc-auto-cursorline
  autocmd!
  autocmd CursorMoved,CursorMovedI * call s:auto_cursorline('CursorMoved')
  autocmd CursorHold,CursorHoldI * call s:auto_cursorline('CursorHold')
  autocmd WinEnter * call s:auto_cursorline('WinEnter')
  autocmd WinLeave * call s:auto_cursorline('WinLeave')

  let s:cursorline_lock = 0
  function! s:auto_cursorline(event)
    if a:event ==# 'WinEnter'
      setlocal cursorline cursorcolumn
      let s:cursorline_lock = 2
    elseif a:event ==# 'WinLeave'
      setlocal nocursorline nocursorcolumn
    elseif a:event ==# 'CursorMoved'
      if s:cursorline_lock
        if 1 < s:cursorline_lock
          let s:cursorline_lock = 1
        else
          setlocal nocursorline nocursorcolumn
          let s:cursorline_lock = 0
        endif
      endif
    elseif a:event ==# 'CursorHold'
      setlocal cursorline cursorcolumn
      let s:cursorline_lock = 1
    endif
  endfunction
augroup END

" hi=highlight
" " カーソル行・列表示色設定
" autocmd VimEnter,ColorScheme * hi CursorLine    ctermbg=Blue ctermfg=Blue
" autocmd VimEnter,ColorScheme * hi CursorColumn  ctermbg=Blue ctermfg=Green
" autocmd VimEnter,ColorScheme * hi CursorLine    term=underline cterm=underline guibg=Grey90
" autocmd VimEnter,ColorScheme * hi CursorColumn  term=reverse ctermbg=7 guibg=Grey90

" 80 に縦 Line
" set colorcolumn=80
" 81 文字より後ろの色を変える
" let &colorcolumn=join(range(81,999),",")
" 80 に縦 Line 120 文字より後ろの色を変える
" let &colorcolumn="80,".join(range(120,999),",")
let &colorcolumn="80,120"




" カレントディレクトリを自動的に変更
" set autochdir

" https://mattn.kaoriya.net/software/vim/20191231001537.htm
" " Vim 本体の機能のデフォルト値を経項する設定
"
" if !has('win32') && !has('win64')
"   setglobal shell=/bin/bash
" endif
"
" if exists('&termguicolors')
"   setglobal termguicolors
" endif
"
" if exists('&completeslash')
"   setglobal completeslash=slash
" endif

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
  augroup WSLYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
endif
