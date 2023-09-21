local lsp_zero = require('lsp-zero')

local cmp_config = require('cmp.config')
local cmp_keymap = require('cmp.utils.keymap')
cmp_config.global.mapping[cmp_keymap.normalize('<C-p>')] = nil
cmp_config.global.mapping[cmp_keymap.normalize('<C-n>')] = nil

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})

  --local opts = {buffer = bufnr, remap = false}

  --vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
end)

require('lspconfig.ui.windows').default_options.border = 'single'
