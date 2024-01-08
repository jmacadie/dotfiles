vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

-- Add indentation guides even on blank lines
return {
	"lukas-reineke/indent-blankline.nvim",
	-- Enable `lukas-reineke/indent-blankline.nvim`
	-- See `:help indent_blankline.txt`
	main = "ibl",
	config = true,
}
