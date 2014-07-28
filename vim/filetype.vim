" Gets loaded before Vim-provided filetypes, so setfiletype can be used here
" to override default filetype settings.
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au BufRead,BufNewFile *.cljx,*.cljs setfiletype clojure
  au BufRead,BufNewFile *.feature setfiletype cucumber
  au BufRead,BufNewFile *.as setfiletype actionscript
  au BufRead,BufNewFile Gemfile,*.pdf.prawn setfiletype ruby
  au BufRead,BufNewFile *.wsdl setfiletype xml
  au BufRead,BufNewFile *.html.mustache setfiletype html
  au BufRead,BufNewFile *.json setfiletype javascript
  au BufRead,BufNewFile *.txt setfiletype text
augroup END
