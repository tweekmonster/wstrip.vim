let s:pattern = '\s\+$'


function! s:cleanable() abort
  return buflisted(bufnr('%')) && empty(&buftype)
endfunction


function! s:git_repo() abort
  if !executable('git')
    return ''
  endif

  let repo = system('git rev-parse --show-toplevel')
  if v:shell_error
    return ''
  endif

  return fnamemodify(split(repo)[0], ':p')
endfunction


function! s:is_tracked(fname) abort
  call system(printf('git ls-files --full-name --error-unmatch "%s"', a:fname))
  return !v:shell_error
endfunction


function! s:get_diff_lines() abort
  if &readonly || !&modifiable || !empty(&buftype)
    return []
  endif

  let buf_name = bufname('%')
  if empty(buf_name) || !filereadable(buf_name)
    return [[1, line('$')]]
  endif

  let repo = s:git_repo()
  let fullpath = fnamemodify(buf_name, ':p')
  let fname = fullpath
  if !empty(repo) && fname[:len(repo)-1] == repo
    let fname = fname[len(repo):]
  else
    let cwd = fnamemodify(getcwd(), ':p')
    if fname[:len(cwd)-1] == cwd
      let fname = fname[len(cwd):]
    else
      return []
    endif
  endif

  if !empty(repo) && s:is_tracked(fullpath)
    let cmd = 'git diff -U0 --no-ext-diff HEAD:"%s" "%s"'
  elseif executable('diff')
    let cmd = 'diff -U0 "%s" "%s"'
  else
    return []
  endif

  " This check is done before the file is written, so the buffer contents
  " needs to be compared with what's already written.  git-diff also requires
  " the file to exist inside of the working tree to diff against HEAD.
  let tmpfile = printf('%s/.wstrip.%s', fnamemodify(fullpath, ':h'),
        \ fnamemodify(fname, ':t'))

  let lines = getline(1, '$')
  if &fileformat ==# 'dos'
    call map(lines, 'v:val . "\r"')
  endif
  call writefile(lines, tmpfile)

  let difflines = split(system(printf(cmd, fname, tmpfile)), "\n")
  call delete(tmpfile)

  if v:shell_error
    return [[1, line('$')]]
  endif

  let groups = []

  for line in difflines
    if line !~# '^@@'
      continue
    endif

    " Only interested in added lines.  If a line is changed, it will show as a
    " deletion *and* addition.
    let added = matchstr(line, '+\zs[0-9,]\+')
    if added =~# ','
      let parts = map(split(added, ','), 'str2nr(v:val)')
      if !parts[1]
        continue
      endif
      let start_line = parts[0]
      let end_line = parts[0] + (parts[1] - 1)
    else
      let start_line = str2nr(added)
      let end_line = start_line
    endif
    call add(groups, [start_line, end_line])
  endfor

  return groups
endfunction


function! wstrip#clean() abort
  if !s:cleanable()
    return
  endif

  let wspattern = s:pattern

  if exists('b:wstrip_trailing_max')
    let wspattern = '\s\{'.b:wstrip_trailing_max.'}\zs'.wspattern
  endif

  let view = winsaveview()
  for group in s:get_diff_lines()
    execute join(group, ',').'s/'.wspattern.'//e'
  endfor
  call histdel('search', -1)
  let @/ = histget('search', -1)
  call winrestview(view)
endfunction


function! wstrip#auto() abort
  if get(b:, 'wstrip_auto', get(g:, 'wstrip_auto', 0))
    call wstrip#clean()
  endif
endfunction


function! wstrip#syntax() abort
  if s:cleanable() && get(b:, 'wstrip_highlight', get(g:, 'wstrip_highlight', 1))
    let wspattern = s:pattern
    if exists('b:wstrip_trailing_max')
      let wspattern = '/\s\{'.b:wstrip_trailing_max.'}'.wspattern.'/ms=s+'.b:wstrip_trailing_max
    else
      let wspattern = '/'.wspattern.'/'
    endif

    execute 'syntax match WStripTrailing '.wspattern.' containedin=ALL'
  endif
endfunction
