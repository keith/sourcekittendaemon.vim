if !has('python')
  echoerr "SourceKittenDaemon.vim requires Vim compiled with +python"
  finish
endif

let s:plug = expand('<sfile>:p:h:h')
let s:python_version = 'python '
let s:pyfile_version = 'pyfile '

augroup sourcekittendaemon_complete
  autocmd!
  autocmd CompleteDone *.swift call s:CompletionFinished(v:completed_item)
augroup END

function! s:LoadPythonScript()
  if exists("s:loaded_sourcekittendaemon_python") && s:loaded_sourcekittendaemon_python
    return
  endif
  let s:loaded_sourcekittendaemon_python = 1

  let l:script = s:plug . "/pythonx/sourcekittendaemon.py"
  execute s:python_version . 'import sys'
  execute s:python_version . 'sys.path.append("' . s:plug . '")'
  execute s:pyfile_version . l:script
endfunction

function! s:GetByteOfLastDot()
  let line = line2byte(line("."))
  let [lnum, col] = searchpos("\\.", "bn", line("."))
  return line + col
endfunction

function! s:CompletionFinished(item)
  let word = a:item["word"]
  if word !~ "("
    return
  endif

  let [lnum, col] = searchpos("(", "bn", line("."))
  call cursor(lnum, col + 1)
endfunction

function! sourcekittendaemon#Complete(findstart, base)
  if a:findstart
    let [lnum, col] = searchpos("\\.", "bn", line("."))
    return col
  endif

  update
  call s:LoadPythonScript()
  execute "python main(prefix = '" . a:base
        \ . "', path = '" . expand("%:p")
        \ . "', offset = " . s:GetByteOfLastDot() . ")"
  return s:result
endfunction
