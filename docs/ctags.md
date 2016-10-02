- [vimの関数ジャンプのかゆいところをMakefileと.vimrcで解決する](http://at-grandpa.hatenablog.jp/entry/2015/10/28/224920)

```sh
[debian系]
sudo apt-get install exuberant-ctags

[CentOS/RedHat系]
yum install ctags

[mac]
brew install ctags
```
```Makefile
# ----------------------------------------------------
#  tagを生成する
# ----------------------------------------------------

# 言語
# see also `ctags --list-languages`
lang := PHP    \
        Ruby   \
        Python \
        Perl

lower_lang := $(shell echo $(lang) | tr A-Z a-z)

# 各言語のtag対象ファイルの拡張子
# see also `ctags --list-maps`
ext := default       \
       .rb.ruby.spec \
       default       \
       default

TARGET_PATH  = $(PWD)  # ここは基本的に書き換える
git_toplevel = $(shell cd $(TARGET_PATH);git rev-parse --show-toplevel)
seq          = $(shell seq 1 $(words $(lang)))

ifeq ($(git_toplevel),)
    # gitリポジトリ管理ではない場合
    tags_save_dir = $(realpath $(TARGET_PATH))/tags
    tags_target_dir = $(realpath $(TARGET_PATH))
else
    # gitリポジトリ管理である場合
    tags_save_dir = $(HOME)/dotfiles/tags_files/$(shell basename $(git_toplevel))
    tags_target_dir = $(git_toplevel)
endif

.PHONY: create_tags $(seq)

create_tags: $(seq)

$(seq):
  mkdir -p $(tags_save_dir)
  ctags -R \
      --languages=$(word $@,$(lang)) \
      --langmap=$(word $@,$(lang)):$(word $@,$(ext)) \
      -f $(tags_save_dir)/$(word $@,$(lower_lang))_tags $(tags_target_dir)
```

```sh
make -f /path/to/Makefile create_tags TARGET_PATH=./
```
```vimrc
" ファイルタイプ毎 & gitリポジトリ毎にtagsの読み込みpathを変える
function! ReadTags(type)
    try
        execute "set tags=".$HOME."/dotfiles/tags_files/".
              \ system("cd " . expand('%:p:h') . "; basename `git rev-parse --show-toplevel` | tr -d '\n'").
              \ "/" . a:type . "_tags"
    catch
        execute "set tags=./tags/" . a:type . "_tags;"
    endtry
endfunction

augroup TagsAutoCmd
    autocmd!
    autocmd BufEnter * :call ReadTags(&filetype)
augroup END



set notagbsearch

" [tag jump] カーソルの単語の定義先にジャンプ（複数候補はリスト表示）
nnoremap tj :exe("tjump ".expand('<cword>'))<CR>

" [tag back] tag stack を戻る -> tp(tag pop)よりもtbの方がしっくりきた
nnoremap tb :pop<CR>

" [tag next] tag stack を進む
nnoremap tn :tag<CR>

" [tag vertical] 縦にウィンドウを分割してジャンプ
nnoremap tv :vsp<CR> :exe("tjump ".expand('<cword>'))<CR>

" [tag horizon] 横にウィンドウを分割してジャンプ
nnoremap th :split<CR> :exe("tjump ".expand('<cword>'))<CR>

" [tag tab] 新しいタブでジャンプ
nnoremap tt :tab sp<CR> :exe("tjump ".expand('<cword>'))<CR>

" [tags list] tag list を表示
nnoremap tl :ts<CR>
```
