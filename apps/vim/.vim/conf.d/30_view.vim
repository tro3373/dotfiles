"######################################################################
"   view.vim
"           見た目の設定
"           Vimの外観や見た目の表示方法に関する設定を行う
"######################################################################

" 行番号を表示する
set number
" ルーラを表示
set ruler
" カーソルラインを表示
set cursorline
" 列を強調表示
set cursorcolumn
" 80 に縦 Line
" set colorcolumn=80
" 81 文字より後ろの色を変える
" let &colorcolumn=join(range(81,999),",")
" 80 に縦 Line 120 文字より後ろの色を変える
let &colorcolumn="80,".join(range(120,999),",")
" hi=highlight
" hi ColorColumn ctermbg=lightblue guibg=lightblue
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
    set ts=4 sw=4 et
    let g:indent_guides_enable_on_vim_startup=1
    let g:indent_guides_start_level=2
    let g:indent_guides_guide_size=1
    let g:indent_guides_auto_colors=0
    " autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=black
    " autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=darkgrey
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=234
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=236
endif


" ターミナル環境用に256色を使えるようにする
set t_Co=256
if &term == 'screen-256color'
    " 背景の塗り潰しは行わない
    set t_ut=
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


" カラーテーマ設定
if 1 && g:plug.is_installed("vim-hybrid")
    " ==> hybrid
    set background=dark
    colorscheme hybrid
elseif g:plug.is_installed("vim-colors-solarized")
    " ==> Solarized
    " let g:solarized_termcolors=256
    let g:solarized_termtrans=1
    set background=dark
    colorscheme solarized
elseif g:plug.is_installed("vim-tomorrow-theme")
    " ==> TomorrowNight
    " colorscheme Tomorrow
    " colorscheme Tomorrow-Night-Bright
    " colorscheme Tomorrow-Night-Eighties
    colorscheme Tomorrow-Night
elseif g:plug.is_installed("molokai")
    " ==> Molokai
    colorscheme molokai
endif

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
        \         ['fugitive', 'gitgutter', 'filename'],
        \       ],
        \       'right': [
        \         ['lineinfo', 'syntastic'],
        \         ['percent'],
        \         ['charcode', 'fileformat', 'fileencoding', 'filetype'],
        \       ]
        \     },
        \     'component_function': {
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
"    let g:airline_powerline_fonts = 1
"    " tabline 設定
"    let g:airline#extensions#tabline#enabled = 1
"    " タブに何かしらの番号を表示する設定
"    let g:airline#extensions#tabline#show_tab_nr = 1
"    " タブ番号を表示する設定
"    let g:airline#extensions#tabline#tab_nr_type = 1
"    " タブ区切り設定
"    let g:airline#extensions#tabline#left_sep = ''
"    let g:airline#extensions#tabline#left_alt_sep = '|'
"    " branch 表示
"    let g:airline#extensions#branch#enabled = 1
"    " hunk 表示
"    let g:airline#extensions#hunks#enabled = 1
"endif
"" Powerline
"if g:plug.is_installed("powerline")
"    " Powerline Settings
"    let g:Powerline_symbols = 'fancy'
"    " let g:Powerline_symbols = 'compatible'
"    let g:Powerline_theme       ='solarized256'
"    let g:Powerline_colorscheme ='solarized256'
"    let g:Powerline_theme='short'
"    let g:Powerline_colorscheme='solarized256_dark'
"    " Python base powerline.
"    source ~/.local/lib/python2.7/site-packages/powerline/bindings/vim/plugin/powerline.vim
"    python from powerline.vim import setup as powerline_setup
"    python powerline_setup()
"    python del powerline_setup
"endif

" vim-gitgutter
if g:plug.is_installed("lightline.vim")
    " let g:gitgutter_sign_added = '✚'
    " let g:gitgutter_sign_modified = '➜'
    " let g:gitgutter_sign_removed = '✘'
endif



