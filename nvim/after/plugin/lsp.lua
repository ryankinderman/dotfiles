local lsp = require('lsp-zero').preset({})

local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings to learn the available actions
  lsp.default_keymaps({buffer = bufnr})

  --local opts = {buffer = bufnr, remap = false}

  --vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
end)

-- (Optional) Configure lua language server for neovim
local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup(lsp.nvim_lua_ls())
lspconfig.jdtls.setup({})
require('lspconfig.ui.windows').default_options.border = 'single'

lsp.setup()
