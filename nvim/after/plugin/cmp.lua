local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          -- fallback to normal vim completion
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
    {
      name = 'lazydev',
      group_index = 0,
    },
  }, {
    { name = 'buffer' }
  })
})
