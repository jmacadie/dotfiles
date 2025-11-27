-- Highlight, edit, and navigate code
return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	build = ":TSUpdate",
	config = function()
		local opts = {
			ensure_installed = {
				"json",
				"lua",
				"python",
				"ruby",
				"rust",
				"vimdoc",
				"vim",
			},

			-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
			auto_install = false,

			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn",
					node_incremental = "grn",
					scope_incremental = "grc",
					node_decremental = "grm",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["ai"] = "@conditional.outer",
						["ii"] = "@conditional.inner",
						["ak"] = "@block.outer",
						["ik"] = "@block.inner",
						["al"] = "@loop.outer",
						["il"] = "@loop.inner",
					},
					selection_modes = {
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "V", -- linewise
						["@block.outer"] = "V", -- linewise
					},
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]f"] = "@function.outer",
						["]]"] = "@class.outer",
						["]i"] = "@conditional.outer",
						["]k"] = "@block.outer",
						["]l"] = "@loop.outer",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[["] = "@class.outer",
						["[i"] = "@conditional.outer",
						["[k"] = "@block.outer",
						["[l"] = "@loop.outer",
					},
				},
				swap = {
					enable = true,
					swap_next = {
						["<leader>a"] = "@parameter.inner",
					},
					swap_previous = {
						["<leader>A"] = "@parameter.inner",
					},
				},
			},
			modules = {},
			sync_install = false,
			ignore_install = {},
		}
		require("nvim-treesitter.configs").setup(opts)

		local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

		-- Repeat movement with ; and ,
		-- vim way: ; goes to the direction you were moving.
		vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
		vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

		-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
		vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
	end,
}
