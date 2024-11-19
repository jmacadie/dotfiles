return {
	"jecaro/fugitive-difftool.nvim",
	config = function()
		local fd = require("fugitive-difftool")

		vim.keymap.set(
			"n",
			"<leader>gcs",
			":Git! difftool --name-status ",
			{ desc = "Vim Fugative: [G]it [C]ompare [S]tart (provide your own refspec)" }
		)
		vim.keymap.set("n", "<leader>gcf", fd.git_cfir, { desc = "Vim Fugative: [G]it [C]ompare [F]irst" })
		vim.keymap.set("n", "<leader>gcl", fd.git_cla, { desc = "Vim Fugative: [G]it [C]ompare [F]irst" })
		vim.keymap.set("n", "<leader>gcn", fd.git_cn, { desc = "Vim Fugative: [G]it [C]ompare [F]irst" })
		vim.keymap.set("n", "<leader>gcp", fd.git_cp, { desc = "Vim Fugative: [G]it [C]ompare [F]irst" })
	end,
}
