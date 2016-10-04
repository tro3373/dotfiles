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
command! CopyPath      call CopyPath()
command! CopyFullPath  call CopyFullPath()
command! CopyFileName  call CopyFileName()
command! CopyTimestamp call CopyTimestamp()
command! CopyDate      call CopyDate()
command! CopyTime      call CopyTime()

function! Settings()
    :tabe $HOME/.vim/conf.d/50_mapping.vim
endfunction
command! Settings call Settings()

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

