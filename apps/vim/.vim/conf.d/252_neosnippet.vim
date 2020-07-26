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
  " --------------------------------------------------------
  " https://yuzuemon.hatenablog.com/entry/2015/01/15/035759
  " Json等のダブルクォーテーションの見た目をなくすなど
  " - concealcursor: カーソル行のテキストを Conceal表示するモードをセットする
  "   - n ノーマルモード
  "   - v ビジュアルモード
  "   - i 挿入モード
  "   - c コマンドライン編集
  " - conceallevel: レベル設定
  "   - 0 通常通り表示(デフォルト)
  "   - 1 conceal対象のテキストは代理文字(初期設定はスペース)に置換される
  "   - 2 conceal対象のテキストは非表示になる
  "   - 3 conceal対象のテキストは完全に非表示
  " --------------------------------------------------------
  " neosnippet に記載されている設定
  " >    set conceallevel=2 concealcursor=niv
  " >    set conceallevel=2 concealcursor=i
  " 以下の方が動作的には好ましいので変更してみる
  set conceallevel=1 concealcursor=
endif
