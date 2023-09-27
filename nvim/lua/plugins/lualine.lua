-- Set lualine as statusline
return {
	"nvim-lualine/lualine.nvim",
	-- See `:help lualine.txt`
	config = function()
		local custom_theme = require("lualine.themes.nordfox")
		custom_theme.insert.c = { bg = "#b1d196", fg = "#3b4252" }

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = custom_theme,
				component_separators = "|",
				section_separators = "",
			},
		})
	end,
}
