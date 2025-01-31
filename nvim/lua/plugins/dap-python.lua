---@module "lazy"

---@type LazyPluginSpec
local dap_python = {
	"mfussenegger/nvim-dap-python",
	config = function()
		-- Assumes we are running inside an active virtual env
		-- For my current use case this is a Poetry shell
		require("dap-python").setup("python")
		require("dap-python").test_runner = "pytest"
		vim.keymap.set("n", "<leader>dd", function()
			require("dap-python").test_method()
		end, { desc = "DAP: Test Method" })
		vim.fn.sign_define(
			"DapBreakpoint",
			{ text = " ", texthl = "DiagnosticError", linehl = "Pmenu", numhl = "Pmenu" }
		)
		vim.fn.sign_define(
			"DapStopped",
			{ text = " ", texthl = "DiagnosticOk", linehl = "PmenuSel", numhl = "PmenuSel" }
		)
	end,
}

---@type LazyPluginSpec
local dap_view = {
	"igorlfs/nvim-dap-view",
	config = function()
		require("dap-view").setup()
		vim.keymap.set("n", "<leader>dv", function()
			require("dap-view").toggle()
		end, { desc = "DAP View: Toggle" })
		vim.keymap.set("n", "<leader>dw", function()
			require("dap-view").add_expr()
		end, { desc = "DAP View: Add Watch Expression" })
	end,
}

---@type LazyPluginSpec
local dap = {
	"mfussenegger/nvim-dap",
	dependencies = {
		dap_python,
		dap_view,
	},
	ft = "python",
	keys = {
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "DAP: Toggle breakpoint",
		},
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "DAP: Continue",
		},
		{
			"<F10>",
			function()
				require("dap").step_over()
			end,
			desc = "DAP: Step Over",
		},
		{
			"<F9>",
			function()
				require("dap").step_into()
			end,
			desc = "DAP: Step Into",
		},
		{
			"<F12>",
			function()
				require("dap").step_out()
			end,
			desc = "DAP: Step Out",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.open()
			end,
			desc = "DAP: REPL",
		},
		{
			"<leader>dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "DAP: Hover",
		},
		{
			"<leader>dp",
			function()
				require("dap.ui.widgets").preview()
			end,
			desc = "DAP: Preview",
		},
		{
			"<leader>df",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end,
			desc = "DAP: Frames",
		},
		{
			"<leader>dc",
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end,
			desc = "DAP: Scopes",
		},
		{
			"<leader>dj",
			function()
				require("dap").goto_()
			end,
			desc = "DAP: Jump to current line",
		},
		{
			"<leader>d<UP>",
			function()
				require("dap").up()
			end,
			desc = "DAP: Move up stack frame",
		},
		{
			"<leader>d<DOWN>",
			function()
				require("dap").down()
			end,
			desc = "DAP: Move down stack frame",
		},
	},
}

return dap
