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

" yank to remote
let g:y2r_config = {
    \   'tmp_file': '/tmp/exchange_file',
    \   'key_file': expand('$HOME') . '/.exchange.key',
    \   'host': 'localhost',
    \   'port': 52224,
    \ }
function! Yank2Remote()
    call writefile(split(@", '\n'), g:y2r_config.tmp_file, 'b')
    let s:params = ['cat %s %s | nc -w1 %s %s']
    for s:item in ['key_file', 'tmp_file', 'host', 'port']
        let s:params += [shellescape(g:y2r_config[s:item])]
    endfor
    let s:ret = system(call(function('printf'), s:params))
endfunction
nnoremap <silent> ,y :call Yank2Remote()<CR>

