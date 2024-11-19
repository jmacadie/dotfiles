-- [[ Setting options ]]
-- Set highlight on search, cancel the highlighting with ESC in normal mode
vim.o.hlsearch = true
vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<CR>")

-- Make line numbers default
vim.wo.relativenumber = true
vim.wo.number = true
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

-- Enable mouse mode
vim.o.mouse = "a"

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = "unnamedplus"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1337#issuecomment-1397639999
-- vim.api.nvim_create_autocmd({ "BufAdd" }, { pattern = { "*" }, command = "normal zx" })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Spell-check Markdown files and Git Commit Messages
vim.api.nvim_command("autocmd FileType markdown setlocal spell")
vim.api.nvim_command("autocmd FileType gitcommit setlocal spell")
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		vim.bo.textwidth = 80
		vim.opt_local.formatoptions:append("t")
	end,
})

-- split right and below
vim.o.splitright = true
vim.o.splitbelow = true
