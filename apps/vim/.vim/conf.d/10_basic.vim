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
set fileencodings=ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,cp932,sjis,utf-8
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


" Ｃ言語スタイルのインデントを使用する
set cindent
" ファイル中の<TAB>を見た目x文字に展開する(既に存在する<TAB>の見た目の設定)
set tabstop=4
" TABキーを押した際に挿入される空白の量を設定
set softtabstop=4
" インデントやシフトオペレータで挿入/削除されるインデントの幅を設定
set shiftwidth=4
" <TAB>を空白スペース文字に置き換える
set expandtab
" オートインデント
set autoindent
" 賢いインデント
set smartindent
"フォーマット揃えをコメント以外有効にする
set formatoptions-=c
augroup fileTypeIndent
    autocmd!
    autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufNewFile,BufRead *.rb setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" コマンド補完機能
" set wildmenu
" zsh like な補完に
" set wildmode=longest,list:longest

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

