local lsp_zero = require('lsp-zero.setup')

--local cmp = require('cmp')
--cmp.setup({
--  mapping = cmp.mapping.preset.insert({
--    ['<C-Space>'] = cmp.mapping.complete(),
--    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
--    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
--    ['<C-d>'] = cmp.mapping.scroll_docs(4),
--  })
--})
--
--lsp_zero.on_attach(function(client, bufnr)
--  -- see :help lsp-zero-keybindings to learn the available actions
--  lsp_zero.default_keymaps({buffer = bufnr})
--
--  --local opts = {buffer = bufnr, remap = false}
--
--  --vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
--end)
--
require('lspconfig.ui.windows').default_options.border = 'single'
