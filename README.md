# wstrip.vim

Strip trailing whitespace only on changed lines.  Inspired by question on
StackExchange's [Vi and Vim][1] website.


## Summary

This plugin uses `git-diff` to strip whitespace from lines that you changed
while editing.  This allows you to keep newly added lines clean without
affecting the history of existing lines.

If the file is not in a `git` repository, `diff` is used to make a simple
comparison against the existing file on disk.


## Usage

Whitespace can be automatically stripped when writing the buffer by setting
`g:wstrip_auto` or `b:wstrip_auto` to `1`.  This is disabled by default.

```vim
" Globally enabled for all filetypes
let g:wstrip_auto = 1  

" Just certain filetypes
autocmd FileType *.css,*.py let b:wstrip_auto = 1  
```

If you don't want automatic cleaning, the `:WStrip` command can be used to
manually clean whitespace.

Trailing whitespace will be highlighted using the `WStripTrailing` syntax
group.  If it appears that Vim is capable of underlining text, trailing
whitespace will be highlighted as a red underline.  Otherwise, it will
highlighted with a red background.  To disable highlighting, set
`b:wstrip_highlight` or `g:wstrip_highlight` to `0`.

If you want to allow a certain amount of trailing whitespace, you can set
`b:wstrip_trailing_max` to the maximum number of whitespace characters that are
allowed to be at the end of a line.  By default, this is set to `2` for the
`markdown` filetype.


## License

MIT

[1]: http://vi.stackexchange.com/q/7959/5229
