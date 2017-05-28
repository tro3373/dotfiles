"######################################################################
" .gvimrc
"       gVim用の設定ファイル (.gvimrcの適用後に適用される)
"       gVimを使用する場合だけ有効にしたい設定のみ記述する
"######################################################################

" 起動時のウィンドウの大きさ
set lines=65 columns=150

" メニューの文字が文字化けしないようにする
source $VIMRUNTIME/delmenu.vim
set langmenu=ja_jp.utf-8
source $VIMRUNTIME/menu.vim
" Removes the menubar.
" :set guioptions -=m
" Removes the toolbar.
:set guioptions -=T

source $VIMRUNTIME/conf.d/31_colorscheme.vim

" " カラーテーマ設定
" if 0 && g:plug.is_installed("vim-colors-solarized")
"     " ==> Solarized
"     " let g:solarized_termcolors=256
"     let g:solarized_termtrans=1
"     set background=dark
"     colorscheme solarized
" elseif 1 && g:plug.is_installed("vim-hybrid")
"     " ==> hybrid
"     set background=dark
"     colorscheme hybrid
" elseif g:plug.is_installed("vim-tomorrow-theme")
"     " ==> TomorrowNight
"     " colorscheme Tomorrow
"     " colorscheme Tomorrow-Night-Bright
"     " colorscheme Tomorrow-Night-Eighties
"     colorscheme Tomorrow-Night
" elseif g:plug.is_installed("molokai")
"     " ==> Molokai
"     colorscheme molokai
" endif
"
" " 使用するフォントと大きさ
" if (has("win64") || has("win32"))
"     set guifont=Osaka-Mono:h13
"     set guifontwide=Osaka-Mono:h13
" else
"     " set guifont=Ricty\ Discord\ for\ Powerline\ 10
"     " set guifontwide=Ricty\ Discord\ for\ Powerline\ 10
"     set guifont=Osaka-Mono\ 13
"     set guifontwide=Osaka-Mono\ 13
" endif

"if (has("win64") || has("win32"))
"    "set encoding=utf-8
"    set fileencoding=cp932
"    set fileencodings=utf-8,cp932
"endif
