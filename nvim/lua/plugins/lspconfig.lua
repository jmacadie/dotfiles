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
		vim.lsp.config("lua_ls", {
			on_attach = utils.on_attach,
		})
		vim.lsp.enable("lua_ls")

		vim.lsp.config("basedpyright", {
			on_attach = utils.on_attach,
			filetypes = { "python" },
		})
		vim.lsp.enable("basedpyright")

		vim.lsp.config("ruby_lsp", {
			on_attach = utils.on_attach,
			filetypes = { "ruby" },
		})
		vim.lsp.enable("ruby_lsp")

		vim.lsp.config("clangd", {
			on_attach = utils.on_attach,
		})
		vim.lsp.enable("clangd")
	end,
}
