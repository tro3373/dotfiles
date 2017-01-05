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
function! ShowPath()
  echo expand('%:p')
endfunction
command! CopyPath      call CopyPath()
command! CopyFullPath  call CopyFullPath()
command! CopyFileName  call CopyFileName()
command! CopyTimestamp call CopyTimestamp()
command! CopyDate      call CopyDate()
command! CopyTime      call CopyTime()
command! ShowPath      call ShowPath()


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

" c_CTRL-X
"   Input current buffer's directory on command line.
"   Kaoriya flavor
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
    let strnow = strftime("%Y-%m-%dT%H:%M:%S%z", now)
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

function! Hugo() abort
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
command! Hugo call Hugo()

