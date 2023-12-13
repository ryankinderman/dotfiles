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

    ["gopls"] = function ()
      require('lspconfig').gopls.setup({})
    end,

    ["pyright"] = function ()
      require('lspconfig').pyright.setup({
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "off"
            }
          }
        }
      })
    end,

    ["tsserver"] = function ()
      require('lspconfig').tsserver.setup({})
    end,
}
