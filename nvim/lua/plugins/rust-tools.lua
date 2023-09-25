local utils = require("plugins.lsp.util")

return {
	"simrat39/rust-tools.nvim",
	ft = "rust",
	dependencies = "neovim/nvim-lspconfig",
	opts = function()
		local keymap = vim.keymap.set

		return {
			server = {
				on_attach = function(client, bufnr)
					utils.on_attach(client, bufnr)
					local rt = require("rust-tools")
					local ls = require("luasnip")
					keymap({ "i", "s" }, "<C-u>", function()
						if ls.expand_or_jumpable() then
							ls.expand_or_jump()
						end
					end, { buffer = bufnr, silent = true })

					keymap({ "i", "s" }, "<C-i>", function()
						if ls.jumpable(-1) then
							ls.jump(-1)
						end
					end, { buffer = bufnr, silent = true })

					keymap("i", "<C-l>", function()
						if ls.choice_active() then
							ls.change_choice(1)
						end
					end, { buffer = bufnr })
					keymap("n", "<leader>rr", rt.runnables.runnables, { buffer = bufnr })
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
	config = function(_, opts)
		require("rust-tools").setup(opts)
	end,
}
