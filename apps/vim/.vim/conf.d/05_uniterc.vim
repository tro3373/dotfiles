"######################################################################
"   uniterc.vim
"           unite関連の設定ファイル
"           @see https://github.com/Shougo/unite.vim
"######################################################################

" 入力モードで開始する
let g:unite_enable_start_insert = 1

" バッファ一覧
nnoremap <silent> <Leader>b :<C-u>Unite buffer<CR>

" ファイル一覧
nnoremap <silent> <Leader>f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>

" レジスタ一覧
nnoremap <silent> <Leader>r :<C-u>Unite -buffer-name=register register<CR>

" 最近使用したファイル一覧
nnoremap <silent> <Leader>m :<C-u>Unite file_mru<CR>

" 全部乗せ
nnoremap <silent> <Leader>a :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

" unite.vim上でのキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
    " 単語単位からパス単位で削除するように変更
    imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

    " ESCキーを2回押すと終了する
    nmap <silent><buffer> <ESC><ESC> q
    imap <silent><buffer> <ESC><ESC> <ESC>q
endfunction


" ウィンドウを分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')

" ウィンドウを縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')

