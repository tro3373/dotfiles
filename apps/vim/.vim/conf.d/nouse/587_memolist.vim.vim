if !g:plug.is_installed('memolist.vim')
  finish
endif

"=============================================
" Memolist
"=============================================

let g:memolist_path = "$HOME/works/memos"
let g:memolist_memo_date = "%Y-%m-%d %H:%M"                 " date format (default %Y-%m-%d %H:%M) ex) epoch/%D %T
let g:memolist_template_dir_path = "/path/to/template/dir"
let g:memolist_memo_suffix = "md"                           " suffix type (default markdown)
let g:memolist_prompt_tags = 1                              " tags prompt (default 0)
let g:memolist_prompt_categories = 0                        " categories prompt (default 0)
let g:memolist_filename_prefix_none = 0                     " remove filename prefix (default 0)
let g:memolist_qfixgrep = 0                                 " use qfixgrep (default 0)
let g:memolist_vimfiler = 0                                 " use vimfler (default 0)
let g:memolist_unite = 0                                    " use unite (default 0)
let g:memolist_unite_source = "file_rec"                    " use arbitrary unite source (default is 'file')
let g:memolist_unite_option = "-auto-preview -start-insert" " use arbitrary unite option (default is empty)
let g:memolist_denite = 0                                   " use denite (default 0)
" let g:memolist_denite_source = "anything"                   " use arbitrary denite source (default is 'file_rec')
" let g:memolist_denite_option = "anything"                   " use arbitrary denite option (default is empty)
let g:memolist_ex_cmd = 'CtrlP'                             " use various Ex commands (default '')
let g:memolist_delimiter_yaml_array = ','                   " use delimiter of array in yaml front matter (default is ' ')
let g:memolist_delimiter_yaml_start = '---'                 " first line string pattern of yaml front matter (default '==========')
let g:memolist_delimiter_yaml_end = '---'                   " last line string pattern of yaml front matter (default '---')


nmap <Leader>mm :exe "CtrlP" g:memolist_path<cr><f5>
nmap <Leader>mc :MemoNew<cr>
nmap <Leader>mg :MemoGrep<cr>
