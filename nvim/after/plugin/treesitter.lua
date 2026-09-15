require('nvim-treesitter').install {
  "c", "lua", "javascript", "typescript", "ruby", "vim", "vimdoc",
  "query", "python", "java", "clojure", "css", "go", "html",
  "markdown_inline", "sql", "pkl",
}

-- Highlighting and indentation are no longer set up via `setup{}` on the
-- new `main` branch; they must be started per-buffer.
-- markdown is excluded: vim-markdown's own indent/markdown.vim (GetMarkdownIndent)
-- handles list continuation, and would otherwise get clobbered here.
local skip_indentexpr_ft = { markdown = true }

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    local ok = pcall(vim.treesitter.start)
    if ok and not skip_indentexpr_ft[args.match] then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.api.nvim_create_autocmd({"BufReadPost", "FileReadPost"}, {
  pattern = "*",
  -- NOTE: the 'zx' is to work around some bug in telescope: <https://github.com/nvim-telescope/telescope.nvim/issues/699>
  command = "normal zx zR",
})
