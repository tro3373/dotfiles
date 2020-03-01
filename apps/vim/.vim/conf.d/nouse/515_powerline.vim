if !g:plug.is_installed("powerline")
  finish
endif

let g:Powerline_symbols = 'fancy'
" let g:Powerline_symbols = 'compatible'
let g:Powerline_theme       ='solarized256'
let g:Powerline_colorscheme ='solarized256'
let g:Powerline_theme='short'
let g:Powerline_colorscheme='solarized256_dark'
" Python base powerline.
source ~/.local/lib/python2.7/site-packages/powerline/bindings/vim/plugin/powerline.vim
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup

