" Gets loaded before Vim-provided filetypes, so setfiletype can be used here
" to override default filetype settings.
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au BufRead,BufNewFile *.feature setfiletype cucumber
  au BufRead,BufNewFile *.as setfiletype actionscript
  au BufRead,BufNewFile *.markdown,*.mkd setfiletype mkd
augroup END