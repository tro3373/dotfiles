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
  autocmd FileType sh,vim,html,xhtml,css,javascript,yaml,ruby,coffee setlocal ts=2 sts=2 sw=2

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


"######################################################################
" 見た目の設定
"######################################################################

" ターミナル環境用に256色を使えるようにする
set t_Co=256
if &term == 'screen-256color'
  " 背景の塗り潰しは行わない
  set t_ut=
endif

" 行番号を表示する
set number
" ルーラを表示
set ruler
" カーソル行・列表示設定
if 0
  " カーソル行・列を常に表示
  set cursorline cursorcolumn
else
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
endif

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
" autocmd VimEnter,ColorScheme * hi ColorColumn ctermbg=lightblue guibg=lightblue
" 検索結果ハイライト色設定
" autocmd VimEnter,ColorScheme * hi Search  xxx ctermfg=234 ctermbg=221 guifg=#1d1f21 guibg=#f0c674
autocmd VimEnter,ColorScheme * hi Search ctermfg=238 ctermbg=109 guifg=#646D75 guibg=#87afaf

" 閉じ括弧が入力されたとき、対応する括弧を表示する
set showmatch
" カーソルが飛ぶ時間を0.1秒で設定
set matchtime=1
" スクロールした際に余白が５行分残るようにする
set scrolloff=5
" ターミナル接続を高速にする
set ttyfast
" ■Unicodeで行末が変になる問題を解決
if &encoding == 'utf-8'
  set ambiwidth=double
endif
" 長い行も表示
set display=lastline
" 補完メニューの高さ
set pumheight=10

" 全角スペースを分かりやすく表示する
highlight ZenkakuSpace cterm=underline ctermfg=lightmagenta guibg=lightmagenta
match ZenkakuSpace /　/
" TAB文字/行末の半角スペースを表示する
set lcs=tab:^\ ,trail:_,extends:\
set list
highlight SpecialKey cterm=NONE ctermfg=cyan guifg=cyan

" Indent Guide Settings
if g:plug.is_installed("vim-indent-guides")
  " set ts=4 sw=4 et
  let g:indent_guides_enable_on_vim_startup=1     " Vim起動時に可視化設定
  let g:indent_guides_start_level=2               " ガイドをスタートするインデントの量
  let g:indent_guides_guide_size=1                " ガイドの幅
  let g:indent_guides_auto_colors=0               " 自動カラー設定
  " autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=black
  " autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=darkgrey
  " autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=234    " Odd(奇数) 色
  autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=233    " Odd(奇数) 色
  autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=236    " Even(偶数) 色
endif

" シンタックスハイライトを有効にする
syntax enable
" default syntax for No syntax
au BufNewFile,BufRead * if &syntax == '' | set syntax=sh | endif

" ステータスラインの表示変更
"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}:%{&fenc!=''?&fenc:&enc}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
" Always display the statusline in all windows
set laststatus=2
" Always display the tabline, even if there is only one tab
set showtabline=2
" Hide the default mode text (e.g. -- INSERT -- below the statusline)
set noshowmode

