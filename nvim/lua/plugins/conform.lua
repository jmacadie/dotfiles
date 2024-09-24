return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
			rust = { "rustfmt" },
			lua = { "stylua" },
			ruby = { "rubocop" },
			["*"] = { "trim_whitespace" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	},
}
