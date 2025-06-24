require('lspconfig.ui.windows').default_options.border = 'single'

local pkl_lsp_jar = vim.fn.glob(vim.fn.stdpath('data') .. "/mason/packages/pkl-lsp" .. "/*.jar")

vim.g.pkl_neovim = {
  start_command = {
    os.getenv('JAVA24_HOME') .. "/bin/java", "-jar", pkl_lsp_jar }
}
