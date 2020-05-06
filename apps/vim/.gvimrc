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
:set guioptions -=m
" Removes the toolbar.
set guioptions -=T
set viminfo+=n~/.vim/_viminfo

source ~/.vim/conf.d/100_colorscheme.vim

" 使用するフォントと大きさ
if (has("win64") || has("win32"))
    set guifont="HackGen Console":h13
    set guifontwide="HackGen Console":h13
else
    " set guifont=Ricty\ Discord\ for\ Powerline\ 10
    " set guifontwide=Ricty\ Discord\ for\ Powerline\ 10
    set guifont="HackGen Console"\ 13
    set guifontwide="HackGen Console"\ 13
endif

"if (has("win64") || has("win32"))
"    "set encoding=utf-8
"    set fileencoding=cp932
"    set fileencodings=utf-8,cp932
"endif

let g:save_window_file = expand('~/.vimwinpos')
augroup SaveWindow
  autocmd!
  autocmd VimLeavePre * call s:save_window()
  function! s:save_window()
    let options = [
      \ 'set columns=' . &columns,
      \ 'set lines=' . &lines,
      \ 'winpos ' . getwinposx() . ' ' . getwinposy(),
      \ ]
    call writefile(options, g:save_window_file)
  endfunction
augroup END

if filereadable(g:save_window_file)
  execute 'source' g:save_window_file
endif

