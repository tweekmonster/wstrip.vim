" Group a consecutive sequence of lines
function! s:line_groups(lines) abort
  if empty(a:lines)
    return []
  endif

  let start_line = a:lines[0]
  let prev_line = a:lines[0]
  let groups = []

  for l in a:lines
    if l == prev_line || l - 1 == prev_line
      let prev_line = l
    else
      call add(groups, [start_line, prev_line])
      let start_line = l
      let prev_line = l
    endif
  endfor

  call add(groups, [start_line, prev_line])
  return groups
endfunction


function! wstrip_changed#clean() abort
  let bfile = expand('%')
  if empty(bfile) || !filereadable(bfile)
    let lines = range(1, line('$'))
  else
    let lines = systemlist("diff --unchanged-line-format='' --old-line-format='' "
          \ . "--new-line-format='%dn\n' '".bfile."' -", getline(1, '$') + [''])
  endif

  if empty(lines)
    return
  endif

  let view = winsaveview()
  for group in s:line_groups(lines)
    execute join(group, ',').'s/\s\+$//e'
  endfor
  call histdel('search', -1)
  let @/ = histget('search', -1)
  call winrestview(view)
endfunction