" lightline Settings
"   solarized/seoul256/jellybeans
if g:plug.is_installed("lightline.vim")
  if 0
    let g:lightline = {
    \    'colorscheme': 'seoul256',
    \    'component': {
    \      'readonly': '%{&readonly?"x":""}',
    \    },
    \    'separator': { 'left': '', 'right': '' },
    \    'subseparator': { 'left': '|', 'right': '|' }
    \ }
  else
    let g:lightline = {
    \     'colorscheme': 'seoul256',
    \     'mode_map': {'c': 'NORMAL'},
    \     'active': {
    \       'left': [
    \         ['mode', 'paste'],
    \         ['fugitive', 'pwd', 'filename', 'gitgutter'],
    \       ],
    \       'right': [
    \         ['lineinfo', 'syntastic'],
    \         ['percent'],
    \         ['fileformat', 'fileencoding', 'filetype'],
    \       ]
    \     },
    \     'component_function': {
    \       'pwd': 'MyPwd',
    \       'modified': 'MyModified',
    \       'readonly': 'MyReadonly',
    \       'fugitive': 'MyFugitive',
    \       'filename': 'MyFilename',
    \       'fileformat': 'MyFileformat',
    \       'filetype': 'MyFiletype',
    \       'fileencoding': 'MyFileencoding',
    \       'mode': 'MyMode',
    \       'syntastic': 'SyntasticStatuslineFlag',
    \       'charcode': 'MyCharCode',
    \       'gitgutter': 'MyGitGutter',
    \     }
    \ }

    function! MyPwd()
      return getcwd()
    endfunction

    function! MyModified()
      return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
    endfunction

    function! MyReadonly()
      return &ft !~? 'help\|vimfiler\|gundo' && &ro ? '(ro)' : ''
    endfunction

    function! MyFilename()
      return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
            \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
            \  &ft == 'unite' ? unite#get_status_string() :
            \  &ft == 'vimshell' ? substitute(b:vimshell.current_dir,expand('~'),'~','') :
            \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
            \ ('' != MyModified() ? ' ' . MyModified() : '')
    endfunction

    function! MyFugitive()
      try
        if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
          let _ = fugitive#head()
          return strlen(_) ? '⭠ '._ : ''
        endif
      catch
      endtry
      return ''
    endfunction

    function! MyFileformat()
      return winwidth('.') > 70 ? &fileformat : ''
    endfunction

    function! MyFiletype()
      return winwidth('.') > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
    endfunction

    function! MyFileencoding()
      return winwidth('.') > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
    endfunction

    function! MyMode()
      return winwidth('.') > 60 ? lightline#mode() : ''
    endfunction

    function! MyGitGutter()
      if ! exists('*GitGutterGetHunkSummary')
            \ || ! get(g:, 'gitgutter_enabled', 0)
            \ || winwidth('.') <= 90
        return ''
      endif
      let symbols = [
            \ g:gitgutter_sign_added . ' ',
            \ g:gitgutter_sign_modified . ' ',
            \ g:gitgutter_sign_removed . ' '
            \ ]
      let hunks = GitGutterGetHunkSummary()
      let ret = []
      for i in [0, 1, 2]
        if hunks[i] > 0
          call add(ret, symbols[i] . hunks[i])
        endif
      endfor
      return join(ret, ' ')
    endfunction

    " https://github.com/Lokaltog/vim-powerline/blob/develop/autoload/Powerline/Functions.vim
    function! MyCharCode()
      if winwidth('.') <= 70
        return ''
      endif

      " Get the output of :ascii
      redir => ascii
      silent! ascii
      redir END

      if match(ascii, 'NUL') != -1
        return 'NUL'
      endif

      " Zero pad hex values
      let nrformat = '0x%02x'

      let encoding = (&fenc == '' ? &enc : &fenc)

      if encoding == 'utf-8'
        " Zero pad with 4 zeroes in unicode files
        let nrformat = '0x%04x'
      endif

      " Get the character and the numeric value from the return value of :ascii
      " This matches the two first pieces of the return value, e.g.
      " "<F>  70" => char: 'F', nr: '70'
      let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

      " Format the numeric value
      let nr = printf(nrformat, nr)

      return "'". char ."' ". nr
    endfunction
  endif
endif

"" Airline Settings
"" Powerline font を使用する
"if g:plug.is_installed("vim-airline")
"  let g:airline_powerline_fonts = 1
"  " tabline 設定
"  let g:airline#extensions#tabline#enabled = 1
"  " タブに何かしらの番号を表示する設定
"  let g:airline#extensions#tabline#show_tab_nr = 1
"  " タブ番号を表示する設定
"  let g:airline#extensions#tabline#tab_nr_type = 1
"  " タブ区切り設定
"  let g:airline#extensions#tabline#left_sep = ''
"  let g:airline#extensions#tabline#left_alt_sep = '|'
"  " branch 表示
"  let g:airline#extensions#branch#enabled = 1
"  " hunk 表示
"  let g:airline#extensions#hunks#enabled = 1
"endif
"" Powerline
"if g:plug.is_installed("powerline")
"  " Powerline Settings
"  let g:Powerline_symbols = 'fancy'
"  " let g:Powerline_symbols = 'compatible'
"  let g:Powerline_theme       ='solarized256'
"  let g:Powerline_colorscheme ='solarized256'
"  let g:Powerline_theme='short'
"  let g:Powerline_colorscheme='solarized256_dark'
"  " Python base powerline.
"  source ~/.local/lib/python2.7/site-packages/powerline/bindings/vim/plugin/powerline.vim
"  python from powerline.vim import setup as powerline_setup
"  python powerline_setup()
"  python del powerline_setup
"endif

" vim-gitgutter
if g:plug.is_installed("vim-gitgutter")
  " let g:gitgutter_git_executable = "PATH=/usr/bin winpty git"
  let g:gitgutter_map_keys = 0  " Not use gitgutter keymap
  let g:gitgutter_realtime = 0  " Not realtime
  let g:gitgutter_eager = 0     " Not realtime
  let g:gitgutter_sign_added = '+'
  let g:gitgutter_sign_modified = '='
  let g:gitgutter_sign_removed = '-'
endif

