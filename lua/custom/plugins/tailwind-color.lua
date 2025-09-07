return {
  'themaxmarchuk/tailwindcss-colors.nvim',
  config = function()
    local nvim_lsp = require 'lspconfig'

    local on_attach = function(client, bufnr)
      -- other stuff --
      require('tailwindcss-colors').buf_attach(bufnr)
    end

    nvim_lsp['tailwindcss'].setup {
      -- other settings --
      on_attach = on_attach,
    }
  end,
  -- Disable the plugin temporarily to avoid deprecation warnings
  -- until the plugin is updated to use the newer API
  enabled = false,
}
