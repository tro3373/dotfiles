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
set tabpagemax=99
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
" 以下タイミングで、checktime を実行
" WinEnter: ウィンドウがアクティブになった時
" FocusGained: ウィンドウがアクティブになった時
" BufEnter: バッファがアクティブになった時
augroup auto-checktime
  autocmd!
  autocmd WinEnter,FocusGained,BufEnter * checktime
augroup END


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
" © Only File Not working see [.vimrc | 暇人専用](http://himajin-senyo.com/conf/vimrc/)
" set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
" [Vim – 文字コードを自動認識して判定/判別する方法 | Howpon[ハウポン]](https://howpon.com/20630)
" set fileencodings=iso-2022-jp,ucs-bom,utf-8,euc-jp,cp932,sjis,default,latin1
"[Vimの文字コードの認識の仕組みと、文字化けを減らすための設定 - Qiita](https://qiita.com/aikige/items/12ffa2574199cc740a44)
set fileencodings=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp,default,latin
" setglobal fileformat=unix
" 新規、読込時の改行設定(複数で自動判定)
set fileformats=unix,dos,mac
" ■Unicodeで行末が変になる問題を解決
if &encoding == 'utf-8'
  if exists('&ambw')
    " set ambiwidth=double
    set ambw=double
  endif
endif

"-----------------------------------------------------
" インデント設定
"-----------------------------------------------------
" C言語スタイルのインデントを使用
set cindent
" オートインデント
set autoindent
" 賢いインデント
set smartindent
" 改行時にコメントを続けるか等の自動整形オプション
" ex) formatoptions-=c
"     - jcroql (in java,vim)
"     - tqj (in python)
" c: (textwidth の値を超える)長いコメント行を入力した場合に自動で改行
" t: (textwidth の値を超える)長いテキスト行を入力した場合に自動で改行
" l: インサートモード時(textwidth の値を超える)長い行入力中に改行しない
" r: Enter 入力時にコメントリーダーを挿入する。
" o: o あるいは O で行を挿入した場合にコメントリーダーを挿入する。
" j: 結合時にコメントリーダーを削除する
" q: gq コマンドで選択部分をコメント整形する。
" set formatoptions-=c
" " setglobal formatoptions+=mb
set formatoptions=jcroql

" ts  = tabstop     ファイル中の<TAB>を見た目x文字に展開する(既に存在する<TAB>の見た目の設定)
" sts = softtabstop TABキーを押した際に挿入される空白の量を設定
" sw  = shiftwidth  インデントやシフトオペレータで挿入/削除されるインデントの幅を設定
" tw  = textwidth
" ft  = filetype
" expandtab         <TAB>を空白スペース文字に置き換える
set ts=4 sts=4 sw=4 expandtab
if has("autocmd")
  " ファイル種別による個別設定
  autocmd FileType sh,zsh,bash,vim,html,xhtml,css,scss,javascript,typescript,typescriptreact,yaml,toml,ruby,coffee,sql,vue setlocal ts=2 sts=2 sw=2
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
  if exists('##TermOpen')
    " tig から開く vim? にTermOpenイベントがないため
    " エラーが発生するので有効な場合のみ
    augroup terminal
      autocmd!
      " " terminal開始時にインサートモードを開始する(302-tig-nvr起動時のみ)
      " autocmd BufWinEnter,WinEnter term://* startinsert
      " terminal開始時にインサートモードを開始する(常に)
      autocmd TermOpen term://* startinsert
      " " terminal バッファから抜ける際ににインサートモードを解除する
      " autocmd BufLeave term://* stopinsert
      " terminal JOBの終了ステータスが成功であれば、バッファを閉じる
      autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif
    augroup END
  endif
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
"[Vimで全角スペースその他不可視文字をハイライトする設定](https://zenn.dev/kawarimidoll/articles/450a1c7754bde6)
" u00A0 ' ' no-break space
" u2000 ' ' en quad
" u2001 ' ' em quad
" u2002 ' ' en space
" u2003 ' ' em space
" u2004 ' ' three-per em space
" u2005 ' ' four-per em space
" u2006 ' ' six-per em space
" u2007 ' ' figure space
" u2008 ' ' punctuation space
" u2009 ' ' thin space
" u200A ' ' hair space
" u200B '​' zero-width space
" u3000 '　' ideographic (zenkaku) space
augroup extra-whitespace
  autocmd VimEnter,WinEnter * call matchadd('ExtraWhitespace', "[\u00A0\u2000-\u200B\u3000]")
  autocmd ColorScheme * highlight default ExtraWhitespace ctermbg=darkmagenta guibg=darkmagenta
augroup END


" TAB文字/行末の半角スペースを表示する
set lcs=tab:\▸\ ,trail:_,extends:\
set list
highlight SpecialKey cterm=NONE ctermfg=cyan guifg=cyan

" 行番号を表示する
set number
" " 相対行番号を表示する
" set relativenumber
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

" Enable Java Highlight
" @see https://nanasi.jp/articles/vim/java_vim.html
" 標準クラス名のハイライト
let java_highlight_all = 1
" デバッグ文のハイライト
let java_highlight_debug=1
" C++ キーワードのハイライト
" 下記のC++言語のキーワードをハイライトします。
" auto delete enum extern friend inline redeclared
" register signed sizeof struct template typedef union
" unsigned operator
let java_allow_cpp_keywords=1
" 余分な空白に対して警告
let java_space_errors=1
" メソッドの宣言文と、ブレースのハイライト
let java_highlight_functions = 1
" @see https://superuser.com/questions/627636/better-syntax-highlighting-for-java-in-vim
" Some more highlights, in addition to those suggested by cmcginty
" highlight link javaScopeDecl Statement
" highlight link javaType Type
" highlight link javaDocTags PreProc

