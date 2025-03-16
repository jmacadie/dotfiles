-- [[ Configure LSP ]]
---@module "lspconfig"

local utils = require("plugins.lsp.util")

-- NOTE: This is where your plugins related to LSP can be installed.
--  The configuration is done below. Search for lspconfig to find it below.
return {
	-- LSP Configuration & Plugins
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"j-hui/fidget.nvim",
		-- "folke/neodev.nvim",
		"saghen/blink.cmp",
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
		{ -- optional blink completion source for require statements and module annotations
			"saghen/blink.cmp",
			opts = {
				sources = {
					-- add lazydev to your completion providers
					default = { "lazydev", "lsp", "path", "snippets", "buffer" },
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							-- make lazydev completions top priority (see `:h blink.cmp`)
							score_offset = 100,
						},
					},
				},
			},
		},
	},
	config = function()
		local lsp = require("lspconfig")

		lsp.lua_ls.setup({
			on_attach = utils.on_attach,
			capabilities = utils.capabilities,
		})

		lsp.basedpyright.setup({
			on_attach = utils.on_attach,
			capabilities = utils.capabilities,
			filetypes = { "python" },
		})

		-- lsp.pyright.setup({
		-- 	on_attach = utils.on_attach,
		-- 	capabilities = utils.capabilities,
		-- 	filetypes = { "python" },
		-- })

		lsp.ruby_lsp.setup({
			on_attach = utils.on_attach,
			capabilities = utils.capabilities,
			filetypes = { "ruby" },
		})

		lsp.clangd.setup({
			on_attach = utils.on_attach,
			capabilities = utils.capabilities,
		})
	end,
}
