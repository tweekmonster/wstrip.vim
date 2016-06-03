# wstrip-changed.vim

Strip trailing whitespace only on changed lines.  Inspired by question on
StackExchange's [Vi and Vim][1] website.


## Summary

This plugin provides a command that runs a `diff` of the buffer against the
buffer's existing file.  Only new lines are checked for trailing whitespace.


## Usage

The `StripChangedWhitespace` can be used manually or with an `autocmd`:

```vim
autocmd BufWritePre *.py StripChangedWhitespace
```

With the `autocmd` above, writing a file will strip whitespace from changed
lines.  If you want to preserve trailing whitespace, you can ignore the
`autocmd` by typing `:noa w` in the command line.  The next `:w` should leave
the trailing whitespace as long as nothing else on that line is changed.


## License

Copyright (c) 2016 Tommy Allen

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


[1]: http://vi.stackexchange.com/q/7959/5229
