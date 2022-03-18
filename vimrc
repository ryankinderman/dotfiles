" Prevent loading of logipat plugin, since it overrides netrw's :E and I never
" use logipat
let loaded_logipat = 1

" Add all directories under $DOTFILES/vim/vendor as runtime paths, so plugins,
" docs, colors, and other runtime files are loaded.
let vendorpaths = globpath("$DOTFILES/vim", "vendor/*")

let vendorruntimepaths = substitute(vendorpaths, "\n", ",", "g")
execute "set runtimepath^=$DOTFILES/vim,".vendorruntimepaths

let vendorpathslist = split(vendorpaths, "\n")
for vendorpath in vendorpathslist
  if isdirectory(vendorpath."/doc")
    execute "helptags ".vendorpath."/doc"
  endif
endfor

set packpath+=$DOTFILES/vim

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set nobackup
set nowritebackup
set noswapfile
set history=50		" keep 50 lines of command line history
set ruler		      " show the cursor position all the time
set showcmd		    " display incomplete commands
set incsearch		  " do incremental searching
set vb            " turn on visual bell
set nu            " show line numbers
set sw=2          " set shiftwidth to 2
set ts=2          " set number of spaces for a tab to 2
set et            " expand tabs to spaces
set display=lastline " show as much as possible of the last line if it's too long to fit completely in the window
set wildignore=*.class,*/tmp/*
set nomodeline


" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")


" Key mappings ****************************************************************
" Easily open and reload vimrc
"<Leader>v brings up my .vimrc
"<Leader>V reloads it -- making all changes active (have to save first)
map <Leader>v :sp $DOTFILES/vimrc<CR>
map <silent> <Leader>V :source $HOME/.vimrc<CR>:if has("gui")<CR>:source $HOME/.gvimrc<CR>:endif<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" In command-mode, typing %/ will replace those chars with the directory of
" the file in the current buffer
cmap %/ <C-r>=expand('%:p:h')<CR>/

" execute current line as shell command, and open output in new window
map <Leader>x :silent . w ! sh > ~/.vim_cmd.out<CR>:new ~/.vim_cmd.out<CR>

" Emacs-like command-mode cursor navigation
cnoremap <C-a> <Home>
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>
cnoremap <Esc>b <S-Left>
cnoremap <Esc>f <S-Right>


" Sessions ********************************************************************
set sessionoptions=blank,buffers,curdir,folds,help,options,resize,tabpages,winpos,winsize,globals

function! AutosaveSessionOn(session_file_path)
  augroup AutosaveSession
    au!
    exec "au VimLeave * mks! " . a:session_file_path
  augroup end
  let g:AutosaveSessionFilePath = a:session_file_path

  echo "Auto-saving sessions to \"" . a:session_file_path . "\""
endfunction
function! AutosaveSessionOff()
  if exists("g:AutosaveSessionFilePath")
    unlet g:AutosaveSessionFilePath
  endif

  augroup AutosaveSession
    au!
  augroup end
  augroup! AutosaveSession

  echo "Auto-saving sessions is off"
endfunction
command! -complete=file -nargs=1 AutosaveSessionOn call AutosaveSessionOn(<f-args>)
command! AutosaveSessionOff call AutosaveSessionOff()
augroup AutosaveSession
  au!
  au SessionLoadPost * if exists("g:AutosaveSessionFilePath") != 0|call AutosaveSessionOn(g:AutosaveSessionFilePath)|endif
augroup end


" Text formatting ********************************************************************
function! WordWrap(state)
  if a:state == "on"
    set lbr
  else
    set nolbr
  end
endfunction
com! WW call WordWrap("on")
com! Ww call WordWrap("off")


" White space ****************************************************************
let hiExtraWhiteSpace = "hi ExtraWhitespace ctermbg=red guibg=red"
exec hiExtraWhiteSpace
au ColorScheme * exec hiExtraWhiteSpace
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au BufRead,InsertLeave * match ExtraWhitespace /\s\+$/


" Markdown *******************************************************************
function! PreviewMKD()
  let tmpfile = tempname()
  exe "write! " tmpfile
  exe "silent !preview_mkd " tmpfile
  exe "redraw!"
endfunction
autocmd FileType markdown map <buffer> <Leader>p :call PreviewMKD()<CR>
autocmd FileType markdown call WordWrap("on")
autocmd FileType markdown set noet


" Folding *********************************************************************
function! EnableFolding()
  set foldcolumn=2
  set foldenable
endfunction
function! DisableFolding()
  set foldcolumn=0
  set nofoldenable
endfunction
set foldmethod=syntax
call DisableFolding()
function! FoldLevelSpaces(lnum)
  let line = getline(a:lnum)
  let cnt = 2
  let pos = match(line, " ")
  while pos != -1
    let cnt = cnt + 1
    let pos = match(line, " ", pos + 1)
  endwhile
  return cnt/&tabstop
endfunction


" Netrw
" commented out below line because it was causing netrw buffers to show as
" modified and give warning: 'E162: No write since last change for buffer
" \"NetrwTreeListing 1\"'. With the same config, this behavior was observed on
" Linux using vim 8.0.1453, but not on Mac using vim 8.0.1283. So, this could
" have something to do with the vim version, compile options, etc., but doesn't
" seem to be an issue with the config itself.
"let g:netrw_liststyle=3
let g:netrw_browse_split=0
let g:netrw_list_hide='^\..*\.swp$'
let g:netrw_altv=1


" File operations

"" :Save will escape a file name that contains e.g. spaces and write it
"" Note: This is useful because the vim :save command does not handle spaces in
"" file names.
function Save(bang, filename)
  exe "save".a:bang." ". fnameescape(a:filename)
endfu
command -bang -nargs=* Save :call Save(<q-bang>, <q-args>)


" Command-T
let g:CommandTMaxFiles=80085
let g:CommandTMaxHeight=20
let g:CommandTScanDotDirectories=1
let g:CommandTTraverseSCM='pwd'


" VimClojure
let g:vimclojure#ParenRainbow=1


" Copy/paste *****************************************************************

let copy_cmd = ""
if system("which pbcopy") != ""
  " On a Mac with pbcopy command
  let copy_cmd = "pbcopy"
elseif system("which xclip") != ""
  let copy_cmd = "xclip -i -selection clipboard"
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


" Tab titles *****************************************************************
" Useful examples at:
" http://vim.wikia.com/wiki/Show_tab_number_in_your_tab_line

if exists("+showtabline")
  function! MyTabLine()
    let s = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
      let buflist = tabpagebuflist(i)
      let winnr = tabpagewinnr(i)
      let m = 0
      for b in buflist
        if getbufvar(b, "&modified")
          let m += 1
        endif
      endfor
      let s .= '%' . i . 'T'
      let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
      let s .= ' '
      let s .= i . ':'
      if m > 0
        let s .= '+'
      endif
      let s .= ' '
      let buf = buflist[winnr - 1]
      let buftype = getbufvar(buf, "&buftype")
      let file = bufname(buf)
      let file = fnamemodify(file, ':p:t')
      if buftype == 'help'
        let s .= '[Help] '
      elseif buftype == 'quickfix'
        if empty(getloclist(winnr))
          let s .= '[Quickfix List]'
        else
          let s .= '[Location List]'
        endif
      elseif file == ''
        let s .= '[No Name]'
      endif
      let s .= file
      let s .= ' '
      let i = i + 1
    endwhile
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s
  endfunction
  set tabline=%!MyTabLine()
endif


" Colors *********************************************************************
if has("gui_running") || &t_Co == 256
  colorscheme jellybeans-ryan
else
  set bg=dark
end
function! GetColorSchemes()
  let colorschemes = {}

  for rtpath in split(&runtimepath, ",")
    let colorscheme_files = split(glob(rtpath . "/colors/*.vim"), "\n")
    for colorscheme_file in colorscheme_files
      let colorname = substitute(colorscheme_file, "^.*/\\([^/]\\+\\)\\.vim$", "\\1", "")
      let colorschemes[colorname] = colorscheme_file
    endfor
  endfor

  return colorschemes
endfunction
function! FListColorSchemes()
  new
  call append(0, keys(GetColorSchemes()))
  delete
  0
  setlocal nomodified nomodifiable bufhidden=delete nonumber nowrap foldcolumn=0 nofoldenable
  nnoremap <buffer> <silent> q    :<C-U>bdelete<CR>
  nnoremap <buffer> <silent> <CR> :<C-U>set t_Co=256<CR>:hi clear<CR>:if exists("syntax_on")<CR>:syntax reset<CR>:endif<CR>:exe "colorscheme ".getline('.')<CR>
  ":<C-U>
endfunction
command! ListColorSchemes call FListColorSchemes()
