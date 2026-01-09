return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",

	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			config = function()
				-- 1) Configure plugin behaviour
				require("nvim-treesitter-textobjects").setup({
					select = {
						lookahead = true,
						selection_modes = {
							["@function.outer"] = "V",
							["@class.outer"] = "V",
							["@block.outer"] = "V",
						},
					},
					move = { set_jumps = true },
				})

				-- 2) Keymaps for textobjects
				local sel = require("nvim-treesitter-textobjects.select")
				vim.keymap.set({ "x", "o" }, "aa", function()
					sel.select_textobject("@parameter.outer", "textobjects")
				end, { desc = "Select outer parameter" })
				vim.keymap.set({ "x", "o" }, "ia", function()
					sel.select_textobject("@parameter.inner", "textobjects")
				end, { desc = "Select inner parameter" })
				vim.keymap.set({ "x", "o" }, "af", function()
					sel.select_textobject("@function.outer", "textobjects")
				end, { desc = "Select outer function" })
				vim.keymap.set({ "x", "o" }, "if", function()
					sel.select_textobject("@function.inner", "textobjects")
				end, { desc = "Select inner function" })
				vim.keymap.set({ "x", "o" }, "ac", function()
					sel.select_textobject("@class.outer", "textobjects")
				end, { desc = "Select outer class" })
				vim.keymap.set({ "x", "o" }, "ic", function()
					sel.select_textobject("@class.inner", "textobjects")
				end, { desc = "Select inner class" })
				vim.keymap.set({ "x", "o" }, "ai", function()
					sel.select_textobject("@conditional.outer", "textobjects")
				end, { desc = "Select outer conditional" })
				vim.keymap.set({ "x", "o" }, "ii", function()
					sel.select_textobject("@conditional.inner", "textobjects")
				end, { desc = "Select inner conditional" })
				vim.keymap.set({ "x", "o" }, "ak", function()
					sel.select_textobject("@block.outer", "textobjects")
				end, { desc = "Select outer block" })
				vim.keymap.set({ "x", "o" }, "ik", function()
					sel.select_textobject("@block.inner", "textobjects")
				end, { desc = "Select inner block" })
				vim.keymap.set({ "x", "o" }, "al", function()
					sel.select_textobject("@loop.outer", "textobjects")
				end, { desc = "Select outer loop" })
				vim.keymap.set({ "x", "o" }, "il", function()
					sel.select_textobject("@loop.inner", "textobjects")
				end, { desc = "Select inner loop" })

				-- 3) Move mappings
				local move = require("nvim-treesitter-textobjects.move")
				vim.keymap.set({ "n", "x", "o" }, "]f", function()
					move.goto_next_start("@function.outer", "textobjects")
				end, { desc = "Next function start" })
				vim.keymap.set({ "n", "x", "o" }, "]]", function()
					move.goto_next_start("@class.outer", "textobjects")
				end, { desc = "Next class start" })
				vim.keymap.set({ "n", "x", "o" }, "]i", function()
					move.goto_next_start("@conditional.outer", "textobjects")
				end, { desc = "Next conditional start" })
				vim.keymap.set({ "n", "x", "o" }, "]k", function()
					move.goto_next_start("@block.outer", "textobjects")
				end, { desc = "Next block start" })
				vim.keymap.set({ "n", "x", "o" }, "]l", function()
					move.goto_next_start("@loop.outer", "textobjects")
				end, { desc = "Next loop start" })
				vim.keymap.set({ "n", "x", "o" }, "[f", function()
					move.goto_previous_start("@function.outer", "textobjects")
				end, { desc = "Previous function start" })
				vim.keymap.set({ "n", "x", "o" }, "[[", function()
					move.goto_previous_start("@class.outer", "textobjects")
				end, { desc = "Previous class start" })
				vim.keymap.set({ "n", "x", "o" }, "[i", function()
					move.goto_previous_start("@conditional.outer", "textobjects")
				end, { desc = "Previous conditional start" })
				vim.keymap.set({ "n", "x", "o" }, "[k", function()
					move.goto_previous_start("@block.outer", "textobjects")
				end, { desc = "Previous block start" })
				vim.keymap.set({ "n", "x", "o" }, "[l", function()
					move.goto_previous_start("@loop.outer", "textobjects")
				end, { desc = "Previous loop start" })

				-- 4) Swap mappings
				local swap = require("nvim-treesitter-textobjects.swap")
				vim.keymap.set("n", "<leader>a", function()
					swap.swap_next("@parameter.inner")
				end, { desc = "Swap with next parameter" })
				vim.keymap.set("n", "<leader>A", function()
					swap.swap_previous("@parameter.inner")
				end, { desc = "Swap with previous parameter" })

				-- 5) Repeatable move
				local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
				vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
				vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
				vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
				vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
				vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
				vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
			end,
		},
	},

	config = function()
		local languages = { "json", "lua", "python", "ruby", "rust", "vimdoc", "vim" }
		require("nvim-treesitter").install(languages)

		local group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = languages,
			callback = function()
				vim.treesitter.start()
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = languages,
			callback = function()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
