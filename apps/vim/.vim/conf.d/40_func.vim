"######################################################################
" func.vim
"     ユーザ定義関数やマクロの定義をする
"######################################################################
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
function! ShowPath()
  echo expand('%:p')
endfunction
command! CopyPath       call CopyPath()
command! CopyFullPath   call CopyFullPath()
command! CopyFileName   call CopyFileName()
command! CopyTimestamp  call CopyTimestamp()
command! CopyDate       call CopyDate()
command! CopyTime       call CopyTime()
command! ShowPath       call ShowPath()


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
  execute system(l:execmd)
  echo "Tags file Created to " . l:gitroot . "/.git/tags"
endfunction
command! Ctags call Ctags()

function! HugoHelperFrontMatterReorder()
  exe 'g/^draft/m 1'
  exe 'g/^date/m 2'
  exe 'g/^title/m 3'
  exe 'g/^slug/m 4'
  exe 'g/^description/m 5'
  exe 'g/^tags/m 6'
  exe 'g/^categories/m 7'
  " create date taxonomy
  exe 'g/^date/co 8'
  exe ':9'
  exe ':s/.*\(\d\{4\}\)-\(\d\{2\}\).*/\1 = ["\2"]'
endfun
command! HugoHelperFrontMatterReorder call HugoHelperFrontMatterReorder()

function! HugoHelperHighlight(language)
  normal! I{{< highlight language_placeholder >}}
  exe 's/language_placeholder/' . a:language . '/'
  normal! o{{< /highlight }}
endfun
command! -nargs=? HugoHelperHighlight call HugoHelperHighlight(<f-args>)


function! HugoHelperDraft()
  exe 'g/^draft/s/false/true'
endfun
command! HugoHelperDraft call HugoHelperDraft()

function! HugoHelperUndraft()
  exe 'g/^draft/s/true/false'
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
  exe 'g/^date: /s/.*/date: '.strnow.'/'
endfun
command! HugoHelperDateIsNow call HugoHelperDateIsNow()

function! HugoHelperLastModIsNow()
  let strnow = GetHugoNowDate()
  exe 'g/^lastmod: /s/.*/lastmod: '.strnow.'/'
endfun
command! HugoHelperLastModIsNow call HugoHelperLastModIsNow()

function! Hugolize() abort
  let strnow = GetHugoNowDate()
  let list = [
    \ '---',
    \ 'date: '.strnow,
    \ 'lastmod: '.strnow,
    \ 'draft: true',
    \ 'title: dotScale 2014 as a sketch',
    \ 'slug: dotscale-2014-as-a-sketch',
    \ 'tags:',
    \ '  - ubuntu',
    \ 'categories:',
    \ '  - tech',
    \ 'image: images/imagename.jpg',
    \ 'comments: true',
    \ 'share: true',
    \ '---',
  \ ]
  let i = 0
  for row in list
    call append(i, row)
    let i += 1
  endfor
endfun
command! Hugolize call Hugolize()

function! SaveMemo() abort
  let outdir = "."
  let memodir = expand("~/works/00_memos")
  if isdirectory(memodir)
    let outdir = memodir
  endif
  let now = localtime()
  let strnow = strftime("%Y-%m-%d-", now)
  let title = input("FileName: ", "",  "file")
  redraw
  exe ":w ".outdir."/".strnow.title.".md"
endfun
command! SaveMemo call SaveMemo()

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
function! ToSpace() abort
  let num = input("Input space number of tab: ")
  call SilentFExec(':set expandtab')
  call SetTabs(num)
  call SilentFExec(':retab! '.num)
endfun
command! ToSpace call ToSpace()
" 空白タブ変換
function! ToTab() abort
  let num = input("Input space number of tab: ")
  call SilentFExec(':set noexpandtab')
  call SetTabs(num)
  call SilentFExec(':retab! '.num)
endfun
command! ToTab call ToTab()


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
  call SilentFExec(':%s/_\(.\)/\u\1/g')
endfun
command! ToCamel call ToCamel()

" toSnake
function! ToSnake() abort
  call SilentFExec(':%s/\([A-Z]\)/_\l\1/g')
endfun
command! ToSnake call ToSnake()

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
        let outputLine .= aLine
        break
      endif
    endfor

    let outputLine .= tab
    for bLine in bLines
      if line == bLine
        let outputLine .= bLine
        break
      endif
    endfor
    call setline(lineNumber, outputLine)
  endfor
endfun
command! DiffTable call DiffTable()

