return {
	"williamboman/mason.nvim",
	config = function()
		vim.keymap.set("n", "<leader>m", vim.cmd.Mason, { desc = "[M] ason package manager" })
		require("mason").setup({
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
