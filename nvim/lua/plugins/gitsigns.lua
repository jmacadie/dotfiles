-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
	"lewis6991/gitsigns.nvim",
	opts = {
		-- See `:help gitsigns.txt`
		signs = {
			add = { text = "│" },
			change = { text = "󱋱" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		on_attach = function(bufnr)
			local gs = require("gitsigns")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "]c", function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(function()
					gs.next_hunk()
					vim.cmd("normal! zz")
				end)
				return "<Ignore>"
			end, { expr = true, desc = "Gitsigns: Next Hunk" })

			map("n", "[c", function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					gs.prev_hunk()
					vim.cmd("normal! zz")
				end)
				return "<Ignore>"
			end, { expr = true, desc = "Gitsigns: Previous Hunk" })

			map("n", "<leader>gp", gs.preview_hunk_inline, { desc = "[G]itsigns: [P]review hunk" })
			map("n", "<leader>gs", gs.stage_hunk, { desc = "[G]itsigns: [S]tage hunk" })
			map("n", "<leader>gr", gs.reset_hunk, { desc = "[G]itsigns: [R]eset hunk" })
			map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "[G]itsigns: [U]ndo stage hunk" })
			map("v", "<leader>gs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "[G]itsigns [S]tage line" })
			map("v", "<leader>gr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "[G]itsigns [R]eset line" })
		end,
	},
}
