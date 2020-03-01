if !g:plug.is_installed("neosnippet")
  finish
endif

"=============================================
" neosnippet 設定
" http://rcmdnk.github.io/blog/2015/01/12/computer-vim/
" http://kazuph.hateblo.jp/entry/2012/11/28/105633
"=============================================

imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
" honza/vim-snippets 等、元々snipmate用等に作られた物との互換性を上げるための設定
let g:neosnippet#enable_snipmate_compatibility = 1
" my-snippets
"   => .vim/snippets
" Shougo/neosnippet-snippets
" honza/vim-snippets
"  => target langs
"       actionscript apache autoit c chef clojure cmake coffee cpp cs css
"       dart diff django erlang eruby falcon go haml haskell html htmldjango
"       htmltornado java javascript-jquery javascript jsp ledger lua make
"       mako markdown objc perl php plsql po processing progress puppet
"       python r rst ruby sh snippets sql tcl tex textile vim xslt yii-chtml yii zsh
let g:neosnippet#snippets_directory = '~/.vim/snippets,~/.vim/plugged/vim-snippets/snippets,~/.vim/plugged/neosnippet-snippets/neosnippets'

" Disabled because TAB expand current select row as select it
" SuperTab like snippets behavior.
" imap <expr><TAB> neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
" smap <expr><TAB> neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif
