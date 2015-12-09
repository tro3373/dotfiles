"######################################################################
"   view.vim
"           見た目の設定
"           Vimの外観や見た目の表示方法に関する設定を行う
"           カラースキームや色定義に関する設定は別途 color.vim で行う
"######################################################################

" 使用するフォントと大きさ
" set guifont=Ricty\ Discord\ for\ Powerline\ 10
" set guifontwide=Ricty\ Discord\ for\ Powerline\ 10
set guifont=OsakaForPowerline-Mono:10
set guifontwide=OsakaForPowerline-Mono:10


" 行番号を表示する
set number
" ルーラを表示
set ruler
" カーソルラインを表示
set cursorline
" 閉じ括弧が入力されたとき、対応する括弧を表示する
set showmatch
" スクロールした際に余白が５行分残るようにする
set scrolloff=5
" ターミナル接続を高速にする
set ttyfast
" Unicodeで行末が変になる問題を解決
set ambiwidth=double


" 全角スペースを分かりやすく表示する
highlight ZenkakuSpace cterm=underline ctermfg=lightmagenta guibg=lightmagenta
match ZenkakuSpace /　/
" TAB文字/行末の半角スペースを表示する
set lcs=tab:>\ ,trail:_,extends:\
set list
highlight SpecialKey cterm=NONE ctermfg=cyan guifg=cyan


" ステータスラインの表示変更
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}:%{&fenc!=''?&fenc:&enc}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
" Always display the statusline in all windows
set laststatus=2
" Always display the tabline, even if there is only one tab
set showtabline=2
" Hide the default mode text (e.g. -- INSERT -- below the statusline)
set noshowmode


" Powerline Settings
let g:Powerline_symbols = 'fancy'
"let g:Powerline_symbols = 'compatible'
source ~/.local/lib/python2.7/site-packages/powerline/bindings/vim/plugin/powerline.vim
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup


" Indent Guide Settings
set ts=4 sw=4 et
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1
let g:indent_guides_auto_colors=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=black
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=darkgrey

