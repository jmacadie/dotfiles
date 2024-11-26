local utils = require("plugins.lsp.util")

return {
	"mrcjkb/rustaceanvim",
	version = "^5", -- Recommended
	lazy = false, -- This plugin is already lazy
	config = function()
		vim.g.rustaceanvim = {
			tools = {
				test_executor = "background",
			},
			server = {
				on_attach = function(client, bufnr)
					utils.on_attach(client, bufnr)
					utils.nmap("<leader>ca", function()
						vim.cmd.RustLsp("codeAction")
					end, "[C]ode [A]ctions")
					utils.nmap("K", function()
						vim.cmd.RustLsp({ "hover", "actions" })
					end, "Hover")
					utils.nmap("<leader>rr", function()
						vim.cmd.RustLsp("runnables")
					end, "[R]ust [R]unnables")
					utils.nmap("<leader>rt", function()
						vim.cmd.RustLsp("testables")
					end, "[R]ust [T]estables")
				end,
				capabilities = utils.capabilities,
				settings = {
					["rust-analyzer"] = {
						checkOnSave = {
							command = "clippy",
						},
					},
				},
			},
		}
	end,
}
