" .vimrcを再読み込みする
command! Reloadvimrc source $MYVIMRC

" private関数

" Ubuntu 判定
function! IsUbuntu() abort
  if filereadable("/etc/debian_version") || filereadable("/etc/debian_release")
    if filereadable("/etc/lsb-release")
      return 1
    endif
  endif
  return 0
endfun

" dotpath を応答する
function! GetDotDir()
  let tmp = $DOTPATH
  if tmp == ""
    let tmp = expand('~/.dot')
    if !isdirectory(tmp)
      echo "No DOTPATH variable and No ~/.dot directory exist."
      throw "error"
    endif
  endif
  return tmp
endfunction

" GitRoot取得
function! GetGitRoot() abort
  try
    let l:result = system("cd " . expand('%:p:h') . " && git rev-parse --is-inside-work-tree")
    let l:result = substitute(l:result, '\(\r\|\n\)\+', '', 'g')
    let l:isgitrepo = matchstr(l:result, "true")
    if l:isgitrepo == "true"
      let l:gitroot = system("cd " . expand('%:p:h') . " && git rev-parse --show-toplevel")
      return substitute(l:gitroot, '\(\r\|\n\)\+', '', 'g')
    else
      return "."
    endif
  catch
  endtry
endfunction

function! GitRoot() abort
  echo GetGitRoot()
endfunction
command! GitRoot call GitRoot()

" Clipboadの値取得
function! GetClipboad() abort
  let l:result = ""
  try
    if IsUbuntu()
      let l:result = @"
    else
      let l:result = @+
    endif
  catch
  endtry
  return l:result
endfunction

