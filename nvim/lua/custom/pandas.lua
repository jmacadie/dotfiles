M = {}

-- https://github.com/igorlfs/nvim-dap-view/blob/0a7e6395f5bdb79cee233cebd99639713b0a0de2/lua/dap-view/options/winbar.lua#L45
-- https://github.com/mfussenegger/nvim-dap/blob/master/lua/dap/repl.lua#L92
-- https://github.com/mfussenegger/nvim-dap/blob/master/doc/dap.txt#L955
--

M.open = function()
	local dap = require("dap")

	-- Create a new floater
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)
	local winopts = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		border = "rounded",
		style = "minimal",
	}
	local scratch_buf = vim.api.nvim_create_buf(false, true)
	local winnr = vim.api.nvim_open_win(scratch_buf, true, winopts)

	local bufnr = dap.repl.open(nil, "lua vim.api.nvim_set_current_win(" .. winnr .. ")")

	dap.repl.execute("df = self.cash")
	dap.repl.clear()
	dap.repl.execute("print(df.T)")

	vim.keymap.set("n", "q", function()
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end)

	vim.keymap.set("n", "z", function()
		dap.repl.execute("df = df[(df != 0).any(axis=1)]")
		dap.repl.clear()
		dap.repl.execute("print(df.T)")
	end)
end

return M
