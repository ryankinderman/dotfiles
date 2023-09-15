" Copy/paste *****************************************************************

let copy_cmd = ""
if system("which pbcopy") !~ "not found"
  " On a Mac with pbcopy command
  let copy_cmd = "pbcopy"
elseif system("which xclip") !~ "not found"
  let copy_cmd = "xclip -i -selection clipboard"
elseif system("which clip.exe") !~ "not found"
  let copy_cmd = "clip.exe"
end

if copy_cmd != ""
  function! CopyToWindowManagerClipboard(type, copy_cmd, ...)
    " This logic is mostly lifted from :help E775
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@

    if a:type == "range"
      let @@ = join(getline(a:1,a:2), "\n")
    elseif a:0  " Invoked from Visual mode, use '< and '> marks.
      silent exe "normal! `<" . a:type . "`>y"
    elseif a:type == "command"
      let @@ = getline(".")
    elseif a:type == "line"
      silent exe "normal! '[V']y"
    elseif a:type == "block"
      silent exe "normal! `[\<C-V>`]y"
    else
      silent exe "normal! `[v`]y"
    end

    call system(a:copy_cmd, @@)

    let &selection = sel_save
    let @@ = reg_save
  endfunction

  vmap <silent> Y :<C-U>call CopyToWindowManagerClipboard(visualmode(), copy_cmd, 1)<CR>
  map <Leader>yy :call CopyToWindowManagerClipboard("command", copy_cmd)<CR>
  com! -range Y call CopyToWindowManagerClipboard("range",copy_cmd,<line1>,<line2>)
end

au InsertLeave * set nopaste
