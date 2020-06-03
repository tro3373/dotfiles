if !executable('ctags')
  finish
endif

" ctags 設定
" set tags+=./tags;
" set tags=./tags,./TAGS,tags,TAGS " original?
" set tags=./tags;./.git/tags;
set tags=**1/.git/tags;./.git/tags;./tags;

map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <Leader><C-\> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
