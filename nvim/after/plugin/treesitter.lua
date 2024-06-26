require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = {
    "c", "lua", "javascript", "typescript", "ruby", "vim", "vimdoc",
    "query", "ruby", "python", "java", "clojure", "css", "go", "html",
    "markdown_inline", "sql", "pkl",
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
  },
}

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.api.nvim_create_autocmd({"BufReadPost", "FileReadPost"}, {
  pattern = "*",
  -- NOTE: the 'zx' is to work around some bug in telescope: <https://github.com/nvim-telescope/telescope.nvim/issues/699>
  command = "normal zx zR",
})
