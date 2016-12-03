"######################################################################
" .vimrc
"       Mac/Linux Vim用の設定ファイル (gVim用の設定は .gvimrc で行う)
"       分割された設定ファイル群(${HOME}/.vim/conf.d/*.vim)で設定を行う
"
"######################################################################

" ${HOME}/.vim/conf.d/ 以下にある *.vim(分割された設定ファイル) を全て適用
set runtimepath+=$HOME/.vim/
runtime! conf.d/*.vim

