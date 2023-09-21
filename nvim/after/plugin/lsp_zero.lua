local lsp_zero = require('lsp-zero')

--local cmp_config = require('cmp.config')
--local cmp_keymap = require('cmp.utils.keymap')
--cmp_config.global.mapping[cmp_keymap.normalize('<C-p>')] = nil
--cmp_config.global.mapping[cmp_keymap.normalize('<C-n>')] = nil
local cmp = require('cmp')
--print(debug.getinfo(cmp.config.sources).source)
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
      }),
    ['<C-n>'] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
      }),
  }),

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    -- use buffer completion if no lsp
    { name = 'buffer' },
  }),
})

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})

  --local opts = {buffer = bufnr, remap = false}

  --vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
end)

require('lspconfig.ui.windows').default_options.border = 'single'
