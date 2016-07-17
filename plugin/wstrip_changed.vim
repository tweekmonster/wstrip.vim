command! -nargs=0 StripChangedWhitespace call wstrip_changed#clean()

highlight default TrailingWhiteSpace ctermbg=red guibg=red


augroup wstrip
  autocmd BufWritePre * call wstrip_changed#auto()
  autocmd Syntax * call wstrip_changed#syntax()
augroup END
