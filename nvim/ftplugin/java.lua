local project_name = string.gsub(string.sub(vim.fn.getcwd(), 2, -1), "/", "--")
local workspace_dir = os.getenv('HOME') .. '/.local/share/nvim/nvim-jdtls/' .. project_name

local config = {
    cmd = {
      os.getenv('HOME') .. '/.local/share/nvim/mason/packages/jdtls/jdtls',
      '-data', workspace_dir,
    },
    --root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
}
require('jdtls').start_or_attach(config)

vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.bo.cindent = false
