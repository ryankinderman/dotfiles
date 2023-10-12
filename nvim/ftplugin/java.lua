vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.bo.cindent = false

local project_name = string.gsub(string.sub(vim.fn.getcwd(), 2, -1), "/", "--")
local util = require 'lspconfig.util'
local workspace_dir = util.path.join('jdtls-data', project_name)
local env = {
  HOME = vim.loop.os_homedir(),
  XDG_CACHE_HOME = os.getenv 'XDG_CACHE_HOME',
}
local get_cache_dir = function()
  return util.path.join(
    (env.XDG_CACHE_HOME and env.XDG_CACHE_HOME or util.path.join(env.HOME, '.cache')),
    'nvim')
end

-- See `nvim-lspconfig/lua/lspconfig/server_configurations/jdtls.lua` for more options
local config = {
  cmd = {
    'jdtls',
    '-configuration', util.path.join(get_cache_dir(), 'jdtls-config'),
    '-data', util.path.join(get_cache_dir(), workspace_dir),
  },
  --root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
}

local jdtls = require('jdtls')
jdtls.start_or_attach(config)

vim.keymap.set('n', '<A-o>', function() jdtls.organize_imports() end, {
  ['buffer'] = true, ['noremap'] = true,
})
