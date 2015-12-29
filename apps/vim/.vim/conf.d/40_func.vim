"######################################################################
"   func.vim
"           ユーザ定義関数やマクロの定義をする
"######################################################################

function! CopyPath()
  let @*=expand('%:P')
endfunction

function! CopyFullPath()
  let @*=expand('%:p')
endfunction

function! CopyFileName()
  let @*=expand('%:t')
endfunction

command! CopyPath     call CopyPath()
command! CopyFullPath call CopyFullPath()
command! CopyFileName call CopyFileName()

" yank to remote
let g:y2r_config = {
            \   'tmp_file': '/tmp/exchange_file',
            \   'key_file': expand('$HOME') . '/.exchange.key',
            \   'host': 'localhost',
            \   'port': 52224,
            \}
function! Yank2Remote()
    call writefile(split(@", '\n'), g:y2r_config.tmp_file, 'b')
    let s:params = ['cat %s %s | nc -w1 %s %s']
    for s:item in ['key_file', 'tmp_file', 'host', 'port']
        let s:params += [shellescape(g:y2r_config[s:item])]
    endfor
    let s:ret = system(call(function('printf'), s:params))
endfunction
nnoremap <silent> ,y :call Yank2Remote()<CR>

