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
  if g:is_orb
    let @0 = getreg('*')
    call PassThroughClip()
  endif
  echo "Clip!=> ".@*
endfunction
function! ClipDir()
  let @*=expand('%:h')
  call ClipComm()
endfunction
function! ClipPath()
  let @*=GetGitRelativePath()
  call ClipComm()
endfunction
function! GetGitRelativePath()
  let l:gitroot = GetGitRoot()
  if l:gitroot == "."
    return expand('%:p')
  else
  endif
  let l:fullpath = expand('%:p')
  let l:gitroot_with_slash = l:gitroot . '/'
  return substitute(l:fullpath, escape(l:gitroot_with_slash, '/\'), '', '')
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
command! ClipFilePath   call ClipPath()
command! ClipFullPath   call ClipFullPath()
command! ClipFileName   call ClipFileName()
command! ClipTimestamp  call ClipTimestamp()
command! ClipDate       call ClipDate()
command! ClipTime       call ClipTime()
command! ShowPath       call ShowPath()
command! CopyDir        call ClipDir()
command! CopyPath       call ClipPath()
command! CopyFilePath   call ClipPath()
" command! Copy           call ClipFullPath()
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
  let pos = getpos(".")
  let v = winsaveview()
  exe 'g/^lastmod: /s/.*/lastmod: '.strnow.'/|norm!``'
  call winrestview(v)
  call setpos(".", pos)
endfun
command! HugoHelperLastModIsNow call HugoHelperLastModIsNow()
" Update `lastmod` date for markdown for hugo
autocmd BufWritePost index*.md call HugoHelperLastModIsNow()

function! Hugolize() abort
  let strnow = GetHugoNowDate()
  " slug form dirname with remove `yyyy-mm-dd-`
  " TODO Support not in target md directory case
  let slug = expand('%:h:t')[11:]
  " Move cursor to top for search
  norm! gg
  let title = getline(search("^#"))[2:]

  let list = [
  \ '---',
  \ 'draft: true',
  \ 'date: '.strnow,
  \ 'lastmod: '.strnow,
  \ 'cover:',
  \ '    image: img.webp',
  \ 'title: "'.title.'"',
  \ 'categories:',
  \ '  - tech',
  \ 'tags:',
  \ '  - golang',
  \ '---',
  \ '## 問題',
  \ '## 原因',
  \ '## 解決方法',
  \ '## Refs',
  \ ]

  " '## はじめに',
  " '## 問題 疑問',
  " '## まとめ 結果 解決方法',
  " '## 以下詳細',
  " '## Refs',

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

function! SaveMemoInner(outdir, defaultTitle, createDirectory, withHugolize) abort
  let dir = a:outdir
  if !isdirectory(expand(dir))
    " pオプション: 親ディレクトリが存在しない場合は作成する (parents)
    call mkdir(expand(dir), "p")
  endif
  let now = localtime()
  let stryyyy = strftime("%Y", now)
  let strymd = strftime("%Y-%m-%d", now)
  let title = input("Title: ", a:defaultTitle,  "file")
  redraw
  if title != ""
    let title = "-" . title
  endif
  let name = strymd . title
  let dir = dir . "/" . stryyyy
  call mkdir(expand(dir), "p")
  if a:createDirectory == 1
    let dir = dir . "/" . name
    call mkdir(expand(dir), "p")
  elseif a:createDirectory == 2
    call mkdir(expand(dir), "p")
  endif
  if a:withHugolize == 1
    let name = "index"
  endif
  exe ":w " . dir . "/" . name . ".md"
  exe ":e " . dir . "/" . name . ".md"
  if a:withHugolize == 1
    call Hugolize()
    exe ":w"
  endif
  return 0
endfun

function! SaveMemoPrv() abort
  call SaveMemoInner("~/.mo/prv", "log", 2, 0)
endfun
command! SaveMemoPrv call SaveMemoPrv()

function! SaveMemoJob() abort
  call SaveMemoInner("~/.mo/job", "log", 2, 0)
endfun
command! SaveMemoJob call SaveMemoJob()

function! WriteToTemp() abort
  let tmpfile = tempname()
  execute 'write! ' . tmpfile
  return tmpfile
endfunction

function! WriteSelectionToTemp() abort
  let tmpfile = tempname()

  " 選択範囲の取得
  " 1. 現在の無名レジスタの内容を保存
  let save_reg = @"
  " 2. 選択範囲をヤンク
  normal! gvy
  " 3. ヤンクした内容を変数に格納
  let selected_text = @"
  " 4. 無名レジスタの内容を元に戻す
  let @" = save_reg

  " 一時ファイルへの書き込み
  call writefile(split(selected_text, '\n'), tmpfile)

  return tmpfile
endfunction

" MEMO: prpName は一意に決まること
function! GenerateViaLLM(prpName, tmpfile) abort
  " システムコマンドへ渡す
  " MEMO: tmp内容が反映されないケースがるので、0.2秒待機
  let title = Chomp(system('sleep 0.2 && cat '..a:tmpfile..' | prp -ne '..a:prpName..' | llm -c tgpt -p groq'))
  " 一時ファイルを削除
  call delete(a:tmpfile)
  return title
endfun

function! SaveKnowledge() abort
  let tmpfile = WriteToTemp()
  let title = GenerateViaLLM("gen-knowledge-filename-ja.md", tmpfile)
  call SaveMemoInner("~/.mo/knowledge", title, 0, 0)
endfun
command! SaveKnowledge call SaveKnowledge()
nnoremap sT :<C-u>SaveKnowledge<CR>

function! SaveMd() abort
  let tmpfile = WriteToTemp()
  let title = GenerateViaLLM("gen-content-title.md", tmpfile)
  call SaveMemoInner("~/.md/content/posts", title, 1, 1)
endfun
command! SaveMd call SaveMd()

function! CorrectEnglish() abort
  " 選択範囲を一時ファイルに保存
  let tmpfile = WriteSelectionToTemp()
  " LLMで修正
  let content = GenerateViaLLM("correct-english.md", tmpfile)

  " 選択範囲を修正された内容で置き換え
  let save_reg = @"
  let @" = content
  normal! gvp
  let @" = save_reg
endfun
" コマンドとして登録（範囲指定可能）
command! -range CorrectEnglish call CorrectEnglish()
" キーマッピング
vnoremap <Leader>m :<C-u>call CorrectEnglish()<CR>

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
  call SilentFExec(':%s/'.dst.'/
/g')
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

function! ToSpace2() abort
  " Not work
  " %s/^\( \{4}\)\+/\=repeat('  ', len(submatch(0)) / 4)/
  call ToTab(4)
  call ToSpace(2)
endfun
command! ToSpace2 call ToSpace2()
function! ToSpace4() abort
  call ToTab(2)
  call ToSpace(4)
endfun
command! ToSpace4 call ToSpace4()

" 選択削除
function! DeleteSelected() abort
  call SilentFExec(':%s///g')
endfun
command! DeleteSelected call DeleteSelected()
" 選択部分以外を削除
function! DeleteUnSelected() abort
  if empty(@/)
    echo "検索パターンが空"
    return
  endif

  " 現在のバッファ内容を保存
  let l:lines = getline(1, '$')
  let l:all_content = join(l:lines, "\n")

  " マッチする部分を収集
  let l:matches = []
  let l:pattern = @/

  " すべてのマッチを検索
  let l:start = 0
  while 1
    let l:match_start = match(l:all_content, l:pattern, l:start)
    if l:match_start == -1
      break
    endif
    let l:match_end = matchend(l:all_content, l:pattern, l:start)
    let l:match_text = strpart(l:all_content, l:match_start, l:match_end - l:match_start)
    call add(l:matches, l:match_text)
    let l:start = l:match_end
  endwhile

  if len(l:matches) > 0
    " バッファをクリアして、マッチした部分のみを挿入
    normal! ggdG
    call setline(1, l:matches)
    echo "Extracted " . len(l:matches) . " matches"
  else
    echo "No matches found"
  endif
endfun
command! DeleteUnSelected call DeleteUnSelected()

command! DeleteSelectedLineInvert call DeleteSelectedLineInvert()
" 検索結果の存在する行を削除
function! DeleteSelectedLine() abort
  " call SilentFExec(':%g//d')
  let search = @/
  call ReplaceAllWithSystemCmdResult("grep -v '".search."'")
endfun
command! DeleteSelectedLine call DeleteSelectedLine()
" 検索結果の存在しない行を削除
function! DeleteSelectedLineInvert() abort
  " call SilentFExec(':%v//d')
  " let search = histget('/', -1)
  let search = @/
  call ReplaceAllWithSystemCmdResult("grep '".search."'")
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

function! ToCamelOrSnake(camel) range
  " 選択範囲またはファイル全体の各行に対して処理
  let lines = getline(a:firstline, a:lastline)
  let convertedLines = []
  for line in lines
    if a:camel
      " 最初の文字を小文字に変換（camelCaseでは最初の文字は小文字であるべき）
      let line = substitute(line, '^\(\u\)', '\l\1', '')
      " アンダースコアに続く文字を大文字に変換
      let convertedLine = substitute(line, '_\(\w\)', '\u\1', 'g')
    else
      " 大文字をアンダースコアに変換し、大文字を小文字にする
      let convertedLine = substitute(line, '\(\u\)', '_\l\1', 'g')
      " 文字列の先頭がアンダースコアの場合は削除
      let convertedLine = substitute(convertedLine, '^_', '', '')
    endif
    call add(convertedLines, convertedLine)
  endfor
  " 変換したテキストを元の位置に置換
  call setline(a:firstline, convertedLines)
endfunction
command! -range=% ToCamel <line1>,<line2>call ToCamelOrSnake(1)
command! -range=% ToSnake <line1>,<line2>call ToCamelOrSnake(0)

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

function! ReplaceAllWithSystemCmdResult(command) abort
  " 全行格納
  let lines = getline(1,"$")
  " システムコマンドへ渡す
  let output = system(a:command, lines)
  " 結果がそのままだとNULL文字で張り付く為、配列へ格納
  let output_lines = split(output, "\n")
  " '%'        => すべての行を指定
  " 'delete _' => `_`(ブラックホールレジスタ("_))を指定して、削除を行う
  silent execute ':%delete _'
  " 1行目から貼り付け
  call setline(1, output_lines)
endfun

" JavaBean クラス定義項目リスト化
function! JavaBeanToList() abort
  call CloneBufferToNewTab()
  if executable('sed')
    call ReplaceAllWithSystemCmdResult("grep -E '(private|public|protected).*;' |sed -e 's,^.*\\(private\\|public\\|protected\\).*[ \\t]\\+\\(\\w\\+\\);,\\2,g'")
    return
  endif
  call SilentFExec(':%v/private/d')
  call SilentFExec(':%s/;//g')
  call Strip(3)
endfun

command! JavaBeanToList call JavaBeanToList()

function! CloneBufferToNewTab()
  normal! ggVGy
  tabnew
  normal! ggP
endfunction
command! CloneBufferToNewTab call CloneBufferToNewTab()

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

" noremap <F5> <ESC>:call RUN()<ENTER>
" function! RUN()
"   :w|!./%;read
" endfunction

function! ToCsv() abort
  call TrimLine()
  call SilentFExec(":%s/\t\/','/g")
  call SilentFExec(":%s/^/'/g")
  call SilentFExec(":%s/$/'/g")
endfun
command! ToCsv call ToCsv()


" ファイルコピー作成
function! Buckup() abort
  " :t はファイル名のみ取得、:r は拡張子を除外
  let base_name = expand('%:t:r')
  " .bk1などを除外
  " substitute
  "   base_name: 対象文字列
  "   \.bk\d\+$: .bkに続く1つ以上の数字が末尾にマッチ
  "   '': 空文字列に置換
  "   4th arg: フラグ指定なし (g:グローバル置換、i:大文字小文字無視などのフラグを指定しない)
  let base_name = substitute(base_name, '\.bk\d\+$', '', '')
  " .bkを除外
  let base_name = substitute(base_name, '\.bk$', '', '')
  let ext = expand('%:e')
  let count = 1
  let def_fname = base_name . '.bk.' . ext
  while filereadable(expand("%:p:h") . "/" . def_fname)
    let count += 1
    let def_fname = base_name . '.bk' . count . '.' . ext
  endwhile
  let fname = input("Input FileName: ", def_fname)
  let fpath = expand("%:p:h") . "/" . fname
  redraw
  call SilentFExec(':w '.fpath)
  echo "==> " . fpath . " created."
endfun
command! Buckup call Buckup()
command! Bk call Buckup()
command! Copy call Buckup()

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

" 開いているファイルのディレクトリをエクスプローラで開く
function! Open()
  let l:current_file_d = expand('%:p:h')
  " execute system('open ' . l:current_file_d)
  call system('open ' . l:current_file_d)
endfunction
command! Open call Open()
map <silent> qn :!open %:h>&/dev/null<ENTER>

" function! OpenTerm()
"   let l:current_file_d = expand('%:p:h')
"   call system('tmux split-window -v cd ' . l:current_file_d)
" endfunction
" command! OpenTerm call OpenTerm()

function! OpenChangePath()
  " 現在のファイルパスを取得
  let current_path = expand('%:p')
  " プロンプトを表示し、ユーザーにパスを入力してもらう
  let user_path = input('Enter file path: ', current_path, 'file')
  " ユーザーがEnterを押したら、新しいタブを開いてそのパスのファイルを開く
  if !empty(user_path)
      execute 'tabnew ' . user_path
  endif
endfunction

" OpenChangePathコマンドを定義
command! OpenChangePath call OpenChangePath()

function! Code(opts)
let l:path = expand('%:p')
  if a:opts =~# 'r'
    let l:path = GetGitRoot()
  endif
call system('code ' . l:path)
endfunction
command! -nargs=* Code call Code(<q-args>)

function! Cursor(opts)
let l:path = expand('%:p')
  if a:opts =~# 'r'
    let l:path = GetGitRoot()
  endif
call system('cursor ' . l:path)
endfunction
command! -nargs=* Cursor call Cursor(<q-args>)
command! -nargs=* R call Cursor(<q-args>)

function! ReOpenUtf8()
  exe "e ++enc=utf-8"
endfunction
function! ReOpenShiftJis()
  exe "e ++enc=shift-jis"
endfunction
command! -nargs=0 ReOpenUtf8 call ReOpenUtf8()
command! -nargs=0 ReOpenShiftJis call ReOpenShiftJis()

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
vnoremap <silent> <leader>md :ToMdTable<cr>

" ALT+P で paste_img 外部コマンドを実行
function! PasteImage() abort
  if ! executable("paste_img")
    echo "paste_img not found."
    return
  endif
  let dstf = Chomp(system('paste_img -w -d ' . expand('%:p:h')))
  let filename = fnamemodify(dstf, ":t") " :t 指定でファイル名のみを取得
  call append('.', '!['..filename..']('..filename..')')
  echo "==> " . dstf . " generated."
endfunction
command! PasteImage call PasteImage()
nnoremap <silent> <M-p> :call PasteImage()<CR>

function! FixShellCheckError() abort
  execute system('shellcheck -f diff '.expand('%:p').' | (cd / && patch -p1 >&/dev/null)')
  execute 'checktime'
endfunction
command! FixShellCheckError call FixShellCheckError()

function! ReplaceMdList2Csv(arr) range
  let lines = getline(a:firstline, a:lastline)
  let csv = join(map(lines, {key, val-> substitute(val, '^\s*-\s*', '', '')}), ", ")
  if a:arr == "array"
    let csv = "["..csv.."]"
  endif
  " Replace the selected lines with the table
  execute a:firstline . ',' . a:lastline . 'delete'
  call append(a:firstline - 1, csv)
endfunction
command! -range ReplaceMdList2Csv <line1>,<line2>call ReplaceMdList2Csv('csv')
command! -range ReplaceMdList2Array <line1>,<line2>call ReplaceMdList2Csv('array')

function! ReplaceTsvNewlines()
  "================================ gpt say sample1
  " " 各行をダブルクォーテーションで囲む
  " %s/^\v(.+)$/\"\1\"/
  " " ダブルクォーテーション内の改行をスペースに置換
  " " \v: very magic: (非常に多くのメタ文字を有効にする)
  " " \zs: 検索パターンの開始位置を指定
  " " \ze: 検索パターンの終了位置を指定
  " %s/\v"\zs\n\ze"/ /g
  " " 各レコードの終端のダブルクォーテーションをタブに置換
  " %s/\v"\n"/\t/g
  " " 末端に余計なタブが残る場合があるので削除
  " %s/\t$//g
  "================================ gpt say sample2
  " :%g/[^"]$/: ファイル内のすべての行に対して正規表現[^"]$を満たす行を検索します。
  " これは、行末がダブルクォーテーションではない行を選択します。
  " normal! J : 選択された各行に対して、VimノーマルモードのJコマンドを適用します。
  " :%g/[^"]$/normal! J
  "================================
  " ユーザーから置換文字を入力
  let l:replace_char = input('Enter replacement character: ', '')
  if l:replace_char == ''
    " デフォルトは ' '
    let l:replace_char = ' '
  endif
  " 置換処理、行末がダブルクォーテーションでない行に対して改行を入力した文字に置換
  " \=l:replace_char: `\=`: 右側の置換部分でevalを行う
  :%s/\([^"]\)$\n/\=submatch(1)..l:replace_char/g
endfunction
command! ReplaceTsvNewlines call ReplaceTsvNewlines()

function! ToggleLinting() abort
  if !exists('g:ale_enabled')
    return
  endif
  if g:ale_enabled
    ALEDisable
    LspStopServer
    let g:ale_enabled = 0
    let g:lsp_diagnostics_enabled = 0
    let g:lsp_diagnostics_echo_cursor = 0
    " let g:lsp_diagnostics_highlights_enabled = 0
    let b:EditorConfig_disable = 1
    echo "==> ALE and LSP EditorConfig disabled."
  else
    ALEEnable
    " LspStartServer => Not Such command Exist
    let g:ale_enabled = 1
    let g:lsp_diagnostics_enabled = 1
    let g:lsp_diagnostics_echo_cursor = 1
    " let g:lsp_diagnostics_highlights_enabled = 1
    let b:EditorConfig_disable = 0
    echo "==> ALE and LSP EditorConfig enabled."
  endif
endfunction
command! ToggleLinting call ToggleLinting()
nnoremap <silent> <Space>v :call ToggleLinting()<CR>

" [Markdownでサクッと選択した文字列にリンクを追加する方法](https://zenn.dev/skanehira/articles/2021-11-29-vim-paste-clipboard-link)
let s:clipboard_register = has('linux') || has('unix') ? '+' : '*'
function! InsertMarkdownLink() abort
  " use register `9`
  let old = getreg('9')
  let link = trim(getreg(s:clipboard_register))
  if link !~# '^http.*'
    normal! gvp
    return
  endif
  " replace `[text](link)` to selected text
  normal! gv"9y
  let word = getreg(9)
  let newtext = printf('[%s](%s)', word, link)
  call setreg(9, newtext)
  normal! gv"9p
  " restore old data
  call setreg(9, old)
endfunction
augroup markdown-insert-link
  au!
  au FileType markdown vnoremap <buffer> <silent> p :<C-u>call InsertMarkdownLink()<CR>
augroup END

" function! SendBufferToCommandAndClose()
"   " 現在のバッファの内容を一時ファイルに保存
"   execute 'write! /tmp/buff_prp.tmp'
"   " terminal を開いてコマンドを実行し、実行後に閉じる
"   " execute 'terminal cat<'..tmpfile..' | prp -ne>'..tmpfile2..' && sleep 0.5 && exit'
"   " execute 'terminal cat< /tmp/buff_prp.tmp | prp -ne >/tmp/buff_prp.md && nvim /tmp/buff_prp.md'
"   " system('cat< /tmp/buff_prp.tmp | prp -ne >/tmp/buff_prp.md')
"   "
"   "
"   "  " prpコマンドを実行して結果を一時ファイルに保存
"   call system('cat /tmp/buff_prp.tmp | prp -ne > /tmp/buff_prp.md')
"   " 現在のバッファで一時ファイルを開く
"   execute 'edit /tmp/buff_prp.md'
"   "
"   " 一時ファイルを削除
"   " call delete(tmpfile)
"   " exe "e /tmp/buff_prp.md"
"   " normal ggVGd
"   " normal "+p
" endfunction

function! SendBufferToCommandAndClose()
  " 現在のバッファの内容を一時ファイルに保存
  execute 'write! /tmp/buff_prp.tmp'
  " 先に開いておく
  " system('touch /tmp/buff_prp.md')
  execute 'edit /tmp/buff_prp.md'

  " 新しいタブでターミナルを開き、prpコマンドを実行
  execute 'tabnew | terminal cat /tmp/buff_prp.tmp | prp -ne >/tmp/buff_prp.md'
  " ターミナルバッファが閉じられたときに実行されるオートコマンドを設定
  augroup prp_terminal
    autocmd!
    autocmd TermClose <buffer> call PostPrpProcess()
  augroup END
  " 結果を処理する関数
  function! PostPrpProcess()
    " 再描画の為に実施
    execute 'edit /tmp/buff_prp.md'
    " 一時的なオートコマンドグループを削除
    augroup prp_terminal
      autocmd!
    augroup END
  endfunction
endfunction

nnoremap <M-m> :call SendBufferToCommandAndClose()<CR>

function! ConvertMdNumberToOne()
  " 行頭の数字を1に変換
  %s/^\d\. /1. /g
  " 行頭以外の数字を1に変換
  %s/  \d\. /  1. /g
endfunction
command! ConvertMdNumberToOne call ConvertMdNumberToOne()


" 半角全角変換
function! ZenkakuHankakuRange(mode, ...)
  let z = '０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ'
  let h = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  let s = a:mode ==# 'zen' ? h : z
  let d = a:mode ==# 'zen' ? z : h
  let s_list = split(s, '\zs')
  let d_list = split(d, '\zs')

  " ビジュアルモードで選択されている場合はその範囲を使用
  let range = visualmode() != '' ? "'<,'>" : '%'

  for i in range(len(s_list))
    try
      let cmd = range . 's/' . escape(s_list[i], '/\') . '/' . escape(d_list[i], '/\') . '/g'
      silent execute cmd
    catch /^Vim\%((\a\+)\)\=:E486/
      " パターンが見つからない場合は無視
    endtry
  endfor
endfunction
command! -range Zen call ZenkakuHankakuRange('zen')
command! -range Han call ZenkakuHankakuRange('han')
command! -range ToZen call ZenkakuHankakuRange('zen')
command! -range ToHan call ZenkakuHankakuRange('han')

function! ShowTabs() abort
  :set shiftwidth?
  :set tabstop?
  :set softtabstop?
  :set expandtab?
endfun
command! ShowTabs call ShowTabs()

function! Issue(args) abort
  let tmpfile = WriteToTemp()
  if !exists('*jobstart')
    echo "jobstart not found. Please update Neovim to use this command."
    return
  endif
  let cmd = ['issue']
  call add(cmd, '-f')
  call add(cmd, tmpfile)
  if !empty(a:args)
    call add(cmd, '-t')
    call add(cmd, a:args)
  endif
  call jobstart(cmd)
endfunction
command! -nargs=* Issue call Issue(expand('<args>'))

" Goto file under cursor
" - `gf`: カーソル下のファイル名を開く
" - `gF`: カーソル下のファイル名＋行番号を開く（例: `foo.txt:42` なら 42 行目で開く）
" noremap gf <C-W>gF
" noremap gF <C-W>gf
function! JumpToFileAndLineUnderCursor()
  let l:word = expand('<cWORD>')
  let l:word = substitute(l:word, '[`''"<>]', '', 'g')
  if l:word =~ '\v(.+)(:\+?|:|#L)(\d+)$'
    let l:file = substitute(l:word, '\v(:\+?|:|#L)\d+$', '', '')
    let l:lnum = matchstr(l:word, '\v(\d+)$')
    execute 'tabedit ' . fnameescape(l:file)
    execute l:lnum
  else
    execute 'tabedit ' . fnameescape(l:word)
  endif
endfunction
nnoremap gf :call JumpToFileAndLineUnderCursor()<CR>

function! Bom()
  set bomb
  write
endfunction
command! Bom call Bom()

function! BomRemove()
  set nobomb
  write
endfunction
command! BomRemove call BomRemove()
