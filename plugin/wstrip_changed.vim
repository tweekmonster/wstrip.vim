command! -nargs=0 StripChangedWhitespace call wstrip_changed#clean()

augroup wstrip
  autocmd BufWritePre * call wstrip_changed#auto()
augroup END
