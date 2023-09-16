-- Fuzzy Finder (files, lsp, etc)
return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- [[ Configure Telescope ]]
	-- See `:help telescope` and `:help telescope.setup()`
	config = function()
		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<C-u>"] = false,
						["<C-d>"] = false,
					},
				},
			},
		})

		local tb = require("telescope.builtin")
		local cbff = function()
			-- You can pass additional configuration to telescope to change theme, layout, etc.
			tb.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end
		-- See `:help telescope.builtin`
		vim.keymap.set("n", "<leader>?", tb.oldfiles, { desc = "[?] Find recently opened files" })
		vim.keymap.set("n", "<leader><space>", tb.buffers, { desc = "[ ] Find existing buffers" })
		vim.keymap.set("n", "<leader>/", cbff, { desc = "[/] Fuzzily search in current buffer" })
		vim.keymap.set("n", "<leader>sf", tb.find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>sh", tb.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sw", tb.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "<leader>sg", tb.live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", tb.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sm", ":Telescope harpoon marks<CR>", { desc = "[S]earch Harpoon [M]arks" })
	end,
	keys = {
		-- See `:help telescope.builtin`
		{ "<leader>?" },
		{ "<leader><space>" },
		{ "<leader>/" },
		{ "<leader>sf" },
		{ "<leader>sh" },
		{ "<leader>sw" },
		{ "<leader>sg" },
		{ "<leader>sd" },
	},
}
