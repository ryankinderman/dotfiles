require("mason").setup()

require("mason-lspconfig").setup({
  automatic_enable = {
    exclude = {
      -- This ensures that only nvim-jdtls is used to start a jdtls server
      "jdtls",
    }
  },
})

-- Per-server overrides live here, after mason-lspconfig's setup(), because
-- setup() applies its own vim.lsp.config() for some servers (e.g. gradle_ls)
-- and later calls win. Keeping them in this file avoids depending on the
-- load order of after/plugin/*.lua.
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off"
      }
    }
  }
})

-- mason-lspconfig sets gradle_ls's cmd to Mason's `gradle-language-server`
-- launcher while it is being set up (above). As of vscode-gradle 3.17.3 that
-- launcher no longer works: the server has no Main-Class manifest entry and
-- talks over a Unix socket instead of stdio. Override it afterwards (later
-- vim.lsp.config() calls win) with a wrapper that bridges the socket to stdio.
vim.lsp.config("gradle_ls", {
  cmd = {
    vim.api.nvim_get_runtime_file("bin/gradle-language-server-stdio", false)[1],
    vim.fn.stdpath("data") .. "/mason/packages/gradle-language-server/extension/lib",
  },
})
