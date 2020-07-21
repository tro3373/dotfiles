if !g:plug.is_installed("ctrlp.vim")
  finish
endif

" let g:ctrlp_map='<c-p>'
let g:ctrlp_map='<Leader>o'
let g:ctrlp_cmd = 'CtrlPMRU'

" let g:ctrlp_max_height          = 90          " CtrlPのウィンドウ最大高さ(match_windowに統合)
let g:ctrlp_match_window        = 'bottom,order:btt,min:1,max:30,results:100'
let g:ctrlp_max_files           = 100000      " 対象ファイル最大数(default:10000)
let g:ctrlp_max_depth           = 10          " 検索対象の最大階層数(default:40)
let g:ctrlp_by_filename         = 0           " フルパスではなくファイル名のみで絞込み
let g:ctrlp_jump_to_buffer      = 0           " 0:disable, 2:タブで開かれていた場合はそのタブに切り替える
let g:ctrlp_mruf_max            = 500         " MRUの最大記録数
let g:ctrlp_highlight_match     = [1, 'IncSearch'] " 絞り込みで一致した部分のハイライト
let g:ctrlp_open_new_file       = 1           " 新規ファイル作成時にタブで開く
let g:ctrlp_open_multi          = '10t'       " 複数ファイルを開く時にタブで最大10まで開く
let g:ctrlp_lazy_update         = 1           " 遅延再描画
let g:ctrlp_working_path_mode   = 'ra'        " Guess vcs root dir
let g:ctrlp_root_markers        = ['Gemfile', 'pom.xml', 'build.xml'] " ルートパスと認識させるためのファイル
let g:ctrlp_extensions          = ['mru', 'mixed', 'line', 'funky', 'quickfix', 'tag', 'dir']
let g:ctrlp_cache_dir           = $HOME.'/.cache/ctrlp' " キャッシュディレクトリ (CtrlPを起動して F5 でキャッシュ更新)
" let g:ctrlp_clear_cache_on_exit = 0           " キャッシュを終了時に削除しない
" 無視するディレクトリ
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
if g:is_windows
  set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe
else
  set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.exe
endif
if executable('ag')
  let g:ctrlp_use_caching = 0
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
elseif g:is_windows
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'dir %s /-n /b /s /a-d' ]
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
endif

" Funky
let g:ctrlp_funky_matchtype = 'path'
let g:ctrlp_funky_syntax_highlight = 1
" http://mattn.kaoriya.net/software/vim/20111228013428.htm
" ~/.vim/dict/migemo-dict に辞書ファイルを置く必要がある
" let g:ctrlp_use_migemo          = 1       " 日本語ファイル名対応

if !g:is_windows
  if g:plug.is_installed("cpsm")
    let g:ctrlp_match_func = {'match': 'cpsm#CtrlPMatch'}
  endif
endif

" CtrlP console mapping
let g:ctrlp_prompt_mappings = {
    \ 'PrtBS()': ['<c-h>', '<bs>'],
    \ 'PrtCurLeft()': ['<left>'],
    \ 'AcceptSelection("e")': ['<Space>', '<cr>', '<2-LeftMouse>'],
    \ }
nnoremap <Leader>p :CtrlPMRU<CR>
" nnoremap <Leader>m :CtrlPMixed<CR>
" nnoremap <Leader>j :CtrlPDir %:h<CR>
" nnoremap <Leader>k :CtrlPFunky<Cr>
" nnoremap <Leader>l :CtrlPLine<CR>
" nnoremap <Leader>; :CtrlPYankring<CR>
" nnoremap <Leader>: :CtrlPCmdline<CR>
" nnoremap <Leader>@ :CtrlPBuffer<CR>
" nnoremap <Leader>: :CtrlPFiler<CR>
" narrow the list down with a word under cursor
" nnoremap <Leader>@@ :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
" カーソル配下の文字で CtrlP 検索
" map <Leader>o <C-P><C-\>w
" map <F3> <C-P><C-\>w
nnoremap st <Nop>
nnoremap st :<C-u>tabnew<CR>:CtrlPMRU<CR>
