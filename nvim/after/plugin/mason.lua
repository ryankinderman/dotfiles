require("mason").setup()

require("mason-lspconfig").setup()

require("mason-lspconfig").setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    --function (server_name) -- default handler (optional)
    --    require("lspconfig")[server_name].setup {}
    --end,
    -- Next, you can provide a dedicated handler for specific servers.
    ["lua_ls"] = function ()
      require('lspconfig').lua_ls.setup(
        require('lsp-zero').nvim_lua_ls()
      )
    end,

    ["jdtls"] = function ()
      local project_name = string.gsub(string.sub(vim.fn.getcwd(), 2, -1), "/", "--")
      local util = require 'lspconfig.util'
      local workspace_dir = util.path.join('nvim', 'nvim-jdtls-data', project_name)
      local env = {
        HOME = vim.loop.os_homedir(),
        XDG_CACHE_HOME = os.getenv 'XDG_CACHE_HOME',
      }
      local get_cache_dir = function()
        return env.XDG_CACHE_HOME and env.XDG_CACHE_HOME or util.path.join(env.HOME, '.cache')
      end

      -- See `nvim-lspconfig/lua/lspconfig/server_configurations/jdtls.lua` for more options
      require('lspconfig').jdtls.setup({
          cmd = {
            'jdtls',
            '-configuration', util.path.join(get_cache_dir(), 'config'),
            '-data', util.path.join(get_cache_dir(), workspace_dir),
          },
          --root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
      })
    end,
}
