command! -nargs=0 WStrip call wstrip#clean()

if has('gui') || !empty(system('tput smul'))
  highlight default WStripTrailing ctermfg=red cterm=underline guifg=red gui=underline
else
  highlight default WStripTrailing ctermbg=red guibg=red
endif


augroup wstrip
  autocmd BufWritePre * call wstrip#auto()
  autocmd Syntax * call wstrip#syntax()
augroup END
