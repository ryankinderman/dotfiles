" Gets loaded before Vim-provided filetypes, so setfiletype can be used here
" to override default filetype settings.
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au BufRead,BufNewFile *.cljx,*.cljs setfiletype clojure
  au BufRead,BufNewFile *.feature setfiletype cucumber
  au BufRead,BufNewFile *.as setfiletype actionscript
  au BufRead,BufNewFile Capfile*,Gemfile,*.pdf.prawn,Vagrantfile*,*.thor setfiletype ruby
  au BufRead,BufNewFile *.wsdl setfiletype xml
  au BufRead,BufNewFile *.html.mustache setfiletype html
  au BufRead,BufNewFile *.json setfiletype javascript
  au BufRead,BufNewFile todo.txt setfiletype markdown
  au BufRead,BufNewFile *.txt setfiletype text
  au BufRead,BufNewFile Jenkinsfile setfiletype groovy
  au BufRead,BufNewFile Dockerfile.* setfiletype dockerfile
  au BufRead,BufNewFile *.confluencewiki setfiletype confluencewiki
  au BufRead,BufNewFile nginx.conf setfiletype nginx
  au BufRead,BufNewFile *.tpl setfiletype gotexttmpl
augroup END