" c_CTRL-X
" Input current buffer's directory on command line.
" Kaoriya flavor
cnoremap <C-X> <C-R>=<SID>GetBufferDirectory()<CR>
function! s:GetBufferDirectory()
  let path = expand('%:p:h')
  let cwd = getcwd()
  let dir = '.'
  if match(path, escape(cwd, '\')) != 0
  let dir = path
  elseif strlen(path) > strlen(cwd)
  let dir = strpart(path, strlen(cwd) + 1)
  endif
  return dir . (exists('+shellslash') && !&shellslash ? '\' : '/')
endfunction

" public 関数

" クリップボードレジスタの違い
" http://maijou2501.hateblo.jp/entry/20121016/1350403062
"
" 通常 * レジスタはクリップボードとなっている(macなど)
" が、ubuntu では + レジスタがクリップボードとなってる(ミソ)
" じゃあ両方にコピーすべし
function! ClipComm()
  let @+=@*
  if g:is_wsl && executable(g:winclip)
    call system(g:winclip, @*)
  endif
  echo "Clip!=> ".@*
endfunction
function! ClipDir()
  let @*=expand('%:h')
  call ClipComm()
endfunction
function! ClipPath()
  let @*=expand('%:P')
  call ClipComm()
endfunction
function! ClipFullPath()
  let @*=expand('%:p')
  call ClipComm()
endfunction
function! ClipFileName()
  let @*=expand('%:t')
  call ClipComm()
endfunction
function! ClipFileNameNoExt()
  let @*=expand('%:t:r')
  call ClipComm()
endfunction
function! ClipTimestamp()
  let @*=strftime('%Y-%m-%d %H:%M:%S')
  call ClipComm()
endfunction
function! ClipDate()
  let @*=strftime('%Y-%m-%d')
  call ClipComm()
endfunction
function! ClipTime()
  let @*=strftime('%H:%M:%S')
  call ClipComm()
endfunction
function! ShowPath()
  echo expand('%:p')
endfunction
command! ClipDir        call ClipDir()
command! ClipPath       call ClipPath()
command! Clip           call ClipFullPath()
command! ClipFullPath   call ClipFullPath()
command! ClipFileName   call ClipFileName()
command! ClipTimestamp  call ClipTimestamp()
command! ClipDate       call ClipDate()
command! ClipTime       call ClipTime()
command! ShowPath       call ShowPath()
command! CopyDir        call ClipDir()
command! CopyPath       call ClipPath()
command! Copy           call ClipFullPath()
command! CopyFullPath   call ClipFullPath()
command! CopyFileName   call ClipFileName()
command! CopyTimestamp  call ClipTimestamp()
command! CopyDate       call ClipDate()
command! CopyTime       call ClipTime()



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

function! Ctags() abort
  " set encoding=cp932
  " set encoding=utf-8
  if !executable('git')
    echo "No git"
    return
  endif
  if !executable('ctags')
    echo "No ctags"
    return
  endif
  let l:gitroot = GetGitRoot()
  if g:is_windows
    let l:ctags = "ctags"
  else
    let l:ctags = substitute(system("which ctags"), '\(\r\|\n\)\+', '', 'g')
  endif
  let l:tags = l:gitroot . "/.git/tags"
  let l:execmd = l:ctags . " --tag-relative --recurse --sort=yes --append=no -f " . l:gitroot . "/.git/tags " . l:gitroot
  " `execute system` は同期的に実行される
  " `call system` は非同期的に実行される
  execute system(l:execmd)
  echo "Tags file Created to " . l:gitroot . "/.git/tags"
endfunction
command! Ctags call Ctags()

" function! HugoHelperFrontMatterReorder()
"   exe 'g/^draft/m 1'
"   exe 'g/^date/m 2'
"   exe 'g/^lastmod/m 3'
"   exe 'g/^title/m 4'
"   exe 'g/^slug/m 5'
"   exe 'g/^description/m 6'
"   exe 'g/^tags/m 6'
"   exe 'g/^categories/m 7'
"   " " create date taxonomy
"   " exe 'g/^date/co 8'
"   " exe ':9'
"   " exe ':s/.*\(\d\{4\}\)-\(\d\{2\}\).*/\1 = ["\2"]'
" endfun
" command! HugoHelperFrontMatterReorder call HugoHelperFrontMatterReorder()

function! HugoHelperHighlight(language)
  normal! I{{< highlight language_placeholder >}}
  exe 's/language_placeholder/' . a:language . '/'
  normal! o{{< /highlight }}
endfun
command! -nargs=? HugoHelperHighlight call HugoHelperHighlight(<f-args>)


function! HugoHelperDraft()
  exe 'g/^draft/s/false/true|norm!``'
endfun
command! HugoHelperDraft call HugoHelperDraft()

function! HugoHelperUndraft()
  exe 'g/^draft/s/true/false|norm!``'
endfun
command! HugoHelperUndraft call HugoHelperUndraft()


function! GetHugoNowDate()
  let now = localtime()
  let strnow = strftime("%Y-%m-%dT%H:%M:%S", now)
  let strnow .= "+09:00"
  return strnow
endfun

function! HugoHelperDateIsNow()
  " exe 'g/^date/s/".*"/\=strftime("%FT%T%z")/'
  let strnow = GetHugoNowDate()
  exe 'g/^date: /s/.*/date: '.strnow.'/|norm!``'
endfun
command! HugoHelperDateIsNow call HugoHelperDateIsNow()

function! HugoHelperLastModIsNow()
  " MEMO no move cursor
  " [macvim - How to run a search and replace command without cursor moving in Vim? - Stack Overflow](https://stackoverflow.com/questions/10468324/how-to-run-a-search-and-replace-command-without-cursor-moving-in-vim)
  let strnow = GetHugoNowDate()
  exe 'g/^lastmod: /s/.*/lastmod: '.strnow.'/|norm!``'
endfun
command! HugoHelperLastModIsNow call HugoHelperLastModIsNow()

function! Hugolize() abort
  let strnow = GetHugoNowDate()
  " slug form dirname with remove `yyyy-mm-dd-`
  " TODO Support not in target md directory case
  let slug = expand('%:h:t')[11:]
  " TODO title from h1
  let title = getline(search("^#"))[2:]

  let list = [
  \ '---',
  \ 'draft: true',
  \ 'date: '.strnow,
  \ 'lastmod: '.strnow,
  \ 'cover: img.png',
  \ 'useRelativeCover: true',
  \ 'comments: true      # set false to hide Disqus comments',
  \ 'share: true         # set false to share buttons',
  \ 'menu: ""            # set "main" to add this content to the main menu',
  \ 'slug: '.slug,
  \ 'title: '.title,
  \ 'categories:',
  \ '  - tech',
  \ 'tags:',
  \ '  - golang',
  \ '---',
  \ ]
  let i = 0
  for row in list
    call append(i, row)
    let i += 1
  endfor
endfun
command! Hugolize call Hugolize()

function! Chomp(string)
  " return substitute(a:string, '\n\+$', '', '')
  return trim(a:string)
endfunction

function! SaveMemoInner(outdir, createDirectory, withHugolize) abort
  let dir = a:outdir
  if !isdirectory(expand(dir))
    call mkdir(expand(dir), "p")
  endif
  let now = localtime()
  let strnow = strftime("%Y-%m-%d", now)
  let title = input("FileName: ", "",  "file")
  redraw
  if title != ""
    let title = "-" . title
  endif
  let name = strnow.title
  if a:createDirectory == 1
    let dir = dir."/".name
    call mkdir(expand(dir), "p")
    let name = "index"
  endif
  exe ":w ".dir."/".name.".md"
  if a:withHugolize == 1
    call Hugolize()
    exe ":w"
  endif
  return 0
endfun

function! SaveMemo() abort
  call SaveMemoInner("~/works/00_memos", 0, 0)
endfun
command! SaveMemo call SaveMemo()

function! SaveMd() abort
  call SaveMemoInner("~/.md/content/post", 1, 1)
endfun
command! SaveMd call SaveMd()

" 全選択コピー
function! CopyAll() abort
  normal! ggVGy
endfun
command! CopyAll call CopyAll()
command! SellAll call CopyAll()

" silent command
function! SilentFExec(...) abort
  try
    silent exe a:1
  catch
  endtry
endfun
" 空白削除(末尾)
function! Trim() abort
  " ! はマップを展開しない
  call SilentFExec(':%s/[ \t]\+$//g')
endfun
command! Trim call Trim()
" 空白削除(先頭)
function! TrimHead() abort
  call SilentFExec(':%s/^[ \t]\+//g')
endfun
command! TrimHead call TrimHead()
" 空行削除
function! TrimLine() abort
  call SilentFExec(':%g/^$/d')
endfun
command! TrimLine call TrimLine()
command! TrimEmpty call TrimLine()
" 空白削除(両端)/カラム取得
function! PickUp(column) abort
  let i = 0
  let num = a:column - 1
  while i < num
    call TrimHead()
    call SilentFExec(':%s/^\S\+ \{-}//g')
    call TrimHead()
    let i += 1
  endwhile
  " Delete after target
  call SilentFExec(':%s/ .\+$//g')
  call Trim()
endfun
function! Strip(...) abort
  if a:0 >= 1
    call PickUp(a:1)
    call TrimLine()
  else
    call TrimHead()
    call Trim()
    call TrimLine()
  end
endfunction
command! -nargs=? Strip call Strip(<f-args>)
function! TrimWord(...) abort
  let w = "'"
  if a:0 == 1
    w = a:1
  end
  call SilentFExec(':%s/^.\{-}\'.w.'//g')
  " call SilentFExec(':%s/\'.w.'.\+//g')
  call SilentFExec(':%s/\'.w.'.\{-}$//g')
  call TrimHead()
  call Trim()
  call TrimLine()
endfunction
command! -nargs=? TrimWord call TrimWord(<f-args>)
" 改行削除
function! OneLine() abort
  let dst = input("Replace LF to: ")
  call TrimHead()
  call Trim()
  call TrimLine()
  call SilentFExec(':%s/\n/'.dst.'/g')
  call Trim()
endfun
command! OneLine call OneLine()

" 改行付与
function! OneLineReverse() abort
  let dst = input("Input char to replace LF: ")
  call SilentFExec(':%s/'.dst.'//g')
endfun
command! OneLineReverse call OneLineReverse()
command! MultiLine call OneLineReverse()

" タブ空白変換
function! ToSpace(...) abort
  let recoveryNum = &tabstop
  let num = 4
  if a:0 >= 1
    let num = a:1
  end
  call SilentFExec(':set expandtab')
  call SetTabs(num)
  call SilentFExec(':retab! '.num)
  call SetTabs(recoveryNum)
endfun
command! -nargs=? ToSpace call ToSpace(<f-args>)
" 空白タブ変換
function! ToTab(...) abort
  let recoveryNum = &tabstop
  let num = 4
  if a:0 >= 1
    let num = a:1
  end
  call SilentFExec(':set noexpandtab')
  call SetTabs(num)
  call SilentFExec(':retab! '.num)
  call SetTabs(recoveryNum)
endfun
command! -nargs=? ToTab call ToTab(<f-args>)

" 選択削除
function! DeleteSelected() abort
  call SilentFExec(':%s///g')
endfun
command! DeleteSelected call DeleteSelected()

" 検索結果の存在する行を削除
function! DeleteSelectedLine() abort
  call SilentFExec(':%g//d')
endfun
command! DeleteSelectedLine call DeleteSelectedLine()
" 検索結果の存在しない行を削除
function! DeleteSelectedLineInvert() abort
  call SilentFExec(':%v//d')
endfun
command! DeleteSelectedLineInvert call DeleteSelectedLineInvert()
function! TrimSelectedLine() abort
  call SilentFExec(':%s/^.*'.histget('/',-1).'.*//g')
endfun
command! TrimSelectedLine call TrimSelectedLine()
function! TrimSelectedLineInvert() abort
  call SilentFExec(':%s/^\%(.*'.histget('/',-1).'.*\)\@!.*//g')
endfun
command! TrimSelectedLineInvert call TrimSelectedLineInvert()
" 指定文字より後ろを削除
function! DeleteAfter(...) abort
  if a:0 >= 1
    let val = a:1
  else
    let val = input("Input char to delete start: ")
  endif
  if val == ""
    echo "\nSpecify something.."
    return
  endif
  call SilentFExec(':%s/'.val.'.*//g')
endfun
command! -nargs=? DeleteAfter call DeleteAfter(<f-args>)

" 選択置換
function! ReplaceSelected() abort
  let dst = input("Replace to: ")
  call SilentFExec(':%s//'.dst.'/g')
endfun
command! ReplaceSelected call ReplaceSelected()

" 選択置換byClipboad
function! ReplacePaste() abort
  let dst = GetClipboad()
  call SilentFExec(':%s//'.dst.'/g')
endfun
command! ReplacePaste call ReplacePaste()

" Encode/LineEnd
function! Encode(type) abort
  if a:type == 0
    exe ':set ff=dos'
    exe ':set fileencoding=cp932'
  else
    exe ':set ff=unix'
    exe ':set fileencoding=utf-8'
  endif
endfun
command! Doslize call Encode(0)
command! ToWin call Encode(0)
command! ToDos call Encode(0)
command! Unixlize call Encode(1)
command! ToUnix call Encode(1)

" toCamel
function! ToCamel() abort
  " call SilentFExec(':%s/_\(.\)/\u\1/g')
  call SilentFExec(":'<,'>s/_\\(.\\)/\\u\\1/g")
endfun
command! ToCamel call ToCamel()
vnoremap <silent> ,c :<c-u>call ToCamel()<cr>

" toSnake
function! ToSnake() abort
  " call SilentFExec(':%s/\([A-Z]\)/_\l\1/g')
  " execute a:firstline . ',' . a:lastline . 's/\([A-Z]\)/_\l\1/g'
  call SilentFExec(":'<,'>s/\\([A-Z]\\)/_\\l\\1/g")
endfun
command! ToSnake :<c-u>call ToSnake()
vnoremap <silent> ,s :<c-u>call ToSnake()<cr>

" コマンドを実行し、バッファに書き込み
function! s:cmd_capture(q_args) "{{{
  redir => output
  silent execute a:q_args
  redir END
  let output = substitute(output, '^\n\+', '', '')

  belowright new

  silent file `=printf('[Capture: %s]', a:q_args)`
  setlocal buftype=nofile bufhidden=unload noswapfile nobuflisted
  call setline(1, split(output, '\n'))
endfunction "}}}

" Capture コマンド定義
command!
\ -nargs=+ -complete=command
\ Capture
\ call s:cmd_capture(<q-args>)

"" 全てのマッピングを表示
"  :AllMaps
"" どのスクリプトで定義されたかの情報も含め表示
"  :verbose AllMaps <buffer>
command!
\ -nargs=* -complete=mapping
\ AllMaps
\ call s:cmd_capture("map <args> | map! <args> | lmap <args>")


" テスト用関数
function! TestScript() abort
  Debug hoge
  echo "pwd:".getcwd()
  echo "uname:".system("uname")
  echo "OSTYPE:".system("echo $OSTYPE")
  echo "IsUbuntu: ".IsUbuntu()
  echo "Clipboad: ".GetClipboad()
endfun
command! TestScript call TestScript()

" JavaBean クラス定義項目リスト化
function! LsJavaBeanFields() abort
  call SilentFExec(':%v/private/d')
  call SilentFExec(':%s/;//g')
  call Strip(3)
endfun
command! LsJavaBeanFields call LsJavaBeanFields()
command! JavaBeanToList call LsJavaBeanFields()

" Table
function! Table() abort
  call SilentFExec(':%s/[\/\*;\(\),]/ /g')
  call Strip()
  call SilentFExec(':%s/ \+/\t/g')
endfun
command! Table call Table()

" Generate Diffarable table
function! DiffTable() abort
  let divideLineNumber = line(".") + 1
  let tab = "\t"
  let aLines = getline(0, divideLineNumber)
  let bLines = getline(divideLineNumber, line("$"))
  call SilentFExec('sort u')
  call Strip()

  let lineNumber = 0
  let allLines = getline(0, line("$"))
  for line in allLines
    let lineNumber += 1
    let outputLine = ""
    " echo lineNumber.":for => ".line
    let outputLine = line . tab
    for aLine in aLines
      if line == aLine
        " echo lineNumber.":a: much! ".aLine
        " let outputLine .= aLine
        let outputLine .= "X"
        break
      endif
    endfor

    let outputLine .= tab
    for bLine in bLines
      if line == bLine
        " let outputLine .= bLine
        let outputLine .= "X"
        break
      endif
    endfor
    call setline(lineNumber, outputLine)
  endfor
endfun
command! DiffTable call DiffTable()

noremap <F5> <ESC>:call RUN()<ENTER>
function! RUN()
  :w|!./%;read
endfunction

function! ToCsv() abort
  call TrimLine()
  call SilentFExec(":%s/\t\/','/g")
  call SilentFExec(":%s/^/'/g")
  call SilentFExec(":%s/$/'/g")
endfun
command! ToCsv call ToCsv()


" ファイルコピー作成
function! Copy() abort
  let def_fname=expand('%:t') . ".copy"
  let fname = input("Input FileName: ", def_fname)
  let fpath = expand("%:p:h") . "/" . fname
  redraw
  call SilentFExec(':w '.fpath)
  echo "==> " . fpath . " created."
endfun
command! Copy call Copy()

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

command! -nargs=*
\   Debug
\   try
\|      echom <q-args> ":" string(<args>)
\|  catch
\|      echom <q-args>
\|  endtry

" C2A0問題修正
function! ReplaceC2A0() abort
  " %s/\%ua0//
  call SilentFExec(":%s/\\%ua0/ /g")
endfun
command! ReplaceC2A0 call ReplaceC2A0()
command! FixC2A0 call ReplaceC2A0()
function! FindC2A0() abort
  " https://stackoverflow.com/questions/1803539/how-do-i-turn-on-search-highlighting-from-a-vim-script
  call feedkeys("/\\%ua0\<CR>")
endfun
command! FindC2A0 call FindC2A0()

function! Open()
  let l:current_file_d = expand('%:p:h')
  " execute system('open ' . l:current_file_d)
  call system('open ' . l:current_file_d)
endfunction
command! Open call Open()

" Strip column list from mysql ddl sql
"   ex) src: ^___`target_col_name`___
"       dst: target_col_name
function! MysqlDdlStripCols() abort
  %s/\(^.\{-}`\|`.*\)//g
endfunction
command! MysqlDdlStripCols call MysqlDdlStripCols()

function! FormatXml()
  %s/></>\r</g | filetype indent on | setf xml | normal gg=G
endfunction
command! FormatXml call FormatXml()

function! ToMdTable() range
  " Get the selected text
  let lines = getline(a:firstline, a:lastline)

  " Get the number of columns
  let num_cols = len(split(lines[0], '\t'))

  " Set the header row
  let header = '| ' . join(map(range(1, num_cols), 'printf("Column %d", v:val)'), ' | ') . ' |'
  let separator = '|:-' . repeat('-:|:', num_cols - 1) . '-:|'

  " Convert each row to a table row
  let rows = []
  for line in lines
    let cells = split(line, '\t')
    let row = '| ' . join(cells, ' | ') . ' |'
    call add(rows, row)
  endfor

  " Combine the header, separator, and rows into a table
  let table = [header, separator] + rows

  " Replace the selected lines with the table
  execute a:firstline . ',' . a:lastline . 'delete'
  call append(a:firstline - 1, table)
endfunction
" https://www.xmisao.com/2014/03/19/how-to-define-range-specific-command-in-vim.html
command! -range ToMdTable <line1>,<line2>call ToMdTable()
vnoremap <silent> <leader>m :ToMdTable<cr>

" ALT+P で paste_img 外部コマンドを実行
function! PasteImage() abort
  if ! executable("paste_img")
    echo "paste_img not found."
    return
  endif
  let dstf = Chomp(system('paste_img -d ' . expand('%:p:h')))
  echo "==> " . dstf . " generated."
endfunction
command! PasteImage call PasteImage()
nnoremap <silent> <M-p> :call PasteImage()<CR>

function! ShellCheckApply() abort
  execute system('shellcheck -f diff '.expand('%:p').' | (cd / && patch -p1 >&/dev/null)')
  execute 'checktime'
endfunction
command! ShellCheckApply call ShellCheckApply()
