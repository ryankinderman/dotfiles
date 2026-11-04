-- In command-mode, typing %/ will replace those chars with the directory of
-- the file in the current buffer
vim.keymap.set('c', '%/', '<C-r>=expand(\'%:p:h\')<CR>/')

-- Copy a reference to the current line to the system clipboard, in the form
-- "+<line> <path>". That's the syntax `:edit` takes for its +cmd argument, so
-- pasting it after `:e ` opens the file at that line:
--
--   :e +42 src/Foo.java
--
-- The same string also works from a shell: `nvim +42 src/Foo.java`.
--
-- Notes:
--   * The path is relative to Neovim's working directory, so the reference only
--     opens correctly if you're in the same directory when you use it. Use
--     vim.fn.expand("%:p") for an absolute path.
--   * The path is escaped with fnameescape() for Vim's command line, not for a
--     shell, so a path with spaces needs quoting if you use it in a shell.
--   * Only the start line is supported. :edit has no syntax for a line range.
--   * Paste on the command line with <C-r>+ (or <C-r>" if you yanked into the
--     unnamed register).
vim.keymap.set("n", "<leader>yl", function()
  local ref = "+" .. vim.fn.line(".") .. " " .. vim.fn.fnameescape(vim.fn.expand("%"))
  vim.fn.setreg("+", ref)
  print("Copied " .. ref)
end)

-- Same as <leader>yl above, but for the whole file
vim.keymap.set("n", "<leader>yf", function()
  local ref = vim.fn.fnameescape(vim.fn.expand("%"))
  vim.fn.setreg("+", ref)
  print("Copied " .. ref)
end)
