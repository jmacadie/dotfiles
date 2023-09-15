return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			python = { "black" },
			rust = { "rustfmt" },
			lua = { "stylua" },
			["*"] = { "trim_whitespace" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	},
}
