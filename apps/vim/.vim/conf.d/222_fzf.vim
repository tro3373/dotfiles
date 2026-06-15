if !executable('fzf')
  finish
endif

if !g:plug.is_installed("fzf.vim")
  finish
endif

" option に関しては、以下が詳しい
"   https://github.com/junegunn/fzf/wiki
"   http://koturn.hatenablog.com/entry/2015/11/26/000000
" nnoremap ,l :FZF .<CR>
" vnoremap ,l y:FZF -q <C-R>"<CR>
" nnoremap ,j :FZF -q <C-R><C-W>
" vnoremap ,j y:FZF -q <C-R>"


let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:50%' --preview 'bat --color=always --style=header,grid --line-range :500 {}'"

" ウィンドウサイズ変更したい場合
let g:fzf_layout = { 'window': { 'width': 1.0, 'height': 1.0, 'yoffset': 0.5, 'xoffset': 0.5, 'border': 'sharp' } }

" 【解説】開発ライブ実況 #1 (Vim / Go) 編 by メルペイ Architect チーム Backend エンジニア #mercari_codecast | メルカリエンジニアリング
" https://engineering.mercari.com/blog/entry/mercari_codecast_1/
function! s:find_rip_grep(q, d) abort
  let l:target_dir = a:d
  if a:d == ''
    let l:target_dir = GetGitRoot()
  endif
  " fzf#vim#with_preview で ctrl+h/l で左右するようにできないか？
  call fzf#vim#grep(
      \   'rg --ignore-file ~/.vim/.rgignore_for_go --glob "!.git/" --column --line-number --no-heading --hidden --smart-case "'.a:q.'" '.l:target_dir,
      \   1,
      \   fzf#vim#with_preview({'options': '--query="' . a:q . '" --delimiter : --nth 4..'}, 'down:50%', '?'),
      \   0,
      \)
endfunction
nnoremap <silent> <Leader>g :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), '')<CR>
" nnoremap <silent> <Leader>G :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>G :<C-u>silent call <SID>find_rip_grep(expand('<cword>'), getcwd())<CR>
vnoremap <silent> <Leader>g "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), '')<CR>
" vnoremap <silent> <Leader>G "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), expand('%:p:h'))<CR>
vnoremap <silent> <Leader>G "zy:<C-u>silent call <SID>find_rip_grep(expand(@z), getcwd())<CR>

function! s:find_rip_grep_fuzzy(q, d) abort
  let l:target_dir = a:d
  if a:d == ''
    let l:target_dir = GetGitRoot()
  endif
  call fzf#vim#grep(
      \   'rg --ignore-file ~/.vim/.rgignore --glob "!.git/" --column --line-number --no-heading --hidden --smart-case "'.a:q.'" '.l:target_dir,
      \   1,
      \   fzf#vim#with_preview({'options': '--query="' . a:q . '" --delimiter : --nth 4..'}, 'down:50%', '?'),
      \   0,
      \)
endfunction
nnoremap <silent> <Leader>f :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), '')<CR>
" nnoremap <silent> <Leader>F :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>F :<C-u>silent call <SID>find_rip_grep_fuzzy(expand('<cword>'), getcwd())<CR>
vnoremap <silent> <Leader>f "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), '')<CR>
" vnoremap <silent> <Leader>F "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), expand('%:p:h'))<CR>
vnoremap <silent> <Leader>F "zy:<C-u>silent call <SID>find_rip_grep_fuzzy(expand(@z), getcwd())<CR>

function! s:find_rip_grep_files(q, d) abort
  let l:target_dir = a:d
  if a:d == ''
    let l:target_dir = GetGitRoot()
  endif
  " 選択した(Enter)ファイルをデフォルトで新しいタブで開く。
  " fzf#vim#files は内部で g:fzf_action を参照してキー別アクションを決めるため、
  " ここで一時的に 'enter' を追加して上書きする。
  " 'tab split' は Ctrl-t と同じ挙動(新タブで開く)。Ctrl-t/x/v の既存設定は extend で温存。
  let l:original_action = get(g:, 'fzf_action', {})
  let g:fzf_action = extend(copy(l:original_action), {'enter': 'tab split'})
  " アクションは fzf#vim#files 呼び出し時に同期的にキャプチャされるため、
  " 呼び出し直後に g:fzf_action を元へ戻しても選択時の挙動は変わらない。
  " finally で復元することで他の fzf コマンドへ影響を残さない。
  try
    " source を rg の更新日時降順に差し替え、最近更新したファイルを上位に出す。
    " '--sortr modified' = 新しい順。dir 指定で target_dir 配下を相対パス列挙する。
    :call fzf#vim#files(l:target_dir, {'source': 'rg --files --sortr modified', 'options': ['--query=' . a:q, '--info=inline']})
  finally
    let g:fzf_action = l:original_action
  endtry
endfunction
" nnoremap <silent> <Leader>; :<C-u>silent call <SID>find_rip_grep_files(expand('<cword>'), '')<CR>
" nnoremap <silent> <Leader>: :<C-u>silent call <SID>find_rip_grep_files(expand('<cword>'), expand('%:p:h'))<CR>
nnoremap <silent> <Leader>l :<C-u>silent call <SID>find_rip_grep_files('', '')<CR>
nnoremap <silent> <Leader>L :<C-u>silent call <SID>find_rip_grep_files('', expand('%:p:h'))<CR>

" :History(MRU) を、cwd 配下のファイルを先頭へ寄せて表示する。
" fzf には特定項目だけ上位ブーストする機能が無いため、独自に source を組み立てる。
" fzf#vim#_recent_files() は :History と同じソース([現在ファイル]+[開いている
" バッファ]+[oldfiles] を uniq した :~:. 表示パス)。:~:. は cwd 配下のみ相対
" パスになるため、先頭が ~ or / でないものを cwd 配下と判定し前方へ寄せる
" (各グループ内の MRU 順は維持する安定パーティション)。
function! s:history_cwd_first() abort
  let l:files = fzf#vim#_recent_files()
  let l:under = filter(copy(l:files), 'v:val !~# "^[~/]"')
  let l:other = filter(copy(l:files), 'v:val =~# "^[~/]"')
  call fzf#run(fzf#wrap('history-cwd-first',
        \ fzf#vim#with_preview({
        \   'source':  l:under + l:other,
        \   'options': ['-m', '--prompt', 'Hist> ', '--info=inline'],
        \ }), 0))
endfunction

" st: 新規タブで MRU(最近使ったファイル)を開く。
" 旧 ctrlp 環境(vim)では 220_ctrlp.vim.vim の `st`(CtrlPMRU)を温存し、
" ctrlp を廃止した環境(nvim)でのみ cwd 優先 History へ再割当する。
if !g:plug.is_installed('ctrlp.vim')
  nnoremap <silent> st :<C-u>tabnew<CR>:call <SID>history_cwd_first()<CR>
  nnoremap <silent> <Leader>p :<C-u>tabnew<CR>:call <SID>history_cwd_first()<CR>
endif
