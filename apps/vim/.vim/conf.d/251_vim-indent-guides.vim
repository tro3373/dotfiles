" Indent Guide Settings
if !g:plug.is_installed("vim-indent-guides")
  finish
endif

" set ts=4 sw=4 et
let g:indent_guides_enable_on_vim_startup=1     " Vim起動時に可視化設定
let g:indent_guides_start_level=2               " ガイドをスタートするインデントの量
let g:indent_guides_guide_size=1                " ガイドの幅
let g:indent_guides_auto_colors=0               " 自動カラー設定
" autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=black
" autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=darkgrey
" autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=234    " Odd(奇数) 色
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=233    " Odd(奇数) 色
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=236    " Even(偶数) 色
