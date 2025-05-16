if !g:plug.is_installed('sqls.vim')
  finish
endif

function! SqlsExecuteCurrent()
  let lnum = line('.')
  let first = lnum
  let last = lnum
  let max = line('$')
  " 上方向探索
  for i in range(lnum-1, 1, -1)
    let lineval = getline(i)
    if lineval =~ '^\s*$'
      let first = i + 1
      break
    endif
    let first = i
  endfor
  " 下方向探索（空行まで）
  for i in range(lnum+1, max)
    let lineval = getline(i)
    if lineval =~ '^\s*$'
      let last = i - 1
      break
    endif
    let last = i
  endfor
  " execute first..','..last..' SqlsExecuteQuery' " NotWork.
  " exe ':'..first..','..last.' SqlsExecuteQuery' " NotWork.

  " 範囲をビジュアルライン選択. 不要だが、ビジュアル的にわかりやすい？ので選択しておく。
  execute first . 'normal! V' . (last - first) . 'j'
  " " コマンド実行 NotWork.選択実行は動かなかった
  " execute 'SqlsExecuteQuery'
  " 選択解除 解除する場合
  " normal! <Esc>

  " 範囲マークをセット
  call setpos("'<", [bufnr('%'), first, 1, 0])
  call setpos("'>", [bufnr('%'), last, 1, 0])
  " 範囲指定でコマンド実行
  execute "'<,'>SqlsExecuteQuery"

endfunction

augroup lsp_sqls_leader_r
  autocmd!
  " \ execute 'nnoremap <buffer> <Leader>r :SqlsExecuteQuery<CR>' |
  autocmd User lsp_buffer_enabled if &filetype ==# 'sql' && index(lsp#get_allowed_servers(), 'sqls') >= 0 |
    \ execute 'vnoremap <buffer> <Leader>r :SqlsExecuteQuery<CR>' |
    \ execute 'nnoremap <buffer> <Leader>r :call SqlsExecuteCurrent()<CR>' |
    \ endif
augroup END
