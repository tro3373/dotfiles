" Indent Guide Settings
if !g:plug.is_installed("vaffle.vim")
  finish
endif

let g:vaffle_show_hidden_files=1

function! s:vaffle_get_current_path() abort
  " filerオブジェクトを取得
  let filer = vaffle#buffer#get_filer()
  " アイテムが空の場合は空文字を返す
  if empty(filer.items)
    return ''
  endif
  " カーソル行のアイテムインデックスを取得
  let lnum = line('.')
  let item_index = lnum - 1
  " 範囲チェック
  if item_index < 0 || item_index >= len(filer.items)
    return ''
  endif
  " カーソル位置のアイテムを取得してパスを返す
  let item = filer.items[item_index]
  return item.path
endfunction

function! s:vaffle_trash_file() abort
  " echo system('trash --no-color ' . shellescape(s:vaffle_get_current_path()))
  echo system('trash ' . shellescape(s:vaffle_get_current_path()))
  let l:pos = getpos('.')
  call vaffle#refresh()
  call setpos('.', l:pos)
endfunction

function! s:customize_vaffle_mappings() abort
  " Customize key mappings here
  " nmap <buffer> <Bslash> <Plug>(vaffle-open-root)
  " nmap <buffer> K        <Plug>(vaffle-mkdir)
  " nmap <buffer> N        <Plug>(vaffle-new-file)
  nmap <buffer> - <Plug>(vaffle-open-parent)
  nmap <buffer> T :call <SID>vaffle_trash_file()<CR>
  nmap <buffer> D :call <SID>vaffle_trash_file()<CR>
endfunction

augroup vimrc_vaffle
  autocmd!
  autocmd FileType vaffle call s:customize_vaffle_mappings()
augroup END
