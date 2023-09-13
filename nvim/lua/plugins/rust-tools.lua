local utils = require 'plugins.lsp.util'

return {
  "simrat39/rust-tools.nvim",
  ft = "rust",
  dependencies = "neovim/nvim-lspconfig",
  opts = function ()
    local keymap = vim.keymap.set

    return {
      server = {
        on_attach = function(client, bufnr)
          utils.on_attach(client, bufnr)
          local rt = require "rust-tools"
          keymap("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
          -- keymap("n", "<leader>rr", rt.runnables.runnables(), { buffer = bufnr })
        end,
        capabilities = utils.capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      },
    }
  end,
  config = function (_, opts)
    require("rust-tools").setup(opts)
  end,
}
