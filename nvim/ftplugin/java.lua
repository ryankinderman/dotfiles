vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true

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
    '--jvm-arg=-javaagent:' .. vim.fn.stdpath('data') .. '/mason/share/jdtls/lombok.jar',
    '-configuration', util.path.join(get_cache_dir(), 'jdtls-config'),
    '-data', util.path.join(get_cache_dir(), workspace_dir),
  },
  root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
  settings = {
    java = {
      configuration = {
        runtimes = vim.g.java_runtimes or {}
      },
      format = {
        settings = {
          url = util.path.join(
            os.getenv('DOTFILES'), 'eclipse-java-google-style.xml'),
        },
      },
    },
  },
}

local jdtls = require('jdtls')
jdtls.start_or_attach(config)

vim.keymap.set('n', '<A-o>', function() jdtls.organize_imports() end, {
  ['buffer'] = true, ['noremap'] = true,
})
