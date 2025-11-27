return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		disable_filetype = { "TelescopePrompt", "dap-repl" },
	}, -- this is equalent to setup({}) function
}
