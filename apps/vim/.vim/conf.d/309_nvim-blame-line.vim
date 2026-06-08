if !g:plug.is_installed("nvim-blame-line")
  finish
endif

" nnoremap <silent> <leader>b :ToggleBlameLine<CR>
" NOTE: 標準の EnableBlameLine は CursorMoved 毎(plugin 内部 70ms デバウンス)に
" git blame を実行するため、スクロール中にもたつく。自前で長め(250ms)に
" デバウンスし、移動中は即クリア・停止後に 1 回だけ表示する。git は停止後 1 回。
" b:onCursorMoved は plugin が BufReadPre で各バッファに設定する表示 handler。
" git 管理外ファイルでは b:onCursorMoved がエラーハンドラ({-> DisableBlameLine()})
" になり、DisableBlameLine が未作成の augroup showBlameLine を掃除して E216 を出す。
" 空で事前宣言して回避する。
augroup showBlameLine
  autocmd!
augroup END

let s:blame_ns = (has('nvim') && has('nvim-0.3.4')) ? nvim_create_namespace('nvim-blame-line') : 0
let s:blame_timer = -1

function! s:BlameClear() abort
  if s:blame_ns
    call nvim_buf_clear_namespace(0, s:blame_ns, 0, -1)
  endif
endfunction

function! s:BlameFire() abort
  let s:blame_timer = -1
  if &buftype ==# '' && !empty(expand('%')) && exists('*b:onCursorMoved')
    call b:onCursorMoved(line('.'))
  endif
endfunction

function! s:BlameOnMove() abort
  if s:blame_timer != -1
    call timer_stop(s:blame_timer)
  endif
  call s:BlameClear()
  let s:blame_timer = timer_start(250, {-> s:BlameFire()})
endfunction

augroup blame_idle
  autocmd!
  autocmd CursorMoved * call s:BlameOnMove()
augroup END

" " Show blame info below the statusline instead of using virtual text
" let g:blameLineUseVirtualText = 0
"
" " Specify the highlight group used for the virtual text ('Comment' by default)
" let g:blameLineVirtualTextHighlight = 'Question'
"
" " Change format of virtual text ('%s' by default)
" let g:blameLineVirtualTextFormat = '/* %s */'
"
" " Customize format for git blame (Default format: '%an | %ar | %s')
" let g:blameLineGitFormat = '%an - %s'
" " Refer to 'git-show --format=' man pages for format options)
"
" " Change message when content is not committed
" let g:blameLineMessageWhenNotYetCommited = ''
