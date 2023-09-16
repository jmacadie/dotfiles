-- [[ Configure LSP ]]

local utils = require("plugins.lsp.util")

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- NOTE: This is where your plugins related to LSP can be installed.
--  The configuration is done below. Search for lspconfig to find it below.
return {
	-- LSP Configuration & Plugins
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"j-hui/fidget.nvim",
		"folke/neodev.nvim",
	},
	config = function()
		local lsp = require("lspconfig")

		lsp.lua_ls.setup({
			on_attach = utils.on_attach,
			capabilities = utils.capabilities,
			settings = require("plugins.lsp.lua-ls"),
		})

		lsp.pyright.setup({
			on_attach = utils.on_attach,
			capabilities = utils.capabilities,
			filetypes = { "python" },
		})
	end,
}
