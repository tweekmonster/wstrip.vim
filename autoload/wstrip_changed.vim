function! s:cleanable() abort
  return buflisted(bufnr('%')) && empty(&buftype)
endfunction


function! s:is_git_repo() abort
  let last_dir = ''
  let cur_dir = expand('%:p:h')

  while last_dir != cur_dir
    if isdirectory(cur_dir.'/.git')
      return 1
    endif
    let last_dir = cur_dir
    let cur_dir = fnamemodify(cur_dir, ':h')
  endwhile

  return 0
endfunction


function! s:get_diff_lines() abort
  let has_grep = executable('grep')

  if s:is_git_repo() && executable('git')
    let cmd = 'git diff -U0 --no-ext-diff HEAD:"%s" "%s"'
  elseif executable('diff')
    let cmd = 'diff -U0 "%s" "%s"'
  else
    return []
  endif

  let buf_file = expand('%')
  if empty(buf_file)
    return []
  endif

  if has_grep
    " If grep is available, pre-filter the lines so this script doesn't have
    " to.
    let cmd .= ' | grep "^@@"'
  endif

  " This check is done before the file is written, so the buffer contents
  " needs to be compared with what's already written.  git-diff also requires
  " the file to exist inside of the working tree to diff against HEAD.
  let tmpfile = printf('%s/.wstrip.%s', fnamemodify(buf_file, ':h'),
        \ fnamemodify(buf_file, ':t'))
  call writefile(getline(1, '$'), tmpfile)

  let difflines = split(system(printf(cmd, buf_file, tmpfile)), "\n")
  call delete(tmpfile)

  let groups = []

  for line in difflines
    if !has_grep && line !~# '^@@'
      continue
    endif

    " Only interested in added lines.  If a line is changed, it will show as a
    " deletion *and* addition.
    let added = matchstr(line, '+\zs[0-9,]\+')
    if added =~# ','
      let parts = map(split(added, ','), 'str2nr(v:val)')
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


function! wstrip_changed#clean() abort
  if !s:cleanable()
    return
  endif

  let view = winsaveview()
  for group in s:get_diff_lines()
    execute join(group, ',').'s/\s\+$//e'
  endfor
  call histdel('search', -1)
  let @/ = histget('search', -1)
  call winrestview(view)
endfunction


function! wstrip_changed#auto() abort
  if get(b:, 'wstrip_auto', get(g:, 'wstrip_auto', 0))
    call wstrip_changed#clean()
  endif
endfunction


function! wstrip_changed#syntax() abort
  if s:cleanable() && get(b:, 'wstrip_highlight', get(g:, 'wstrip_highlight', 1))
    syntax match TrailingWhiteSpace /\s\+$/ containedin=ALL
  endif
endfunction
