-- Fuzzy Finder (files, lsp, etc)
return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local actions = require("telescope.actions")
		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<C-u>"] = false,
						["<C-d>"] = actions.delete_buffer + actions.move_to_top,
					},
				},
			},
		})

		local tb = require("telescope.builtin")
		local tt = require("telescope.themes")
		local mg = require("custom.multigrep")
		local cbff = function()
			tb.current_buffer_fuzzy_find(tt.get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end
		local spell = function()
			tb.spell_suggest(tt.get_cursor({}))
		end
		vim.keymap.set("n", "<leader><space>", tb.buffers, { desc = "[ ] Find existing buffers" })
		vim.keymap.set("n", "<leader>/", cbff, { desc = "[/] Fuzzily search in current buffer" })
		vim.keymap.set("n", "<leader>sf", tb.find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>sj", tb.jumplist, { desc = "[S]earch [J]ump List" })
		vim.keymap.set("n", "<leader>sq", tb.registers, { desc = "[S]earch [q] Registers / Macros" })
		vim.keymap.set("n", "<leader>sc", tb.oldfiles, { desc = "[S]earch [C]urrent Files" })
		vim.keymap.set("n", "<leader>sa", function()
			tb.find_files({ hidden = true, no_ignore = true })
		end, { desc = "[S]earch [A]ll files" })
		vim.keymap.set("n", "<leader>sh", tb.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sw", tb.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "<leader>sg", mg.live_multigrep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", tb.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>st", tb.builtin, { desc = "[S]earch [T]elescope" })
		vim.keymap.set("n", "<leader>ss", tb.resume, { desc = "[S]earch Re[s]umes" })
		vim.keymap.set("n", "<leader>sp", spell, { desc = "[SP]elling suggestions" })
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
