-- Note: `brew install fd` to exclude files in list that are in `.gitignore`, e.g. `.class` files in Java
require('telescope').setup({
  defaults = {
    wrap_results = true,
  },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>t', builtin.find_files, {})
