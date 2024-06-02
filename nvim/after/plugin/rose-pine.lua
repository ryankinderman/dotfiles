require('rose-pine').setup(
{
  dim_inactive_windows = true,

  highlight_groups = {
    Normal = { bg = 'none' },
    Folded = { fg = 'subtle' },
    Search = { bg = 'highlight_med', inherit = false },
  },
})

-- Set colorscheme after options
vim.cmd('colorscheme rose-pine')
