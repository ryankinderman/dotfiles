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
set laststatus=2
set wildignore=*.class,*/tmp/*
set switchbuf=uselast " this is the default, but need to configure here explicitly because command-t sets it to something else if its not set
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
let g:netrw_home="$HOME/.vim"


" File operations

"" :Save will escape a file name that contains e.g. spaces and write it
"" Note: This is useful because the vim :save command does not handle spaces in
"" file names.
function Save(bang, filename)
  exe "save".a:bang." ". fnameescape(a:filename)
endfu
command -bang -nargs=* Save :call Save(<q-bang>, <q-args>)


" Command-T
let g:CommandTMaxFiles=1000000
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

au InsertLeave * set nopaste


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
let g:jellybeans_overrides = {
\ 'background': { 'ctermbg': 'none', '256ctermbg': 'none' },
\}
if has('termguicolors') && &termguicolors
  let g:jellybeans_overrides['background']['guibg'] = 'none'
endif

colorscheme jellybeans
"if has("gui_running") || &t_Co == 256
"else
"  set bg=dark
"end
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

if has('python3') && $POWERLINE_ROOT != ""
  set noshowmode " because powerline already provides this info

  python3 from powerline.vim import setup as powerline_setup
  python3 powerline_setup()
  python3 del powerline_setup
endif

" golang stuff ***************************************************************

let g:go_doc_popup_window = 1
let g:go_def_split_same_buffer = 1
au FileType go nmap <Leader>ds <Plug>(go-def-split)
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>dt <Plug>(go-def-tab)


" CoC

function! CheckBackspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" " Use `:CocDiagnostics` to get all diagnostics of current buffer in location
" list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for apply code actions at the cursor position.
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer.
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for apply refactor code actions.
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')
