local utils = require("plugins.lsp.util")

return {
	"mrcjkb/rustaceanvim",
	version = "^7", -- Recommended
	lazy = false, -- This plugin is already lazy
	config = function()
		vim.g.rustaceanvim = {
			tools = {
				test_executor = "background",
			},
			server = {
				on_attach = function(client, bufnr)
					utils.on_attach(client, bufnr)
					local function map(keys, func, desc)
						utils.nmap(keys, func, bufnr, desc)
					end
					map("<leader>ca", function()
						vim.cmd.RustLsp("codeAction")
					end, "[C]ode [A]ctions")
					map("K", function()
						vim.cmd.RustLsp({ "hover", "actions" })
					end, "Hover")
					map("<leader>rr", function()
						vim.cmd.RustLsp("runnables")
					end, "[R]ust [R]unnables")
					map("<leader>rt", function()
						vim.cmd.RustLsp("testables")
					end, "[R]ust [T]estables")
					vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
				end,
				capabilities = require("blink-cmp").get_lsp_capabilities(),
				settings = {
					["rust-analyzer"] = {
						checkOnSave = true,
						check = {
							command = "clippy",
						},
					},
				},
			},
		}
	end,
}
