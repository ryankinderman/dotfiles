command E :Explore

" fugitive's :GBrowse falls back to netrw#BrowseX, which errors with E118 on
" this netrw/fugitive combo (BrowseX takes 1 arg, fugitive calls it with 2).
" Defining :Browse makes fugitive use this instead and skip netrw entirely.
function! s:OpenUrl(url) abort
  call jobstart(['open', a:url], {'detach': v:true})
endfunction
command! -nargs=1 Browse call s:OpenUrl(<q-args>)
