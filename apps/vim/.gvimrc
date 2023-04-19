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
set guioptions-=a

source ~/.vim/conf.d/200_colorscheme.vim

" 使用するフォントと大きさ
" set guifont=HackGen\ Console:h13
" set guifontwide=HackGen\ Console:h13
" set guifont=UDEV\ Gothic\ JPDOC:h13
" set guifontwide=UDEV\ Gothic\ JPDOC:h13
if (has("gui_gtk2") || has("gui_gtk3"))
  set guifont=Osaka-Mono\ 13
  set guifontwide=Osaka-Mono\ 13
else
  set guifont=Osaka-Mono:h13
  set guifontwide=Osaka-Mono:h13
endif
if &encoding == 'utf-8'
  set ambiwidth=double
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
