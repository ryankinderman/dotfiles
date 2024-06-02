require('rose-pine').setup(
{
  dim_inactive_windows = true,

  highlight_groups = {
    Folded = { fg = 'subtle' }
  },
})

-- Set colorscheme after options
vim.cmd('colorscheme rose-pine')
