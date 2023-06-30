if !g:plug.is_installed("lightline.vim")
  finish
endif

"   solarized/seoul256/jellybeans
" let g:lightline = {
"\    'colorscheme': 'seoul256',
"\    'component': {
"\      'readonly': '%{&readonly?"x":""}',
"\    },
"\    'separator': { 'left': '', 'right': '' },
"\    'subseparator': { 'left': '|', 'right': '|' }
"\ }

let g:lightline = {
\   'colorscheme': 'seoul256',
\   'mode_map': {'c': 'NORMAL'},
\   'active': {
\     'left': [
\       ['mode', 'paste'],
\       ['fugitive', 'pwd', 'filename', 'gitgutter'],
\     ],
\     'right': [
\       ['lineinfo', 'syntastic'],
\       ['percent'],
\       ['filetype', 'fileencoding', 'fileformat'],
\       ['lsp_errors', 'lsp_warnings', 'lsp_ok', 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok'],
\     ]
\   },
\   'component': {
\     'lineinfo': '%3l[%L]:%-2v',
\   },
\   'component_function': {
\     'pwd':          'MyPwd',
\     'modified':     'MyModified',
\     'readonly':     'MyReadonly',
\     'fugitive':     'MyFugitive',
\     'filename':     'MyFilename',
\     'fileformat':   'MyFileformat',
\     'filetype':     'MyFiletype',
\     'fileencoding': 'MyFileencoding',
\     'mode':         'MyMode',
\     'syntastic':    'SyntasticStatuslineFlag',
\     'charcode':     'MyCharCode',
\     'gitgutter':    'MyGitGutter',
\   },
\   'component_expand': {
\     'lsp_warnings':     'lightline_lsp#warnings',
\     'lsp_errors':       'lightline_lsp#errors',
\     'lsp_ok':           'lightline_lsp#ok',
\     'linter_checking':  'lightline#ale#checking',
\     'linter_infos':     'lightline#ale#infos',
\     'linter_warnings':  'lightline#ale#warnings',
\     'linter_errors':    'lightline#ale#errors',
\     'linter_ok':        'lightline#ale#ok',
\   },
\   'component_type': {
\     'lsp_warnings':    'warning',
\     'lsp_errors':      'error',
\     'lsp_ok':          'right',
\     'linter_checking': 'right',
\     'linter_infos':    'right',
\     'linter_warnings': 'warning',
\     'linter_errors':   'error',
\     'linter_ok':       'right',
\   },
\ }

function! GetRefPath(targetPath, fromPath = '')
  let l:src = a:targetPath
  let l:from = a:fromPath
  let l:to = ''
  if l:from == ''
    let l:from = expand("$HOME")
    let l:to = '~/'
  endif
  let l:from = l:from . '/'
  if stridx(l:src, l:from) == -1
    return l:src
  endif
  return substitute(l:src, l:from, l:to, "")
endfunction

function! MyPwd()
  return GetRefPath(getcwd())
endfunction

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &ro ? '(ro)' : ''
endfunction

function! MyFilename()
  " let l:current_file_path = GetRefPath(expand('%:p'), GetGitRoot())
  let l:current_file_path = GetRefPath(expand('%:p'), getcwd())
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? substitute(b:vimshell.current_dir,expand('~'),'~','') :
        \ '' != expand('%:t') ? l:current_file_path : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
      let _ = fugitive#head()
      return strlen(_) ? '⭠ '._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth('.') > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth('.') > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth('.') > 70 ? (strlen(&fenc) ? &fenc : &enc).(&bomb?'(BOM)':'') : ''
endfunction

function! MyMode()
  return winwidth('.') > 60 ? lightline#mode() : ''
endfunction

function! MyGitGutter()
  if ! exists('*GitGutterGetHunkSummary')
        \ || ! get(g:, 'gitgutter_enabled', 0)
        \ || winwidth('.') <= 90
    return ''
  endif
  let symbols = [
        \ g:gitgutter_sign_added . ' ',
        \ g:gitgutter_sign_modified . ' ',
        \ g:gitgutter_sign_removed . ' '
        \ ]
  let hunks = GitGutterGetHunkSummary()
  let ret = []
  for i in [0, 1, 2]
    if hunks[i] > 0
      call add(ret, symbols[i] . hunks[i])
    endif
  endfor
  return join(ret, ' ')
endfunction

" https://github.com/Lokaltog/vim-powerline/blob/develop/autoload/Powerline/Functions.vim
function! MyCharCode()
  if winwidth('.') <= 70
    return ''
  endif

  " Get the output of :ascii
  redir => ascii
  silent! ascii
  redir END

  if match(ascii, 'NUL') != -1
    return 'NUL'
  endif

  " Zero pad hex values
  let nrformat = '0x%02x'

  let encoding = (&fenc == '' ? &enc : &fenc)

  if encoding == 'utf-8'
    " Zero pad with 4 zeroes in unicode files
    let nrformat = '0x%04x'
  endif

  " Get the character and the numeric value from the return value of :ascii
  " This matches the two first pieces of the return value, e.g.
  " "<F>  70" => char: 'F', nr: '70'
  let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

  " Format the numeric value
  let nr = printf(nrformat, nr)

  return "'". char ."' ". nr
endfunction
