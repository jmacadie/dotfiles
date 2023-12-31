return {
	"folke/noice.nvim",
	opts = {
		-- add any options here
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},
		markdown = {
			highlights = {
				["^%s*(Args:)"] = "@text.title",
				["^%s*(Returns:)"] = "@text.title",
				["^%s*(Input [A|a]ssumptions:?)"] = "@text.title",
				["^%s*(Output [S|s]tatements:?)"] = "@text.title",
				["^%s*([%l\\_]+)%s+%(.+%)%s?:"] = "@parameter",
				["^%s*[%l\\_]+%s+%((.+)%)%s?:"] = "@type",
				["^%s*([%l\\_]+)%.[%l\\_]+%s+%(.+%)%s?:"] = "@field",
				["^%s*[%l\\_]+%.([%l\\_]+)%s+%(.+%)%s?:"] = "@field",
				["^%s*[%l\\_]+%.[%l\\_]+%s+%((.+)%)%s?:"] = "@type",
				["^%s*([%l\\_]+)%.[%l\\_]+%.[%l\\_]+%s+%(.+%)%s?:"] = "@field",
				["^%s*[%l\\_]+%.([%l\\_]+)%.[%l\\_]+%s+%(.+%)%s?:"] = "@field",
				["^%s*[%l\\_]+%.[%l\\_]+%.([%l\\_]+)%s+%(.+%)%s?:"] = "@field",
				["^%s*[%l\\_]+%.[%l\\_]+%.[%l\\_]+%s+%((.+)%)%s?:"] = "@type",
				["^%s*([%l\\_]+)%.[%l\\_]+%s*$"] = "@field",
				["^%s*[%l\\_]+%.([%l\\_]+)%s*$"] = "@field",
				["\\%['([^']+)'\\%]"] = "@string",
				['\\%["([^"]+)"\\%]'] = "@string",
				["%s*(self)[%s|%.]"] = "@variable.builtin",
				["%s*self%.([%l\\_]+)"] = "@field",
			},
		},
		-- you can enable a preset for easier configuration
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = true, -- add a border to hover docs and signature help
		},
	},
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
}
