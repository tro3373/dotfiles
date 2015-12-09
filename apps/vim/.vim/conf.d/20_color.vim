"######################################################################
"   color.vim
"           カラースキーム、色定義に関する設定を行う
"######################################################################


" ターミナル環境用に256色を使えるようにする
set t_Co=256
if &term == 'screen-256color'
    " 背景の塗り潰しは行わない
    set t_ut=
endif

" シンタックスハイライトを有効にする
syntax enable

" Molokai
" colorscheme molokai

" Solarized
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1
" set background=dark
" colorscheme solarized

" TomorrowNight
colorscheme Tomorrow-Night

