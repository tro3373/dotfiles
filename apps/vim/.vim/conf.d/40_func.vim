"######################################################################
"   func.vim
"           ユーザ定義関数やマクロの定義をする
"######################################################################

" クリップボードレジスタの違い
" http://maijou2501.hateblo.jp/entry/20121016/1350403062
"
" 通常 * レジスタはクリップボードとなっている(macなど)
" が、ubuntu では + レジスタがクリップボードとなってる(ミソ)
" じゃあ両方にコピーすべし
function! CopyComm()
  let @+=@*
  echo "Copy!=> ".@*
endfunction
function! CopyPath()
  let @*=expand('%:P')
  call CopyComm()
endfunction
function! CopyFullPath()
  let @*=expand('%:p')
  call CopyComm()
endfunction
function! CopyFileName()
  let @*=expand('%:t:r')
  call CopyComm()
endfunction
function! CopyTimestamp()
  let @*=strftime('%Y-%m-%d %H:%M:%S')
  call CopyComm()
endfunction
function! CopyDate()
  let @*=strftime('%Y-%m-%d')
  call CopyComm()
endfunction
function! CopyTime()
  let @*=strftime('%H:%M:%S')
  call CopyComm()
endfunction
command! CopyPath      call CopyPath()
command! CopyFullPath  call CopyFullPath()
command! CopyFileName  call CopyFileName()
command! CopyTimestamp call CopyTimestamp()
command! CopyDate      call CopyDate()
command! CopyTime      call CopyTime()

function! Settings()
    :tabe $HOME/.vim/conf.d/50_mapping.vim
endfunction
command! Settings call Settings()

function! SetTabs(...)
    let num = 4
    if a:0 >= 1
        let num = a:1
    end
    let &tabstop=num
    let &softtabstop=num
    let &shiftwidth=num
endfunction
command! -nargs=? SetTab call SetTabs(<f-args>)

