setlocal shiftwidth=4
setlocal tabstop=4
setlocal expandtab
if $JDK_SRC_CTAGS_PATH != ""
  set tags+=$JDK_SRC_CTAGS_PATH
endif
