local M = {
	Lua = {
		diagnostics = {
			global = { "vim" },
		},
		workspace = {
			library = {
				[vim.fn.expand("$VIMRUNTIME/lua")] = true,
				[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				[vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
			},
			checkThirdParty = false,
			maxPreload = 100000,
			preloadFileSize = 10000,
		},
	},
}

return M
