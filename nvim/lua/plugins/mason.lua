return {
	"williamboman/mason.nvim",
	config = function()
		vim.keymap.set("n", "<leader>m", vim.cmd.Mason, { desc = "[M] ason package manager" })
		require("mason").setup({
			registries = {
				"github:mason-org/mason-registry",
				"github:Crashdummyy/mason-registry",
			},
			ensure_installed = {
				-- Python
				"pyright",
				"ruff",
				-- Rust
				"rust-analyzer",
				-- Lua
				"stylua",
			},
		})
	end,
}
