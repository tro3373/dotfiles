" " ${HOME}/.vim/conf.d/ 以下にある *.vim(分割された設定ファイル) を全て適用
" set runtimepath+=$HOME/.vim/
" runtime! conf.d/*.vim

" MacVim付属のgvimrcで、独自のmacvimと名付けられたカラースキームを勝手に読むのを防ぐ
let g:macvim_skip_colorscheme=1
let g:no_gvimrc_example=1
let g:no_vimrc_example=1
" デフォルトプラグインを無効化
let g:loaded_gzip               = 1
let g:loaded_tar                = 1
let g:loaded_tarPlugin          = 1
let g:loaded_zip                = 1
let g:loaded_zipPlugin          = 1
let g:loaded_rrhelper           = 1
let g:loaded_vimball            = 1
let g:loaded_vimballPlugin      = 1
let g:loaded_getscript          = 1
let g:loaded_getscriptPlugin    = 1
" netrw系を無効化
" let g:loaded_netrw              = 1
" let g:loaded_netrwPlugin        = 1
" let g:loaded_netrwSettings      = 1
" let g:loaded_netrwFileHandlers  = 1

" GVim `set guioptions-=m` 設定時の起動高速化
" https://twitter.com/mattn_jp/status/467518829447245825
let g:did_install_default_menus = 1
let g:did_install_syntax_menu   = 1
" Windows使用時、mswin.vimが読み込まれて、キーバインドを変更されることを防ぐ
" https://vi.stackexchange.com/questions/16713/revert-effect-of-source-vimruntime-mswin-vim/16714
let g:skip_loading_mswin        = 1
let g:loaded_2html_plugin       = 1

" let g:mapleader = '\'
" let g:maplocalleader = ','

" " git commit 時にはプラグインは読み込まない
" if $HOME != $USERPROFILE && $GIT_EXEC_PATH != ''
"   finish
" end

" 各種設定の読み込み
call map(sort(split(globpath(&runtimepath, 'conf.d/*.vim'))), {->[execute('exec "so" v:val')]})
