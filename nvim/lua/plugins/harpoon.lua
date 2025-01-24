return {
	"ThePrimeagen/harpoon",
	enabled = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		local ui = require("harpoon.ui")
		local mark = require("harpoon.mark")
		harpoon.setup({
			global_settings = {
				mark_branch = true,
			},
		})
		vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "[H]arpoon [A]dd Mark" })
		vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "[H]arpoon toggle Quick Menu" })
		vim.keymap.set("n", "<leader>hn", ui.nav_next, { desc = "[H]arpoon [N]ext" })
		vim.keymap.set("n", "<leader>hp", ui.nav_prev, { desc = "[H]arpoon [P]revious" })
		vim.keymap.set("n", "<leader>h1", function()
			ui.nav_file(1)
		end, { desc = "[H]arpoon File [1]" })
		vim.keymap.set("n", "<leader>h2", function()
			ui.nav_file(2)
		end, { desc = "[H]arpoon File [2]" })
		vim.keymap.set("n", "<leader>h3", function()
			ui.nav_file(3)
		end, { desc = "[H]arpoon File [3]" })
		vim.keymap.set("n", "<leader>h4", function()
			ui.nav_file(4)
		end, { desc = "[H]arpoon File [4]" })
	end,
}
