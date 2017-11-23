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
set guioptions -=T
set viminfo+=n~/.vim/_viminfo

source ~/.vim/conf.d/20_colorscheme.vim

" 使用するフォントと大きさ
if (has("win64") || has("win32"))
    set guifont=Osaka-Mono:h13
    set guifontwide=Osaka-Mono:h13
else
    " set guifont=Ricty\ Discord\ for\ Powerline\ 10
    " set guifontwide=Ricty\ Discord\ for\ Powerline\ 10
    set guifont=Osaka-Mono\ 13
    set guifontwide=Osaka-Mono\ 13
endif

"if (has("win64") || has("win32"))
"    "set encoding=utf-8
"    set fileencoding=cp932
"    set fileencodings=utf-8,cp932
"endif
