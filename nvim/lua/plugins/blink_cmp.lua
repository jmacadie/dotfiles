return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"mikavilpas/blink-ripgrep.nvim",
	},

	version = "v0.*",

	opts = {
		keymap = { preset = "default" },
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		menu = {
			draw = {
				columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
				treesitter = { "lsp" },
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
			providers = {
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
				},
			},
		},
		completion = {
			documentation = { auto_show = true },
		},
		signature = { enabled = true },
	},
}