if g:is_linux
  set clipboard=unnamedplus
  " vmap <C-c> :w !xsel -ib<CR><CR>
  " vmap <C-y> :w !xsel -ib<CR><CR>
  "
  " unnamedplus: use clipboard in vim for linux.
  " `set clipboard&`: Set clipboard option to default.(Support reload vimrc to fix add loop)
  " `set clipboard^=unnamedplus`: Add `unnamedplus` option to first.
  "   - Default clipboard options is `autoselect,exclude:cons\|linux`
  "     - option will be excluded defined after `exclude`.
  " set clipboard&
  " set clipboard^=unnamedplus
else
  set clipboard=unnamed
endif

" Yank post handling
" @see
" - [Vim: pipe register to external command - Stack Overflow](https://stackoverflow.com/questions/10780469/vim-pipe-register-to-external-command)
" - [vim : how to write to another file my lines yanked? - Stack Overflow](https://stackoverflow.com/questions/34785759/vim-how-to-write-to-another-file-my-lines-yanked)
" autocmd TextYankPost * if v:event.operator ==# 'y' | call system('echo '.@0.'|'.s:clip) | endif
" autocmd TextYankPost * call system(s:clip, @0)
let g:winclip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
let s:clip = $HOME.'/.dot/bin/clip'
function! s:set_yank_post_for_win()
  if $DISPLAY == ':0'
    " DISPLAY :0 => wslg is running
    " define only wsl(no define in wslg)
    return
  endif
  augroup my-yank-post
    autocmd!
    autocmd TextYankPost * call system(g:winclip, @0)
  augroup END
endfunction
function! s:set_yank_post_in_remote_not_vagrant()
  let s:is_remote = $REMOTEHOST..$SSH_CONNECTION
  if empty(s:is_remote) || $IS_VAGRANT == '1'
    return
  endif
  function! s:yank_post_in_remote_not_vagrant()
    let s:cliptmp = $HOME.'/.vim/.clip.tmp'
    call writefile(split(getreg('0'), '\n'), s:cliptmp)
    call system('cat <'..s:cliptmp..'|'..s:clip)
    " echo system(s:clip, @0)
  endfunction
  augroup my-yank-post
    autocmd!
    autocmd TextYankPost * call s:yank_post_in_remote_not_vagrant(v:event)
  augroup END
endfunction

if executable(g:winclip)
  call s:set_yank_post_for_win()
elseif executable(s:clip)
  call s:set_yank_post_in_remote_not_vagrant()
endif

" augroup LargeFile
"   let g:large_file = 10485760 " 10MB
"   " Set options:
"   "   eventignore+=FileType (no syntax highlighting etc
"   "   assumes FileType always on)
"   "   noswapfile (save copy of file)
"   "   bufhidden=unload (save memory when other file is viewed)
"   "   buftype=nowritefile (is read-only)
"   "   undolevels=-1 (no undo possible)
"   au BufReadPre *
"    \ let f=expand("<afile>") |
"    \ if getfsize(f) > g:large_file |
"      \ set eventignore+=FileType |
"      \ setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 |
"    \ else |
"      \ set eventignore-=FileType |
"    \ endif
" augroup END

"==============================================================================
" Read local vimrc settings
" @see [vim-jp » Hack #112: 場所ごとに設定を用意する](https://vim-jp.org/vim-users-jp/2009/12/27/Hack-112.html)
" @see [HiPhish's Workshop](https://hiphish.github.io/blog/2020/02/08/project-local-vim-settings-the-right-way/)
" Load settings for each location.
augroup local-rc
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:load_local_rc()
augroup END
function! s:get_local_rc_path()
  return $HOME .. "/.ldot/vim/additional" .. getcwd() .. '/local.vimrc'
endfunction
function! s:load_local_rc()
  let l:rc = s:get_local_rc_path()
  if ! filereadable(l:rc)
    return
  endif
  echo '==> Loading local vimrc settings ' .. l:rc .. ' ...'
  " source `=l:rc`
  execute 'source' l:rc
endfunction
function! OpenLocalRc()
  let l:rc = s:get_local_rc_path()
  if ! filereadable(l:rc)
    return
  endif
  exe "tabe" l:rc
endfunction
command! OpenLocalRc call OpenLocalRc()

"==============================================================================
" SQL auto uppercase
augroup sql-auto-uppercase
  autocmd!
  autocmd FileType sql iabbrev <buffer> select SELECT
  autocmd FileType sql iabbrev <buffer> update UPDATE
  autocmd FileType sql iabbrev <buffer> delete DELETE
  autocmd FileType sql iabbrev <buffer> from FROM
  autocmd FileType sql iabbrev <buffer> where WHERE
  autocmd FileType sql iabbrev <buffer> order ORDER
  autocmd FileType sql iabbrev <buffer> by BY
  autocmd FileType sql iabbrev <buffer> join JOIN
  autocmd FileType sql iabbrev <buffer> on ON
  autocmd FileType sql iabbrev <buffer> set SET
augroup END
