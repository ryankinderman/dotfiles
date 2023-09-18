-- In command-mode, typing %/ will replace those chars with the directory of
-- the file in the current buffer
vim.keymap.set('c', '%/', '<C-r>=expand(\'%:p:h\')<CR>/')
